/home:
  mount.mounted:
    - device: LABEL=HOME
    - fstype: ext4
    - opts:
      - rw
      - nodev
      - relatime
