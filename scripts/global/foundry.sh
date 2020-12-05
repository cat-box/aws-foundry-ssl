#!/bin/bash

# grab variables
source /aws-foundry-ssl/variables/foundry_variables.sh
source /foundryssl/variables.sh

# install packages for foundry
sudo yum install -y nodejs
sudo yum install -y openssl-devel

# download foundry from patreon link or google drive
cd /foundry
if [[ `echo ${foundry_download_link}  | cut -d '/' -f3` == 'drive.google.com' ]]
then
    fileid=`echo ${foundry_download_link} | cut -d '/' -f6`
    sudo wget --quiet --save-cookies cookies.txt --keep-session-cookies --no-check-certificate "https://docs.google.com/uc?export=download&id=${fileid}" -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p' > confirm.txt
    sudo wget --load-cookies cookies.txt -O foundry.zip 'https://docs.google.com/uc?export=download&id='${fileid}'&confirm='$(<confirm.txt) && rm -rf cookies.txt confirm.txt
else 
    sudo wget -O foundry.zip "${foundry_download_link}"
fi

unzip -u foundry.zip
rm foundry.zip

# start foundry and add to boot
sudo cp /aws-foundry-ssl/files/foundry/foundry.service /etc/systemd/system/foundry.service
sudo chmod 644 /etc/systemd/system/foundry.service
sudo systemctl daemon-reload
sudo systemctl start foundry
sudo systemctl enable foundry
sleep 10s

# configure foundry aws json file
sudo cp /aws-foundry-ssl/files/foundry/options.json /foundrydata/Config/options.json
sudo cp /aws-foundry-ssl/files/foundry/AWS.json /foundrydata/Config/AWS.json
sudo sed -i "s|ACCESSKEYIDHERE|${access_key_id}|g" /foundrydata/Config/AWS.json
sudo sed -i "s|SECRETACCESSKEYHERE|${secret_access_key}|g" /foundrydata/Config/AWS.json
sudo sed -i "s|REGIONHERE|${region}|g" /foundrydata/Config/AWS.json

# configure foundry options file
sudo sed -i 's|"awsConfig":.*|"awsConfig": "/foundrydata/Config/AWS.json",|g' /foundrydata/Config/options.json

# allow rwx in the Data folder only for ec2-user
sudo chown ec2-user -R /foundrydata/Data
sudo chmod 755 -R /foundrydata/Data
