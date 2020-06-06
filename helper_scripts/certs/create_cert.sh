# Check certificate expiry & create new SSL cert for saltmaster
#!/bin/bash

cat /etc/ssl/private/saltmaster.crt | openssl x509 -noout -enddate

sudo openssl req -x509 -nodes -newkey rsa:4096 -days 365 -keyout /etc/nginx/ssl/saltmaster.key -out /etc/nginx/ssl/saltmaster.crt
sudo cp -v /etc/nginx/ssl/saltmaster.crt /srv/salt/managed_files/etc/ssl/private/saltmaster.crt

# Don't forget to:
sudo systemctl restart nginx

