/var/tmp:
  mount.mounted:
    - device: LABEL=VAR_TMP
    - fstype: ext4
    - opts:
      - defaults
      - rw
      - nosuid
      - nodev
      - noexec
      - relatime

