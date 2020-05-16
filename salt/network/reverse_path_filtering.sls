net.ipv4.conf.all.rp_filter:
  sysctl.present:
    - value: 1

net.ipv4.conf.default.rp_filter:
  sysctl.present:
    - value: 1

/etc/sysctl.d/reverse_path_filtering.conf:
  file.managed:
    - source: salt://managed_files/etc/sysctl.d/reverse_path_filtering.conf

