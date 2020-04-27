# Format, label and mount partitions
# Needs the device file extension as an argument.
# Note that $11 transforms to {$1}1 -> xvda1
# The argument get passed the device file: xvda, vda, sda, sdb...

# Format the partitions
mkfs.vfat /dev/$11
mkfs.ext4 /dev/$12
mkfs.ext4 /dev/$13
mkfs.ext4 /dev/$14
mkfs.ext4 /dev/$15
mkfs.ext4 /dev/$16
mkfs.ext4 /dev/$17

# Label the partitions for easier Salt handling
tune2fs -L ROOT /dev/$12
tune2fs -L VAR /dev/$13
tune2fs -L VAR_TMP /dev/$14
tune2fs -L VAR_LOG /dev/$15
tune2fs -L VAR_LOG_AUDIT /dev/$16
tune2fs -L HOME /dev/$17

# Make directories
mkdir /mnt/var
mkdir /mnt/var/tmp
mkdir /mnt/var/log
mkdir /mnt/var/log/audit
mkdir /mnt/home

# Mount partitions
mount /dev/$12 /mnt
mount /dev/$13 /mnt/var
mount /dev/$14 /mnt/var/tmp
mount /dev/$15 /mnt/var/log
mount /dev/$16 /mnt/var/log/audit
mount /dev/$17 /mnt/home

