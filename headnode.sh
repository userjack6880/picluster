################################################################
# check if root:
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
################################################################
# check for network first
if ping -c 1 72.14.177.74 &> /dev/null
then
	echo "Online, continuing"
else
	echo "Internet Access Required, Please Connect to Network"
	exit
fi
################################################################

##########################################################################
BASEDIR=$( dirname $0 )
##########################################################################

# grow root FS to avoid running out of space during installation:
rootfs-expand

### install necessary packages and update: ###
dnf config-manager --set-enabled crb
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
dnf update -y # necessary. sshd breaks w/out it
dnf install -y vim pdsh pdsh-rcmd-ssh pdsh-mod-genders python3-distutils-extra python3-devel git tar


### set ssh as default pdsh remote console ###
echo 'export PDSH_RCMD_DEFAULT=ssh' > /etc/profile.d/pdsh.sh

### add apps dir: ###
mkdir -p /apps/pkgs

### make apps writable: ###
chmod g+w /apps

### change rocky to admin as per docs: ###
sed -i 's/rocky/admin/g' /etc/passwd /etc/group /etc/shadow
# sed is used since usage of usermod requires no running processes belonging to the user
usermod -p '$5$cOTJhkxlC4$kEFPIJaKPriv16lcwNBsS4dVMT1sC/a9vFPNlZDHug1' admin
mv /home/{rocky,admin}

### copy public/private keys: ##
mkdir /home/admin/.ssh
cp $BASEDIR/configs/admin_privkey /home/admin/.ssh/id_rsa
cp $BASEDIR/configs/admin_pubkey /home/admin/.ssh/authorized_keys
chown -R admin:admin /home/admin/.ssh
chmod 600 /home/admin/.ssh/id_rsa
chmod 644 /home/admin/.ssh/authorized_keys
### make ssh to root possible: ###
mkdir /root/.ssh # already exists on rocky. possibly remove
cp /home/admin/.ssh/* /root/.ssh/

### create additional users: ###
useradd -m -g users -p '$5$cOTJhkxlC4$kEFPIJaKPriv16lcwNBsS4dVMT1sC/a9vFPNlZDHug1' -s /bin/bash -u 1001 user
#        ^- creates home dir automatically w/ contents of /etc/skel

### copy needed configs: ###
cp $BASEDIR/configs/hosts /etc/hosts
cp $BASEDIR/configs/sudoers /etc/sudoers
cp $BASEDIR/configs/genders /etc/genders
mkdir /apps/configs
cp $BASEDIR/configs/chrony-client.conf /apps/configs

### set hostname: ###
echo "pi-hpc-head01" > /etc/hostname

### Setup Networking as per docs: ###
cp $BASEDIR/configs/head-node.nmconnection /etc/NetworkManager/system-connections/
chown root:root /etc/NetworkManager/system-connections/head-node.nmconnection
chmod 600 /etc/NetworkManager/system-connections/head-node.nmconnection

### wait for ^C if reboot isn't wanted: ###
echo "done!"
sleep 10

### reboot: ###
reboot now
