#!/bin/bash

# USE WITH CARE! The script partitions hard drive according to
# partition_map -file with no questions asked. I take no responsibility
# if you delete your data. Always keep backups.

# Tested on Rovius Cloud Platform

# General settings:
TZ="Europe/Helsinki"
LOC="en_US.UTF-8"
KEYBOARD="us"
HOSTNAME="archlinux-roviustest"
SUDOUSER="user"

# Silly settings
PASSWORD="user"

# Which NTP server are we actually using?
timedatectl set-ntp true

# SSH Settings
SSH_PORT="22"
#SSH_PUB_KEY=$(cat id_rsa.pub)

# Disk partitioning, formatting and mounting
sfdisk /dev/xvda < partition_map_rovius
mkfs.vfat /dev/xvda1
mkfs.ext4 /dev/xvda2
mkfs.ext4 /dev/xvda3
mount /dev/xvda2 /mnt
mkdir /mnt/home
mount /dev/xvda3 /mnt/home

# Overwrite the installation ISO mirrorlist with a supplied one as it gets
# copied over to the new installation in the process.
cat mirrorlist > /etc/pacman.d/mirrorlist

# Main install command - bootstrap Arch Linux
pacstrap /mnt base linux linux-firmware grub openssh sudo nano

# Create file system table:
genfstab -U /mnt >> /mnt/etc/fstab

# Settings: here-document is piped to chroot
cat << EOF | arch-chroot /mnt
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
hwclock --systohc
sed -i 's/#$LOC/$LOC/' /etc/locale.gen
locale-gen
echo "LANG=$LOC" > /etc/locale.conf
echo "KEYMAP=$KEYBOARD" > /etc/vconsole.conf
echo "$SUDOUSER ALL=(ALL) ALL" >> /etc/sudoers

echo -e "[Match]\nName=en*\n\n[Network]\nDHCP=true" > /etc/systemd/network/dhcp.network
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
# Timeout is zero, no password? Is it possible to hijack the system here?
grub-install --target=i386-pc /dev/xvda
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i '/LINUX_DEF/c\GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet random.trust_cpu=on"' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

EOF

# Copy existing DNS settings to new installation
cp /etc/resolv.conf /mnt/etc/resolv.conf
