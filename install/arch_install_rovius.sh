#!/bin/bash

# USE WITH CARE! The script partitions hard drive according to
# partition_map -file with no questions asked. I take no responsibility
# if you delete your data. Always keep backups.

# Tested and working on Rovius Cloud Platform

# Settings:
HD_DEVICE=xvda
timedatectl set-ntp true

# General settings:
TZ="Europe/Helsinki"
LOC="en_US.UTF-8"
KEYBOARD="us"
SUDOUSER="user"
PASSWORD="user"
GPG_KEYID=""

# Salt settings
MASTER_IP="<ip-address>"
FILESERVER_PORT="80"
M_PORT="4506"
P_PORT="4505"
HOSTNAME="minion-"

# Disk partitioning, formatting, labelling and mounting
sfdisk /dev/$HD_DEVICE < partitions/partition_map_rovius_32
chmod +x partitions/prepare.sh
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

useradd -m $SUDOUSER
echo -e "$PASSWORD\n$PASSWORD" | passwd $SUDOUSER

# SSH Settings:
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

# Update trust anchors:
trust anchor /etc/ssl/private/saltmaster.crt
update-ca-trust

# Download saltmaster's public GPG key to sudousers home directory
mkdir /home/$SUDOUSER/.gnupg
wget -P /home/$SUDOUSER/.gnupg https://saltmaster:$FILESERVER_PORT/saltmaster.gpg
pacman-key --add /home/$SUDOUSER/.gnupg/saltmaster.gpg
pacman-key --lsign-key $GPG_KEYID

# Set up custom repository
echo -e "[saltmaster]\nServer = https://saltmaster:$FILESERVER_PORT\n" >> /etc/pacman.conf
pacman -Sy
pacman -S --noconfirm salt-py3

# Salt configuration
systemctl enable salt-minion
echo -e "master: saltmaster\nmaster_port: $M_PORT\npublish_port: $P_PORT\nid: $HOSTNAME" > /etc/salt/minion

EOF

# Copy existing DNS settings to new installation
cp /etc/resolv.conf /mnt/etc/resolv.conf
