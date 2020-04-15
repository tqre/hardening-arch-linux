/var/log:
  mount.mounted:
    - device: LABEL=VAR_LOG
    - fstype: ext4
    - opts:
      - rw
      - relatime
      - data=ordered
