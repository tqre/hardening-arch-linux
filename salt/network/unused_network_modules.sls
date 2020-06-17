/etc/modprobe.d/unused_network_modules.conf:
  file.managed:
    - source: salt://managed_files/etc/modprobe.d/unused_network_modules.conf
  cmd.run:
    - name: mkinitcpio -P
    - onchanges:
      - file: /etc/modprobe.d/unused_network_modules.conf

