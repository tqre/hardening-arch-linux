net.ipv4.conf.all.log_martians:
  sysctl.present:
    - value: 1

net.ipv4.conf.default.log_martians:
  sysctl.present:
    - value: 1

/etc/sysctl.d/log_martians.conf:
  file.managed:
    - source: salt://managed_files/etc/sysctl.d/log_martians.conf

