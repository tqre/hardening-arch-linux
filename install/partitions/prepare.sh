
# Format the partitions
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

# Make directories
mkdir /mnt/var
mkdir /mnt/var/tmp
mkdir /mnt/var/log
mkdir /mnt/var/log/audit
mkdir /mnt/home

# Mount partitions
mount /dev/xvda2 /mnt
mount /dev/xvda3 /mnt/var
mount /dev/xvda4 /mnt/var/tmp
mount /dev/xvda5 /mnt/var/log
mount /dev/xvda6 /mnt/var/log/audit
mount /dev/xvda7 /mnt/home

