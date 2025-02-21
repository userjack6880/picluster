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

### Download rpms for packages students will install: ###
# this is actually much easier to do in rocky 
# source: https://superuser.com/questions/1244789/is-it-possible-to-download-rpm-files-in-fedora-for-offline-usage-see-descripti
dnf install -y --downloadonly --downloaddir=/apps/pkgs/mariadb-server mariadb-server gawk
dnf install -y --downloadonly --downloaddir=/apps/pkgs/slurm-head slurm{,-slurmctld,-slurmdbd,-perlapi} munge
dnf install -y --downloadonly --downloaddir=/apps/pkgs/openmpi openmpi-devel
dnf install -y --downloadonly --downloaddir=/apps/pkgs/glusterfs-server glusterfs
dnf install -y --downloadonly --downloaddir=/apps/pkgs/ipa-server ipa-server dnsmasq --setopt=install_weak_deps=False
dnf install -y --downloadonly --downloaddir=/apps/pkgs/ipa-client ipa-client --setopt=install_weak_deps=False
# these have been moved to inside the container for dependency acquisition
# dnf install -y --downloadonly --downloaddir=/apps/pkgs/slurm-compute slurm-slurmd munge
# dnf install -y --downloadonly --downloaddir=/apps/pkgs/glusterfs-client glusterfs-fuse

### Download source for OpenMPI: ###
mkdir -p /apps/src/openmpi
curl -L https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-5.0.7.tar.gz -o /apps/src/openmpi/openmpi-latest.tar.gz

### Clone source for mpi4pi: ###
mkdir -p /apps/src/mpi4py
curl -L https://github.com/mpi4py/mpi4py/releases/download/3.1.5/mpi4py-3.1.5.tar.gz | tar xz -C /apps/src/mpi4py
chown -R root:users /apps/src/mpi4py
chmod -R 770 /apps/src/mpi4py
