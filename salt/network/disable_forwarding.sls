net.ipv4.ip_forward:
  sysctl.present:
    - value: 0

net.ipv6.conf.all.forwarding:
  sysctl.present:
    - value: 0

/etc/sysctl.d/ipforwarding.conf:
  file.managed:
    - source: salt://managed_files/etc/sysctl.d/ipforwarding.conf

