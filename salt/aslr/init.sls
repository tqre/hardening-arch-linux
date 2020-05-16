kernel.randomize_va_space:
  sysctl.present:
    - value: 2

/etc/sysctl.d/aslr.conf:
  file.managed:
    - source: salt://managed_files/etc/sysctl.d/aslr.conf

