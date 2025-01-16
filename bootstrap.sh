#!/bin/sh

dnf install -y git
git clone https://github.com/userjack6880/picluster /opt/picluster
/opt/picluster/headnode.sh