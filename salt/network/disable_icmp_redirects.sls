net.ipv4.conf.all.send_redirects:
  sysctl.present:
    - value: 0

net.ipv4.conf.default.send_redirects:
  sysctl.present:
    - value: 0

/etc/sysctl.d/ICMPredirects.conf:
  file.managed:
    - source: salt://managed_files/etc/sysctl.d/ICMPredirects.conf


