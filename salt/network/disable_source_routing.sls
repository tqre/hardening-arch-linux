net.ipv4.conf.all.accept_source_route:
  sysctl.present:
    - value: 0

net.ipv4.conf.default.accept_source_route:
  sysctl.present:
    - value: 0

net.ipv6.conf.all.accept_source_route:
  sysctl.present:
    - value: 0

net.ipv6.conf.default.accept_source_route:
  sysctl.present:
    - value: 0

/etc/sysctl.d/source_routing.conf:
  file.managed:
    - source: salt://managed_files/etc/sysctl.d/source_routing.conf

