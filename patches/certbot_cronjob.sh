#!/usr/bin/env bash

SCRIPT_PATH=/foundrycron/reboot_certbot.sh
CRON_PATH=/var/spool/cron/root

yum install python-certbot-nginx -y
mkdir /var/log/foundrycron /foundrycron

# create certbot renewal script
cat >> ${SCRIPT_PATH} <<EOL
echo \$PATH > /var/log/foundrycron/path.log 2>&1
sleep 15
certbot renew --nginx --no-self-upgrade --no-random-sleep-on-renew --post-hook "systemctl restart nginx" > /var/log/foundrycron/certbot_renew.log 2>&1
EOL
chmod a+x ${SCRIPT_PATH}

# change path in cron
echo -e "PATH=/usr/bin:/bin:/usr/sbin\n\n$(cat ${CRON_PATH})" > ${CRON_PATH}

# replace explicit renew with script
sed -i "s|@reboot    /usr/bin/certbot renew --quiet|@reboot    ${SCRIPT_PATH}|" ${CRON_PATH}

# replace scheduled renew
sed -i "s|0 12 * * *     /usr/bin/certbot renew --quiet|0 12 * * *     certbot renew --nginx --no-self-upgrade --no-random-sleep-on-renew --post-hook \"systemctl restart nginx\" > /var/log/foundrycron/certbot_renew_daily.log 2>&1|" ${CRON_PATH}