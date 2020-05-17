net.ipv4.conf.all.send_redirects:
  sysctl.present:
    - value: 0

net.ipv4.conf.default.send_redirects:
  sysctl.present:
    - value: 0

net.ipv4.conf.all.accept_redirects:
  sysctl.present:
    - value: 0

net.ipv4.conf.default.accept_redirects:
  sysctl.present:
    - value: 0

net.ipv6.conf.all.accept_redirects:
  sysctl.present:
    - value: 0

net.ipv6.conf.default.accept_redirects:
  sysctl.present:
    - value: 0

net.ipv4.conf.all.secure_redirects:
  sysctl.present:
    - value: 0

net.ipv4.conf.default.secure_redirects:
  sysctl.present:
    - value: 0

