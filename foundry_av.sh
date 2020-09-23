#!/bin/bash

if [[ "${webserver_bool}" == "True" ]]
then
    sudo sed -i 's|"sslCert":.*|"sslCert": "/etc/letsencrypt/live/${fqdn}/fullchain.pem",|g' /foundrydata/Config/options.json
    sudo sed -i 's/"sslKey":.*/"sslKey": "/etc/letsencrypt/live/${fqdn}/privkey.pem",/g' /foundrydata/Config/options.json
else
    sudo sed -i "s|\"sslCert\":.*|\"sslCert\": \"/etc/letsencrypt/live/${subdomain}.${fqdn}/fullchain.pem\",|g" /foundrydata/Config/options.json
    sudo sed -i "s|\"sslKey\":.*|\"sslKey\": \"/etc/letsencrypt/live/${subdomain}.${fqdn}/privkey.pem\",|g" /foundrydata/Config/options.json
fi

