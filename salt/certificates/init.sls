/etc/ssl/private/saltmaster.crt:
  file.managed:
    - source: salt://managed_files/etc/ssl/private/saltmaster.crt
  cmd.run:
    - name: rm -v /etc/ca-certificates/trust-source/saltmaster.p11-kit
    - onchanges:
      - file: /etc/ssl/private/saltmaster.crt

'trust anchor /etc/ssl/private/saltmaster.crt':
  cmd.run:
    - onchanges:
      - file: /etc/ssl/private/saltmaster.crt

'update-ca-trust':
  cmd.run:
    - onchanges:
      - file: /etc/ssl/private/saltmaster.crt


