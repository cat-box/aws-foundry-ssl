#!/usr/bin/env bash

# This patch is intended to be used on deployments created prior to MARCH 23, 2021
# Do not use this if you deployed via template v1-7 or later
#
# NODE V14 PATCH: updates node v12.x to 14.x

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

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
            echo -e "${YELLOW}Patch unsuccessful. Quitting...${NC}"
            exit
        fi
        echo -e "${GREEN}Foundry service stopped.${NC}"
        ;;
    service_error)
        # service deployment disabled
        echo -e "${RED}ERROR_DEPLOYMENT: Detected service deployment but was not enabled.${NC}"
        echo -e "${YELLOW}Patch unsuccessful. Quitting...${NC}"
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
            echo -e "${YELLOW}Patch unsuccessful. Quitting...${NC}"
            exit
        fi
        echo -e "${GREEN}Foundry PID ${foundry_pid} terminated.${NC}"
        ;;
    neither)
        # cannot detect deployment method
        echo -e "${RED}ERROR_STOP: Unable to detect systemd or rc.local deployment method.${NC}"
        echo -e "${YELLOW}Patch unsuccessful. Quitting...${NC}"
        exit
        ;;
esac

# update existing packages
yum -y update

# unistall node add v14 to yum repository
yum remove -y 'nodesource-release*' 'nodejs*'
curl --silent --location https://rpm.nodesource.com/setup_14.x | sudo bash -
yum clean all

# install v14
yum install -y nodejs

# restart foundry
case "$(check_deployment)" in
    service)
        # service deployment
        systemctl start foundry
        if systemctl is-active --quiet foundry
        then
            echo -e "${GREEN}Patch successfully finished.${NC}"
            echo -e "${YELLOW}If you are unable to access foundry, please wait 10 minutes before trying agin. If still unsuccessful, restart your EC2 Instance.${NC}"
        else
            echo -e "${RED}ERROR_START: Unable to restart foundry after patch.${NC}"
            echo -e "${YELLOW}Patch unsuccessful. Quitting...${NC}"
            exit
        fi
        ;;
    service_error)
        # service deployment disabled
        echo -e "${RED}ERROR_DEPLOYMENT: Detected service deployment but was not enabled.${NC}"
        echo -e "${YELLOW}Patch unsuccessful. Quitting...${NC}"
        exit
        ;;
    rc.local)
        # rc.local deployment
        echo -e "${GREEN}Patch finished. Please manually restart EC2 instance to finalize patch.${NC}"
        echo -e "${YELLOW}Quitting...${NC}"
        ;;
    neither)
        # cannot detect deployment method
        echo -e "${RED}ERROR_START: Unable to detect systemd or rc.local deployment method.${NC}"
        echo -e "${YELLOW}Patch unsuccessful. Quitting...${NC}"
        exit
        ;;
esac