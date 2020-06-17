/etc/modprobe.d/uncommon_protocols.conf:
  file.managed:
    - source: salt://managed_files/etc/modprobe.d/uncommon_protocols.conf
  cmd.run:
    - name: mkinitcpio -P
    - onchanges:
      - file: /etc/modprobe.d/uncommon_protocols.conf


