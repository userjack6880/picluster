################################################################
# check if root:
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
####################################################################
# check for network first
if curl google.com &> /dev/null
then
	echo "Online, continuing"
else
	echo "Internet Access Required, Please Connect to Network"
	exit
fi
################################################################

### make sure filessystem is expanded ####################################
#rootfs-expand

###################################################################
BASEDIR=$( dirname $0 )
#######################################################################

### reload env in case running w/out reboot: ##########################
source /etc/profile

### install docker(podman in a trenchcoat on rocky): ##################
dnf install -y docker # last time we use dnf
dnf clean all # remove cache for image size

### build container: ##################################################
cd $BASEDIR/docker
cp -r /etc/yum.repos.d . 
docker build . -t base-rocky9

### import container to ww: ###########################################
docker save base-rocky9 -o oci.tar
wwctl container import oci.tar base-rocky9
rm oci.tar
cd -

### run ww configure to bootstrap all services: #######################
wwctl configure -a

### profile setup (including dracut) ##################################
wwctl profile set --container base-rocky9 default --yes
#wwctl profile set --ipxe dracut default --yes
wwctl profile set --netdev ens3 default --yes

### add nodes #########################################################
wwctl node add boxocluster-node-[2-4] -I 10.0.0.12 --discoverable

### build containers and overlays: ####################################
wwctl container syncuser --write --build base-rocky9
wwctl overlay build

### reconfigure warewulf w/ new chagnes ###############################
wwctl configure -a

### clean up docker stuff: ############################################
podman system prune -af # for space considerations
rm -r /root/.cache