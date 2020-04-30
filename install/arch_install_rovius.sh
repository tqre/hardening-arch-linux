#!/bin/bash

# USE WITH CARE! The script partitions hard drive according to
# partition_map -file with no questions asked. I take no responsibility
# if you delete your data. Always keep backups.

# Tested on Rovius Cloud Platform

# Settings:
HD_DEVICE=xvda

# General settings:
TZ="Europe/Helsinki"
LOC="en_US.UTF-8"
KEYBOARD="us"
SUDOUSER="user"
PASSWORD="user"

# Salt settings
MASTER_IP="<ip-address>"
FILESERVER_PORT="80"
M_PORT="4506"
P_PORT="4505"
HOSTNAME="minion-"

timedatectl set-ntp true

# SSH Settings
SSH_PORT="22"
#SSH_PUB_KEY=$(cat id_rsa.pub)

# Disk partitioning, formatting, labelling and mounting
sfdisk /dev/$HD_DEVICE < partitions/partition_map_rovius_32
partitions/prepare.sh $HD_DEVICE

# Overwrite the installation ISO mirrorlist with a supplied one as it gets
# copied over to the new installation in the process.
cat mirrorlist > /etc/pacman.d/mirrorlist

# Main install command - bootstrap Arch Linux
pacstrap /mnt base linux grub openssh sudo nano wget python \
python-jinja python-yaml python-markupsafe python-requests python-pyzmq \
python-m2crypto python-systemd python-distro python-pycryptodomex

# Create filesystem table:
genfstab -L /mnt >> /mnt/etc/fstab

# Copy the saltmaster certificate to the new machine
cp saltmaster.crt /mnt/etc/ssl/private/saltmaster.crt

# Chroot setup:
# here-document is piped to chroot
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
echo -e "127.0.0.1 localhost\n::1 localhost\n$MASTER_IP saltmaster" > /etc/hosts

# Now this is plain silly on a security focused project. Better way to do this?
useradd -m $SUDOUSER
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
grub-install --target=i386-pc /dev/$HD_DEVICE
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i '/LINUX_DEF/c\GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Install old python-msgpack for Salt-py3, make pacman to ignore it in the future
sed -i 's/#IgnorePkg   =/IgnorePkg   = python-msgpack/' /etc/pacman.conf
wget -P /var/cache/pacman/pkg \
	https://archive.archlinux.org/packages/p/python-msgpack/python-msgpack-0.6.2-3-x86_64.pkg.tar.xz
pacman -U --noconfirm /var/cache/pacman/pkg/python-msgpack-0.6.2-3-x86_64.pkg.tar.xz

#TODO: download built salt-py3 pkg.tar.xz
wget -P /var/cache/pacman/pkg/ \
	--ca-certificate=/etc/ssl/private/saltmaster.crt \
	https://saltmaster:$FILESERVER_PORT/salt-py3-3000.1-2-any.pkg.tar.xz
pacman -U --noconfirm /var/cache/pacman/pkg/salt-py3-3000.1-2-any.pkg.tar.xz

# Salt configuration
systemctl enable salt-minion
echo -e "master: saltmaster\nmaster_port: $M_PORT\npublish_port: $P_PORT\nid: $HOSTNAME" > /etc/salt/minion

EOF

# Copy existing DNS settings to new installation
cp /etc/resolv.conf /mnt/etc/resolv.conf
