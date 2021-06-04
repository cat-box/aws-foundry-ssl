#!/bin/bash

# This script is intended to be used on all deployments
#
# PREREQUISITE CHECKLIST:
# [ ] Node.js v14 or later is installed
# [ ] /foundrydata folder is backed up
#
# FOUNDRY UPDATE SCRIPT: updates FoundryVTT

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

# check if foundry download link was supplied
if [ -z "$1" ]
then
    echo -e "${RED}ERROR: Foundry download link not supplied."
    echo -e "${YELLOW}Update unsuccessful. Quitting...${NC}"
    exit
fi

# check if root
if [ "$EUID" -ne 0 ]
then 
    echo -e "${RED}ERROR: Please run as root. (sudo su)${NC}"
    echo -e "${YELLOW}Update unsuccessful. Quitting...${NC}"
    exit
fi

# check node v14+
node_version=`echo $(node -v) | cut -d '.' -f1 | cut -d 'v' -f2`
if [ $node_version -ge 14 ]
then
    echo -e "${GREEN}Node.js confirmed running v14 or greater${NC}"
else
    echo -e "${RED}ERROR: Foundry VTT 0.8 requires Node.js version 14 or greater."
    echo -e "${YELLOW}Please visit \e[4mhttps://github.com/cat-box/aws-foundry-ssl/wiki/Patches${YELLOW} to update Node.js first.${NC}"
    echo -e "${YELLOW}Update unsuccessful. Quitting...${NC}"
    exit
fi

# check deployment method
check_deployment() {
    FILE=/etc/systemd/system/foundry.service
    if [ -f $FILE ]
    then
        # service deployment
        systemctl list-unit-files | grep enabled | grep foundry >&2
        foundry_systemd_status=$?
        if [ ${foundry_systemd_status} -eq 0 ]
        then
            echo "service"
        else
            echo "service_error"
        fi
    elif grep -Fq 'foundry' /etc/rc.local
    then
        # rc.local deployment
        echo "rc.local"
    else
        # cannot detect deployment method
        echo "neither"
    fi
} 

# suspend foundry
case "$(check_deployment)" in
    service)
        # service deployment
        systemctl stop foundry
        if systemctl is-active --quiet foundry
        then
            echo -e "${RED}ERROR_STOP: Unable to stop foundry service.${NC}"
            echo -e "${YELLOW}Update unsuccessful. Quitting...${NC}"
            exit
        fi
        echo -e "${GREEN}Foundry service stopped.${NC}"
        ;;
    service_error)
        # service deployment disabled
        echo -e "${RED}ERROR_DEPLOYMENT: Detected service deployment but was not enabled.${NC}"
        echo -e "${YELLOW}Update unsuccessful. Quitting...${NC}"
        exit
        ;;
    rc.local)
        # rc.local deployment
        foundry_pid=`echo $(ps aux | grep '[f]oundry/resources/app/main.js') | cut -d ' ' -f2`
        kill -TERM ${foundry_pid} > /dev/null 2>&1 &

        ps -p ${foundry_pid}
        if [ "$?" -eq 0 ]
        then
            echo -e "${RED}ERROR: Unable to stop foundry process.${NC}"
            echo -e "${YELLOW}Update unsuccessful. Quitting...${NC}"
            exit
        fi
        echo -e "${GREEN}Foundry PID ${foundry_pid} terminated.${NC}"
        ;;
    neither)
        # cannot detect deployment method
        echo -e "${RED}ERROR_STOP: Unable to detect systemd or rc.local deployment method.${NC}"
        echo -e "${YELLOW}Update unsuccessful. Quitting...${NC}"
        exit
        ;;
esac

# install 0.8x
mv /foundry /foundryold_$(date +"%Y-%m-%d_%H-%M")
mkdir /foundry
foundry_download_link=$1
if [[ `echo ${foundry_download_link}  | cut -d '/' -f3` == 'drive.google.com' ]]
then
    fileid=`echo ${foundry_download_link} | cut -d '/' -f6`
    sudo wget --quiet --save-cookies cookies.txt --keep-session-cookies --no-check-certificate "https://docs.google.com/uc?export=download&id=${fileid}" -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p' > confirm.txt
    sudo wget --load-cookies cookies.txt -O foundry.zip 'https://docs.google.com/uc?export=download&id='${fileid}'&confirm='$(<confirm.txt) && rm -rf cookies.txt confirm.txt
else 
    sudo wget -O foundry.zip "${foundry_download_link}"
fi
unzip -qu foundry.zip -d /foundry
rm foundry.zip

# restart foundry
case "$(check_deployment)" in
    service)
        # service deployment
        systemctl start foundry
        if systemctl is-active --quiet foundry
        then
            echo -e "${GREEN}Update successfully finished.${NC}"
            echo -e "${YELLOW}If you are unable to access foundry, please wait 10 minutes before trying agin. If still unsuccessful, restart your EC2 Instance.${NC}"
        else
            echo -e "${RED}ERROR_START: Unable to restart foundry after update.${NC}"
            echo -e "${YELLOW}Update unsuccessful. Quitting...${NC}"
            exit
        fi
        ;;
    service_error)
        # service deployment disabled
        echo -e "${RED}ERROR_DEPLOYMENT: Detected service deployment but was not enabled.${NC}"
        echo -e "${YELLOW}Update unsuccessful. Quitting...${NC}"
        exit
        ;;
    rc.local)
        # rc.local deployment
        echo -e "${GREEN}Update script finished. Please manually restart EC2 instance to finalize update.${NC}"
        echo -e "${YELLOW}Quitting...${NC}"
        ;;
    neither)
        # cannot detect deployment method
        echo -e "${RED}ERROR_START: Unable to detect systemd or rc.local deployment method.${NC}"
        echo -e "${YELLOW}Update unsuccessful. Quitting...${NC}"
        exit
        ;;
esac