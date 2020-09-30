#!/bin/bash

# grab public ip address
source /foundryssl/variables.sh
instance_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)

# adds custom foundry subdomain to GoDaddy Host Records
# curl -X PUT 
# 	  -H "Authorization: sso-key ${api_key}:${api_secret}" "https://api.godaddy.com/v1/domains/${fqdn}/records/A/${subdomain}" 
#     -H "Content-Type: application/json" 
#     -H "Accept: application/json" 
#     -d "[{\"data\": \"${instance_ip}\",\"name\": \"${subdomain}\", \"ttl\": 1800, \"type\": \"A\"}]"
curl -X PUT -H "Authorization: sso-key ${api_key}:${api_secret}" "https://api.godaddy.com/v1/domains/${fqdn}/records/A/${subdomain}" -H "Content-Type: application/json" -H "Accept: application/json" -d "[{\"data\": \"${instance_ip}\",\"name\": \"${subdomain}\", \"ttl\": 1800, \"type\": \"A\"}]"

if [[ "${webserver_bool}" == "True" ]]
then
    # replace A record (domain) with ec2 instance IP
    # curl -X PUT -H "Authorization: sso-key ${api_key}:${api_secret}" "https://api.godaddy.com/v1/domains/${fqdn}/records/A/@"
    #             -H "Content-Type: application/json"
    #             -H "Accept: application/json"
    #             -d "[{\"data\": \"${instanct_ip}\", \"name\": \"@\", \"ttl\": 600, \"type\": \"A\"}]"
    curl -X PUT -H "Authorization: sso-key ${api_key}:${api_secret}" "https://api.godaddy.com/v1/domains/${fqdn}/records/A/@" -H "Content-Type: application/json" -H "Accept: application/json" -d "[{\"data\": \"${instance_ip}\", \"name\": \"@\", \"ttl\": 600, \"type\": \"A\"}]"
fi


# install dynamic dns as cron job
sudo cp /aws-foundry-ssl/scripts/godaddy/dynamic_dns.sh /foundryssl/dynamic_dns.sh
crontab -l | { cat; echo "@reboot    /foundryssl/dynamic_dns.sh > /dev/null"; } | crontab -
crontab -l | { cat; echo "*/10 * * * *    /foundryssl/dynamic_dns.sh > /dev/null"; } | crontab -