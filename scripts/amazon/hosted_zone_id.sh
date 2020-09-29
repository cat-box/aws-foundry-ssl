#!/bin/bash

sudo yum install -y jq
 
zone_id=`aws route53 list-hosted-zones | jq ".HostedZones[] | select(.Name==\"${fqdn}.\") | .Id" | cut -d / -f3 | cut -d '"' -f1`

echo "zone_id=${zone_id}" >> /foundryssl/variables.sh

sudo cp /aws-foundry-ssl/scripts/amazon/dynamic_dns.sh /foundryssl/dynamic_dns.sh
crontab -l | { cat; echo "@reboot    /foundryssl/dynamic_dns.sh > /dev/null"; } | crontab -
crontab -l | { cat; echo "*/10 * * * *    /foundryssl/dynamic_dns.sh > /dev/null"; } | crontab -