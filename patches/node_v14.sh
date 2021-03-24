#!/usr/bin/env bash

# This patch is intended to be used on deployments created prior to MARCH 23, 2021
# Do not use this if you deployed via template v1-7 or later
#
# NODE V14 PATCH: updates node v12.x to 14.x

# suspend foundry
systemctl stop foundry

# update existing packages
yum -y update

# unistall node add v14 to yum repository
yum remove -y 'nodesource-release*' 'nodejs*'
curl --silent --location https://rpm.nodesource.com/setup_14.x | sudo bash -
yum clean all

# install v14
yum install -y nodejs
systemctl start foundry