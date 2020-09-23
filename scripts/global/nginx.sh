#! /bin/bash
source /foundryssl/variables.sh

if [[ ${webserver_bool} == "True" ]]
then
    foundry_file="foundryvtt_webserver.conf"
else
    foundry_file="foundryvtt.conf"
fi

# install nginx
sudo amazon-linux-extras install -y nginx1

# configure nginx
sudo mkdir /var/log/nginx/foundry
sudo cp /aws-foundry-ssl/files/nginx/${foundry_file} /etc/nginx/conf.d/foundryvtt.conf
sudo sed -i "s/YOURSUBDOMAINHERE/${subdomain}/g" /etc/nginx/conf.d/foundryvtt.conf
sudo sed -i "s/YOURDOMAINHERE/${fqdn}/g" /etc/nginx/conf.d/foundryvtt.conf

# start nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# configure foundry for nginx
sudo sed -i "s/\"hostname\":.*/\"hostname\": \"${subdomain}\.${fqdn}\",/g" /foundrydata/Config/options.json
sudo sed -i 's/"proxyPort":.*/"proxyPort": "80",/g' /foundrydata/Config/options.json

/bin/cp -rf /aws-foundry-ssl/website/* /usr/share/nginx/html

systemctl restart nginx