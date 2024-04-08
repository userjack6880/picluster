if [ -z $1 ]; then
  echo "please provide range xx-xx"
  exit 1
else
  # since you so kindly provided the node numbers,
  # lets update the /etc/genders file accordingly
  sed -ri "s/compute\[..-..\]/compute[$1]/" /etc/genders 
fi

if [ -z $2 ]
then
  echo "Storage range not provided, assuming no storage nodes"
  sed -ri "s/^(pi-hpc-storage.*)/#\1/" /etc/genders 
else
  sed -ri "s/^#(pi-hpc-storage.*)/\1/" /etc/genders
  sed -ri "s/storage\[..-..\]/storage[$1]/" /etc/genders 
fi

# install open mpi

dpkg -i /apps/pkgs/openmpi/*.deb

# install and configure python

gzip -d /apps/src/mpi4py/mpi4py-3.1.5.tar.gz
tar -xf /apps/src/mpi4py/mpi4py-3.1.5.tar
python /apps/src/mpi4py/mpi4py-3.1.5/setup.py build
python /apps/src/mpi4py/mpi4py-3.1.5/setup.py install

# install and configure mpi and python on compute nodes

su -c "pdsh -w pi-hpc-compute[$1] sudo dpkg -i /apps/pkgs/openmpi/*.deb" admin
su -c "pdsh -w pi-hpc-compute[$1] sudo /apps/src/mpi4py/mpi4py-3.1.5/setup.py install" admin