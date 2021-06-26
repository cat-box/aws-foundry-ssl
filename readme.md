# AWS Foundry VTT Deployment with SSL Encryption

_Deploys Foundry VTT with SSL encryption in AWS using CloudFormation (Beginner Friendly)_


![GitHub](https://img.shields.io/github/license/cat-box/aws-foundry-ssl?style=flat-square)
[![Maintenance](https://img.shields.io/maintenance/yes/2021?style=flat-square)](https://github.com/cat-box/aws-foundry-ssl/wiki/Patches)
![GitHub last commit](https://img.shields.io/github/last-commit/cat-box/aws-foundry-ssl?style=flat-square&color=blue)
[![Reddit](https://img.shields.io/badge/u/auraofire-FF4500?style=flat-square&logo=reddit&logoColor=white)](https://www.reddit.com/user/auraofire)

This is an upgraded version of the [original](https://www.reddit.com/r/FoundryVTT/comments/iurf7h/i_created_a_method_to_automatically_deploy_a/) beginner friendly automated AWS deployment Lupert and I worked on. We did some tinkering and it now handles setup and creation of AWS resources, in addition to fully configuring reverse proxy and SSL certificates. 

**tldr**: You can now use audio and video in Foundry to your heart's content!

### Head to the [**wiki**](https://github.com/cat-box/aws-foundry-ssl/wiki) for full instructions, and remember: READ EVERY. SINGLE. PAGE.
---
### New Features
_New features which were added to this project will be automatically configured during setup._

1. Domain name setup to point to your foundry server. <br/>
    **e.g.** https://dnd.<yourdomain\>.com in your web browsers will show your foundry server.

2. Certificate for SSL encrypted server traffic, thereby enabling voice and video in foundry. <br/>
   **Note:** This includes automated certificate renewal so you never have to worry about certificate expirations.

3. Dynamic DNS to allow your domain to always point to the correct IP address even without a static IP address.

4. Systemd service to better handle the Foundry process. Previously, managing Foundry required a full reboot.

    It mainly provides two functions:
    1. More elegant method of starting and stopping of Foundry. 
    2. Auto restart of Foundry in an event of crash.

    A [patch](https://github.com/cat-box/aws-foundry-ssl/wiki/Patches#rclocal-to-systemd-service) is available to those who deployed using earlier versions of this project. 

5. Text/Email uptime notification system via AWS SNS as a cost-saving measure. <br />
    **i.e.** receive a notification if your server has been active for over 24 hours.