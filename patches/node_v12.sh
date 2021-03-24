#!/usr/bin/env bash

# This patch is intended to be used on deployments created prior to MARCH 23, 2021
# Only use this if you applied the Node v14.x patch and are experiencing stability issues
# Do not use this if you deployed via template v1-7 or later
#
# NODE V12 REVERT: reverts node v14.x to v12.x

# suspend foundry
systemctl stop foundry

# update existing packages
yum -y update

# unistall node add v12 to yum repository
yum remove -y 'nodesource-release*' 'nodejs*'
curl --silent --location https://rpm.nodesource.com/setup_12.x | sudo bash -
yum clean all

# install v12
yum install -y nodejs
systemctl start foundry