/etc/pacman.conf:
  file.managed:
    - source: salt://managed_files/etc/pacman.conf
    - user: root
    - group: root
    - mode: 644

/etc/pacman.d/mirrorlist:
  file.managed:
    - source: salt://managed_files/etc/pacman.d/mirrorlist
    - user: root
    - group: root
    - mode: 644

