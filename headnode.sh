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

# grow root FS to avoid running out of space during installation:
rootfs-expand

### install necessary packages and update: ###
dnf config-manager --set-enabled crb
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
dnf update -y # necessary. sshd breaks w/out it
dnf install -y vim pdsh pdsh-rcmd-ssh pdsh-mod-genders python3-distutils-extra python3-devel git


### set ssh as default pdsh remote console ###
echo 'export PDSH_RCMD_DEFAULT=ssh' > /etc/profile.d/pdsh.sh

### add apps dir: ###
mkdir /apps

### make apps writable: ###
chmod g+w /apps

### copy public/private keys: ##
mkdir /home/admin/.ssh
cp ./configs/admin_privkey /home/admin/.ssh/id_rsa
cp ./configs/admin_pubkey /home/admin/.ssh/authorized_keys
chown -R admin:admin /home/admin/.ssh
chmod 600 /home/admin/.ssh/id_rsa
chmod 644 /home/admin/.ssh/authorized_keys
### make ssh to root possible: ###
mkdir /root/.ssh
cp /home/rocky/.ssh/* /root/.ssh/

### change rocky to admin as per docs: ###
sed -i 's/rocky/admin/g' /etc/passwd /etc/group /etc/shadow
# sed is used since usage of usermod requires no running processes belonging to the user
usermod -p '$5$cOTJhkxlC4$kEFPIJaKPriv16lcwNBsS4dVMT1sC/a9vFPNlZDHug1' admin
mv /home/{rocky,admin}

### create additional users: ###
useradd -m -g users -p '$5$cOTJhkxlC4$kEFPIJaKPriv16lcwNBsS4dVMT1sC/a9vFPNlZDHug1' -s /bin/bash -u 1001 user
#        ^- creates home dir automatically w/ contents of /etc/skel

### Download rpms for packages students will install: ###
# this is actually much easier to do in rocky 
# source: https://superuser.com/questions/1244789/is-it-possible-to-download-rpm-files-in-fedora-for-offline-usage-see-descripti
dnf install -y --downloadonly --downloaddir=/apps/pkgs/chrony chrony
dnf install -y --downloadonly --downloaddir=/apps/pkgs/mariadb-server mariadb-server gawk
dnf install -y --downloadonly --downloaddir=/apps/pkgs/slurm-head slurm{,-slurmctld,-slurmdbd,-perlapi} munge
dnf install -y --downloadonly --downloaddir=/apps/pkgs/slurm-compute slurm-slurmd munge
dnf install -y --downloadonly --downloaddir=/apps/pkgs/openmpi openmpi-devel
dnf install -y --downloadonly --downloaddir=/apps/pkgs/glusterfs-server glusterfs
dnf install -y --downloadonly --downloaddir=/apps/pkgs/glusterfs-client glusterfs-fuse

### Download source for OpenMPI: ###
mkdir /apps/src/openmpi
curl -L https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-5.0.6.tar.bz2 -o /apps/src/openmpi/openmpi-latest.tar.bz2

### Clone source for mpi4pi: ###
mkdir -p /mnt/apps/src/mpi4py
curl -L https://github.com/mpi4py/mpi4py/releases/download/3.1.5/mpi4py-3.1.5.tar.gz | tar xz -C /apps/src/mpi4py
chown -R root:users /apps/src/mpi4py
chmod -R 770 /apps/src/mpi4py

### copy needed configs: ###
cp ./configs/hosts /etc/hosts
cp ./configs/sudoers /etc/sudoers
cp ./configs/genders /etc/genders
mkdir /mnt/apps/configs
cp ./configs/chrony-client.conf /mnt/apps/configs

### set hostname: ###
echo "pi-hpc-head01" > /etc/hostname

### Setup Networking as per docs: ###
cp ./configs/head-node.nmconnection /etc/NetworkManager/system-connections/
chown root:root /etc/NetworkManager/system-connections/head-node.nmconnection
chmod 600 /etc/NetworkManager/system-connections/head-node.nmconnection

### wait for ^C if reboot isn't wanted: ###
echo "done!"
sleep 10

### reboot: ###
reboot now
