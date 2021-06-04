#!/bin/bash

# This patch is intended to be used on deployments created prior to OCT 23, 2020
#
# SYSTEMD SERVICE PATCH: Updates rc.local deployments to systemd service

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

# check if root
if [ "$EUID" -ne 0 ]
then 
    echo -e "${RED}ERROR: Please run as root. (sudo su)${NC}"
    echo -e "${YELLOW}Patch unsuccessful. Quitting...${NC}"
    exit
fi

# check rc.local method
if grep -Fq 'foundry' /etc/rc.local
then
    echo -e "${YELLOW}Confirmed rc.local deployment method.${NC}"
else
    echo -e "${RED}ERROR: Cannot detect rc.local launch method.${NC}"
    echo -e "${YELLOW}Patch unsuccessful. Quitting...${NC}"
    exit
fi

# terminate foundry process
foundry_pid=`echo $(ps aux | grep '[f]oundry/resources/app/main.js') | cut -d ' ' -f2`
kill -TERM ${foundry_pid} > /dev/null 2>&1 &
sleep 5s

ps -p ${foundry_pid}
if [ "$?" -eq 0 ]
then
    echo -e "${RED}ERROR: Unable to stop foundry process.${NC}"
    echo -e "${YELLOW}Patch unsuccessful. Quitting...${NC}"
    exit
fi
echo -e "${GREEN}Foundry PID ${foundry_pid} terminated.${NC}"

# remove foundry start from rc.local
sed -i "s|node /foundry/resources/app/main.js --dataPath=/foundrydata||" /etc/rc.local
sed -i "s|node /foundry/resources/app/main.js --dataPath=/foundrydata||" /etc/rc.d/rc.local

# install foundry as service
sudo wget https://raw.githubusercontent.com/cat-box/aws-foundry-ssl/master/files/foundry/foundry.service -P /etc/systemd/system
sudo chmod 644 /etc/systemd/system/foundry.service
sudo systemctl daemon-reload

# enable service
sudo systemctl enable foundry
systemctl list-unit-files | grep enabled | grep foundry >&2
foundry_systemd_status=$?
if [ ${foundry_systemd_status} -eq 0 ]
then
    # successfully enabled
    echo -e "${GREEN}Foundry service successfully enabled.${NC}"
    echo -e "${YELLOW}Restart the EC2 instance now to finish applying the patch.${NC}"
else
    # service failed to enable
    echo -e "${RED}ERROR: Unable to enable foundry service.${NC}"
    echo -e "${YELLOW}Patch unsuccessful. Quitting...${NC}"
    exit
fi