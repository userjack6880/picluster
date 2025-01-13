################################################################################
BASEDIR=$( dirname $0 )
################################################################################

##################### container import ############################
wwctl container import docker://ghcr.io/warewulf/warewulf-rockylinux:9 rockylinux-9-dracut
wwctl container syncuser --write rockylinux-9-dracut

##################### container dracut setup ######################
wwctl container exec rockylinux-9-dracut --bind /opt:/opt /bin/bash -c "\
dnf update -y;
dnf install -y /opt/warewulf/warewulf-dracut.rpm;
dracut --force --no-hostonly --add wwinit --regenerate-all;
exit

################ profile setup (including dracut) #################
wwctl profile set --container rockylinux-9-dracut default
wwctl profile set --ipxe dracut default
wwctl profile set --netdev eth0 default

##################### add nodes ###################################
wwctl node add pi-hpc-compute-[01-04] -I 10.0.0.11 --discoverable