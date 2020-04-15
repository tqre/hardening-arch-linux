/var/log/audit:
  mount.mounted:
    - device: LABEL=VAR_LOG_AUDIT
    - fstype: ext4
    - opts:
      - rw
      - relatime
      - data=ordered
