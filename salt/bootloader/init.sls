/boot/grub/grub.cfg:
  file.managed:
    - user: root
    - group: root
    - mode: 400

/etc/grub.d/09_make_OS_entries_unrestricted:
  file.managed:
    - source: salt://managed_files/etc/grub.d/09_make_OS_entries_unrestricted
    - user: root
    - group: root
    - mode: 700
  cmd.run:
    - name: grub-mkconfig -o /boot/grub/grub.cfg
    - onchanges:
      - file: /etc/grub.d/09_make_OS_entries_unrestricted

/etc/grub.d/40_custom:
  file.managed:
    - source: salt://managed_files/etc/grub.d/40_custom
    - user: root
    - group: root
    - mode: 700
  cmd.run:
    - name: grub-mkconfig -o /boot/grub/grub.cfg
    - onchanges:
      - file: /etc/grub.d/40_custom

