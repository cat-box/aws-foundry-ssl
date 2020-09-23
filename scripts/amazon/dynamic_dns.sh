#!/bin/bash
source /foundryssl/variables.sh

# retrieve public ip
public_ip="$(dig +short myip.opendns.com @resolver1.opendns.com)"

# get IP for subdomain record
aws_ip=`aws route53 list-resource-record-sets --hosted-zone-id ${zone_id} | jq ".ResourceRecordSets[] | select(.Name==\"${fqdn}\") | select(.Type==\"A\") | .ResourceRecords[] | .Value" | cut -d '"' -f2`

# if dont match then create temp dns_block.json replacing domain_here and ip_here with values
if [ "${public_ip}" != "${aws_ip}" ]
then
    # change subdomain record
    aws route53 change-resource-record-sets --hosted-zone-id ${zone_id} --change-batch "{ \"Comment\": \"Dynamic DNS change\", \"Changes\": [ { \"Action\": \"UPSERT\", \"ResourceRecordSet\": { \"Name\": \"${subdomain}.${fqdn}\", \"Type\": \"A\", \"TTL\": 120, \"ResourceRecords\": [ { \"Value\": \"${public_ip}\" } ] } } ] }"
    if [ "${webserver_bool}" == "True" ]
    then
        aws route53 change-resource-record-sets --hosted-zone-id ${zone_id} --change-batch "{ \"Comment\": \"Dynamic DNS change\", \"Changes\": [ { \"Action\": \"UPSERT\", \"ResourceRecordSet\": { \"Name\": \"${fqdn}\", \"Type\": \"A\", \"TTL\": 120, \"ResourceRecords\": [ { \"Value\": \"${public_ip}\" } ] } } ] }"
    fi
fi
