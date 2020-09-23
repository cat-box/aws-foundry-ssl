#!/bin/bash

# grab variables
source /foundryssl/variables.sh

# retrieve public ip
public_ip="$(dig +short myip.opendns.com @resolver1.opendns.com)"

# retrieve dns data of the subdomain from godaddy
dns_data=`curl -s -X GET -H "Authorization: sso-key ${api_key}:${api_secret}" "https://api.godaddy.com/v1/domains/${fqdn}/records/A/${subdomain}"`
godaddy_ip=`echo ${dns_data} | cut -d ',' -f 1 | tr -d '"' | cut -d ":" -f 2`

# compare current public ip with godaddy record and replace if different
if [ "${public_ip}" != "${godaddy_ip}" ] && [ "${public_ip}" != "" ]
then
    if [ "${webserver_bool}" == "True" ]
    then
        # update the @ record (domain)
        curl -X PUT -H "Authorization: sso-key ${api_key}:${api_secret}" "https://api.godaddy.com/v1/domains/${fqdn}/records/A/@" -H "Content-Type: application/json" -H "Accept: application/json" -d "[{\"data\": \"${public_ip}\", \"name\": \"@\", \"ttl\": 600, \"type\": \"A\"}]"
    fi
    # update the A record (subdomain)
    curl -X PUT -H "Authorization: sso-key ${api_key}:${api_secret}" "https://api.godaddy.com/v1/domains/${fqdn}/records/A/${subdomain}" -H "Content-Type: application/json" -H "Accept: application/json" -d "[{\"data\": \"${public_ip}\", \"name\": \"${subdomain}\", \"ttl\": 600, \"type\": \"A\"}]"
else
    echo "Dynamic DNS: Public IP (${public_ip}) and GoDaddy IP (${godaddy_ip}) are the same. No changes made"
fi