#!/bin/bash

source /foundryssl/variables.sh
source /aws-foundry-ssl/variables/foundry_variables.sh

case ${domain_registrar} in
    amazon)
        sleep 20s
        source /aws-foundry-ssl/scripts/amazon/hosted_zone_id.sh
        ;;
    godaddy)
        # set dns records and install dynamic dns
        source /aws-foundry-ssl/scripts/godaddy/record_set.sh
        ;;
    google)
        source /aws-foundry-ssl/scripts/google/record_set.sh
        ;;
    namecheap)
        source /aws-foundry-ssl/scripts/namecheap/record_set.sh
        ;;
esac

# install foundry
source /aws-foundry-ssl/scripts/global/foundry.sh

# install nginx
source /aws-foundry-ssl/scripts/global/nginx.sh

# set up certificates
# disabled for testing
# source /aws-foundry-ssl/scripts/global/certbot.sh

# clean up install files
# Do not do this during testing
# sudo rm -r /aws-foundry-ssl

reboot now