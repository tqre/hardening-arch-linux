aide:
  pkg.installed

/etc/aide.conf:
  file.managed:
    - source: salt://managed_files/etc/aide.conf

