net.ipv4.icmp_echo_ignore_broadcasts:
  sysctl.present:
    - value: 1

net.ipv4.icmp_ignore_bogus_error_responses:
  sysctl.present:
    - value: 1

/etc/sysctl.d/icmp_ignore.conf:
  file.managed:
    - source: salt://managed_files/etc/sysctl.d/icmp_ignore.conf

