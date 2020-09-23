#!/bin/bash

# grab variables
source /foundryssl/variables.sh
if [[ ${webserver_bool} == "True" ]]
then
    client_conf="ddclient_webserver.conf"
else
    client_conf="ddclient.conf"
fi

# install ddclient
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum install -y ddclient

# set ddclient config
sudo sed -i "s/api_key/${api_key}/g" /aws-foundry-ssl/files/ddns/google/${client_conf}
sudo sed -i "s/api_secret/${api_secret}/g" /aws-foundry-ssl/files/ddns/google/${client_conf}
sudo sed -i "s/subdomain/${subdomain}/g" /aws-foundry-ssl/files/ddns/google/${client_conf}
sudo sed -i "s/fqdn/${fqdn}/g" /aws-foundry-ssl/files/ddns/google/${client_conf}

if [[ ${webserver_bool} == "True" ]]
then
    sudo sed -i "s/webserver_user/${webserver_user}/g" /aws-foundry-ssl/files/ddns/google/${client_conf}
    sudo sed -i "s/webserver_pass/${webserver_pass}/g" /aws-foundry-ssl/files/ddns/google/${client_conf}
fi

sudo cat /aws-foundry-ssl/files/ddns/google/${client_conf} >> /etc/ddclient.conf

# restart ddclient
sudo systemctl start ddclient
sudo systemctl enable ddclient

sudo ddclient --force