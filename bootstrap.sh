#!/bin/sh

### Check for root: ##############################################
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

### install git and clone repo: ##################################
dnf install -y git
git clone https://github.com/userjack6880/picluster /opt/picluster

### run creation script: #########################################
/opt/picluster/headnode.sh