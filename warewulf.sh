################################################################
# check if root:
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
###########################################################################
# check for network first
if ping -c 1 72.14.177.74 &> /dev/null
then
	echo "Online, continuing"
else
	echo "Internet Access Required, Please Connect to Network"
	exit
fi
################################################################

###############################################################
BASEDIR=$( dirname $0 )
##########################################################################

### install services required for warewulf: ##############################
dnf -y --setopt=install_weak_deps=False --nodocs install dhcp-server tftp-server nfs-utils golang unzip ipxe-bootimgs-aarch64

### disable firewalld: ###################################################
systemctl disable --now firewalld

### clone and build warewulf: ############################################
mkdir /opt/warewulf
git clone https://github.com/warewulf/warewulf.git /opt/warewulf/src
cd /opt/warewulf/src
git checkout v4.5.8
git apply $BASEDIR/configs/ww-picluster.patch
make clean defaults PREFIX=/opt/warewulf
make all
make install
go clean -modcache

### point warewulf to ipxe images: #######################################
sed -i 's/\/opt\/warewulf\/share\/ipxe/\/usr\/share\/ipxe/' /opt/warewulf/etc/warewulf/warewulf.conf

### add warewulf to path: ################################################
echo "export PATH=$PATH:/opt/warewulf/bin" > /etc/profile.d/warewulf.sh

### add raspi's special uefi pxeboot: ####################################
curl -o rpi-uefi.zip -L https://github.com/pftf/RPi4/releases/download/v1.38/RPi4_UEFI_Firmware_v1.38.zip
unzip rpi-uefi.zip -d /var/lib/tftpboot/

### return to previous location: #########################################
cd -

systemctl enable dhcpd tftp warewulfd

### reboot ###############################################################
reboot