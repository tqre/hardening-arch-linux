#!/bin/sh
# This generated list includes other stuff too
cat /proc/config.gz | gunzip > running.config
grep _FS running.config > FS_modules
