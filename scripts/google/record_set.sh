#!/bin/bash
source /foundryssl/variables.sh
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum install -y ddclient

if [[ ${webserver_bool} == "True" ]]
then
    client_conf="ddclient_webserver.conf"
else
    client_conf="ddclient.conf"
fi

sudo sed -i "s/api_key/${api_key}/g" /aws-foundry-ssl/files/ddns/google/${client_conf}
sudo sed -i "s/api_secret/${api_secret}/g" /aws-foundry-ssl/files/ddns/google/${client_conf}
sudo sed -i "s/subdomain/${subdomain}/g" /aws-foundry-ssl/files/ddns/google/${client_conf}
sudo sed -i "s/fqdn/${fqdn}/g" /aws-foundry-ssl/files/ddns/google/${client_conf}

if [[ ${webserver_bool} == "True" ]]
then
    sudo sed -i "s/web_server_api_key/${web_server_api_key}/g" /aws-foundry-ssl/files/ddns/google/${client_conf}
    sudo sed -i "s/web_server_api_secret/${web_server_api_secret}/g" /aws-foundry-ssl/files/ddns/google/${client_conf}
fi

sudo cat /aws-foundry-ssl/files/ddns/google/${client_conf} >> /etc/ddclient.conf

sudo systemctl start ddclient
sudo systemctl enable ddclient

sudo ddclient --force