#!/bin/bash

# USE WITH CARE! The script partitions hard drive according to
# partition_map -file with no questions asked. I take no responsibility
# if you delete your data. Always keep backups.

# ! Untested version
HD_DEVICE=vda
timedatectl set-ntp true

# General settings:
TZ="Europe/Helsinki"
LOC="en_US.UTF-8"
KEYBOARD="us"
HOSTNAME="saltmaster"
SUDOUSER="user"
SSH_PORT="22"
SSH_PUB_KEY=$(cat id_rsa.pub)

# Disk partitioning, formatting and mounting
sfdisk /dev/$HD_DEVICE < partitions/partition_map_upcloud_50
chmod +x partitions/prepare.sh
partitions/prepare.sh $HD_DEVICE

# Overwrite the installation ISO mirrorlist with a supplied one as it gets
# copied over to the new installation in the process.
cat mirrorlist > /etc/pacman.d/mirrorlist

# Main install command - bootstrap Arch Linux
pacstrap /mnt base base-devel linux grub openssh \
	nano wget git ufw nginx-mainline \
	python python-jinja python-yaml python-markupsafe python-requests \
	python-pyzmq python-m2crypto python-systemd python-distro \
	python-pycryptodomex

# Create file system table:
genfstab -L /mnt >> /mnt/etc/fstab

# Settings: here-document is piped to chroot
cat << EOF | arch-chroot /mnt
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
hwclock --systohc
sed -i 's/#$LOC/$LOC/' /etc/locale.gen
locale-gen
echo "LANG=$LOC" > /etc/locale.conf
echo "KEYMAP=$KEYBOARD" > /etc/vconsole.conf
echo "$SUDOUSER ALL=(ALL) ALL" >> /etc/sudoers

echo -e "[Match]\nName=ens*\n\n[Network]\nDHCP=true" > /etc/systemd/network/dhcp.network
systemctl enable systemd-networkd.service

echo $HOSTNAME > /etc/hostname
echo -e "127.0.0.1 localhost\n::1 localhost" > /etc/hosts

useradd -m $SUDOUSER
runuser $SUDOUSER -c 'mkdir ~/.ssh'
runuser $SUDOUSER -c 'echo $SSH_PUB_KEY > ~/.ssh/authorized_keys'

# SSH configuration
sed -i "s/#Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config
# Disable sftp subsystem
sed -i 's/Subsystem/#Subsystem/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i '/#PermitRootLogin pro/c\PermitRootLogin no' /etc/ssh/sshd_config
systemctl enable sshd

# GRUB installation
grub-install --target=i386-pc /dev/$HD_DEVICE
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i '/LINUX_DEF/c\GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet random.trust_cpu=on"' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Salt-py3 dependency installation:
sed -i 's/#IgnorePkg   =/IgnorePkg   = python-msgpack/' /etc/pacman.conf
wget -P /var/cache/pacman/pkg \
        https://archive.archlinux.org/packages/p/python-msgpack/python-msgpack-0.6.2-3-x86_64.pkg.tar.xz
pacman -U --noconfirm /var/cache/pacman/pkg/python-msgpack-0.6.2-3-x86_64.pkg.tar.xz

EOF

# Copy existing DNS settings to new installation
cp /etc/resolv.conf /mnt/etc/resolv.conf

echo
echo To finish the installation, set the password for the user account:
echo Enter the chroot environment with:
echo   arch-chroot /mnt
echo And set the password with:
echo   passwd $SUDOUSER

