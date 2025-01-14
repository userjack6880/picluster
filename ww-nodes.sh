#######################################################################
BASEDIR=$( dirname $0 )
#######################################################################

### reload env in case running w/out reboot: ##########################
source /etc/profile

### install docker(podman in a trenchcoat on rocky): ##################
dnf install -y docker # last time we use dnf
dnf clean all # remove cache for image size

### build container: ##################################################
cd $BASEDIR/docker
docker build . -t base-rocky9-dracut
cd -

### import container to ww: ###########################################
# we'll store the intermediate file in a tmpfs
mount -t tmpfs tmpfs /mnt 
docker save base-rocky9-dracut -o /mnt/oci.tar
wwctl container import /mnt/oci.tar base-rocky9-dracut
umount /mnt

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