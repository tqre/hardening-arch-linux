/etc/modprobe.d/disable_usb.conf:
  file.managed:
    - source: salt://managed_files/etc/modprobe.d/disable_usb.conf
  cmd.run:
    - name: mkinitcpio -P
    - onchanges:
      - file: /etc/modprobe.d/disable_usb.conf    

