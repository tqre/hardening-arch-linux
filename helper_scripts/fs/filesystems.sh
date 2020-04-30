#!/bin/sh

# Enumerate kernel modules with _FS in them
#cat /proc/config.gz | gunzip > running.config
#grep _FS running.config > FS_modules_compiled_to_kernel

# Better approach: the installed modules directory
ls -1 /lib/modules/$(uname -r)/kernel/fs | \
sed 's/^/#install /' | sed 's/$/ \/bin\/true/' > disable_filesystems.conf



