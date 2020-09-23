#!/bin/bash
source /foundryssl/variables.sh

# install epel
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# install certbot
sudo yum install -y certbot python2-certbot-nginx

# install certificates
sudo certbot --agree-tos -n --nginx -d ${subdomain}.${fqdn} -m ${email} --no-eff-email

# install certificates for optional webserver
if [[ ${webserver_bool} == 'True' ]]; then
    sudo certbot --agree-tos -n --nginx -d ${fqdn},www.${fqdn} -m ${email} --no-eff-email
fi

# configure to autorenew certs
crontab -l | { cat; echo "@reboot    /usr/bin/certbot renew --quiet"; } | crontab -
crontab -l | { cat; echo "0 12 * * *     /usr/bin/certbot renew --quiet"; } | crontab -

sudo sed -i -e "s|location / {|include conf.d/drop;\n\n\tlocation / {|g" /etc/nginx/conf.d/foundryvtt.conf
sudo cp /aws-foundry-ssl/files/nginx/drop /etc/nginx/conf.d/drop
sudo systemctl restart nginx

# configure foundry to use ssl
sudo sed -i 's/"proxyPort":.*/"proxyPort": "443",/g' /foundrydata/Config/options.json
sudo sed -i 's/"proxySSL":.*/"proxySSL": true,/g' /foundrydata/Config/options.json