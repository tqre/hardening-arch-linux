/boot/grub/grub.cfg:
  file.managed:
    - user: root
    - group: root
    - mode: 400

/etc/grub.d/40_custom:
  file.managed:
    - source: salt://managed_files/etc/grub.d/40_custom
    - user: root
    - group: root
    - mode: 500
  cmd.run:
    - name: grub-mkconfig -o /boot/grub/grub.cfg
    - onchanges:
      - file: /etc/grub.d/40_custom

