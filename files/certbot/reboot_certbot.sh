#!/bin/bash

echo $PATH > /var/log/foundrycron/path.log 2>&1

sleep 15
certbot renew --nginx --no-self-upgrade --no-random-sleep-on-renew --post-hook "systemctl restart nginx" > /var/log/foundrycron/certbot_renew.log 2>&1