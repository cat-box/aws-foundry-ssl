#!/bin/bash

source /foundryssl/variables.sh
source /aws-foundry-ssl/variables/foundry_variables.sh
echo $domain_registrar > /registrar.txr
case ${domain_registrar} in
    amazon)
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
source /aws-foundry-ssl/scripts/global/certbot.sh

# clean up install files
# Do not do this during testing
#sudo rm -r /aws-foundry-ssl

reboot now