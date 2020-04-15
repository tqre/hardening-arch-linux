/etc/modprobe.d/disable_filesystems.conf:
  file.managed:
    - source: salt://disable_filesystems/disable_filesystems.conf
  cmd.run:
    - name: touch /root/changed
    - onchanges:
      - file: /etc/modprobe.d/disable_filesystems.conf
    

