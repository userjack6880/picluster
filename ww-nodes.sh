################################################################
# check if root:
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
####################################################################
# check for network first
if ping -c 1 72.14.177.74 &> /dev/null
then
	echo "Online, continuing"
else
	echo "Internet Access Required, Please Connect to Network"
	exit
fi
################################################################

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
docker build . -t base-rocky9-dracut

### import container to ww: ###########################################
docker save base-rocky9-dracut -o oci.tar
wwctl container import oci.tar base-rocky9-dracut
rm oci.tar
cd -

### run ww configure to bootstrap all services: #######################
wwctl configure -a

### profile setup (including dracut) ##################################
wwctl profile set --container base-rocky9-dracut default --yes
wwctl profile set --ipxe dracut default --yes
wwctl profile set --netdev eth0 default --yes

### add nodes #########################################################
wwctl node add pi-hpc-compute[01-04] -I 10.0.0.11 --discoverable

### build containers and overlays: ####################################
wwctl container syncuser --write --build base-rocky9-dracut
wwctl overlay build

### clean up docker stuff: ############################################
podman system prune -af # for space considerations
rm -r /root/.cache