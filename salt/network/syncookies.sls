net.ipv4.tcp_syncookies:
  sysctl.present:
    - value: 1

/etc/sysctl.d/syncookies.conf:
  file.managed:
    - source: salt://managed_files/etc/sysctl.d/syncookies.conf

