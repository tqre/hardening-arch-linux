/etc/sysctl.d/network.conf:
  file.managed:
    - source: salt://managed_files/etc/sysctl.d/network.conf

include:
  - network.disable_forwarding
  - network.disable_icmp_redirects
  - network.disable_source_routing
  - network.log_martians
  - network.icmp_ignore
  - network.reverse_path_filtering
  - network.syncookies
