/dev/shm:
  mount.mounted:
    - device: tmpfs
    - fstype: tmpfs
    - opts:
      - defaults
      - rw
      - nosuid
      - nodev
      - noexec
