#!/bin/bash

# USE WITH CARE! The script partitions hard drive according to
# partition_map -file with no questions asked. I take no responsibility
# if you delete your data. Always keep backups.

# Tested on Rovius Cloud Platform

# General settings:
TZ="Europe/Helsinki"
LOC="en_US.UTF-8"
KEYBOARD="us"

# Salt settings
#MASTER_IP="saltmaster"
#M_PORT="4506"
#P_PORT="4505"
HOSTNAME="minion-"

SUDOUSER="user"
# Silly settings
PASSWORD="user"

timedatectl set-ntp true

# SSH Settings
SSH_PORT="22"
#SSH_PUB_KEY=$(cat id_rsa.pub)

# Disk partitioning, formatting, labelling and mounting
sfdisk /dev/xvda < partition_map_rovius_32
mkfs.vfat /dev/xvda1
mkfs.ext4 /dev/xvda2
mkfs.ext4 /dev/xvda3
mkfs.ext4 /dev/xvda4
mkfs.ext4 /dev/xvda5
mkfs.ext4 /dev/xvda6
mkfs.ext4 /dev/xvda7

# Label the partitions for easier Salt handling
tune2fs -L ROOT /dev/xvda2
tune2fs -L VAR /dev/xvda3
tune2fs -L VAR_TMP /dev/xvda4
tune2fs -L VAR_LOG /dev/xvda5
tune2fs -L VAR_LOG_AUDIT /dev/xvda6
tune2fs -L HOME /dev/xvda7

mount /dev/xvda2 /mnt
mkdir /mnt/var
mount /dev/xvda3 /mnt/var
mkdir /mnt/var/tmp
mount /dev/xvda4 /mnt/var/tmp
mkdir /mnt/var/log
mount /dev/xvda5 /mnt/var/log
mkdir /mnt/var/log/audit
mount /dev/xvda6 /mnt/var/log/audit
mkdir /mnt/home
mount /dev/xvda7 /mnt/home

# Overwrite the installation ISO mirrorlist with a supplied one as it gets
# copied over to the new installation in the process.
cat mirrorlist > /etc/pacman.d/mirrorlist

# Main install command - bootstrap Arch Linux
pacstrap /mnt base base-devel linux grub openssh sudo nano git wget python \
python-jinja python-yaml python-markupsafe python-requests python-pyzmq \
python-m2crypto python-systemd python-distro python-pycryptodomex

# Create filesystem table:
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

echo -e "[Match]\nName=eth0\n\n[Network]\nDHCP=true" > /etc/systemd/network/dhcp.network
systemctl enable systemd-networkd.service

echo $HOSTNAME > /etc/hostname
echo -e "127.0.0.1 localhost\n::1 localhost" > /etc/hosts

useradd -m $SUDOUSER
# Now this is plain silly on a security focused project. Better way to do this?
echo -e "$PASSWORD\n$PASSWORD" | passwd $SUDOUSER
#runuser $SUDOUSER -c 'mkdir ~/.ssh'
#runuser $SUDOUSER -c 'echo $SSH_PUB_KEY > ~/.ssh/authorized_keys'

# SSH Settings:
# Change default port
sed -i "s/#Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config
# Disable sftp subsystem
sed -i 's/Subsystem/#Subsystem/' /etc/ssh/sshd_config
#sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i '/#PermitRootLogin pro/c\PermitRootLogin no' /etc/ssh/sshd_config
systemctl enable sshd

# GRUB installation
grub-install --target=i386-pc /dev/xvda
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i '/LINUX_DEF/c\GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Salt install
sed -i 's/#IgnorePkg   =/IgnorePkg   = python-msgpack/' /etc/pacman.conf
wget -P /var/cache/pacman/pkg \
	https://archive.archlinux.org/packages/p/python-msgpack/python-msgpack-0.6.2-3-x86_64.pkg.tar.xz
pacman -U --noconfirm /var/cache/pacman/pkg/python-msgpack-0.6.2-3-x86_64.pkg.tar.xz
runuser $SUDOUSER -c 'cd ~;git clone https://aur.archlinux.org/salt-py3.git'
runuser $SUDOUSER -c 'cd ~/salt-py3;makepkg -s'
pacman -U --noconfirm /home/user/salt-py3/salt-py3-3000.1-2-any.pkg.tar.xz

# Salt configuration
systemctl enable salt-minion
echo -e "master: $MASTER_IP\nmaster_port: $M_PORT\npublish_port: $P_PORT\nid: $HOSTNAME" > /etc/salt/minion

EOF

# Copy existing DNS settings to new installation
cp /etc/resolv.conf /mnt/etc/resolv.conf
