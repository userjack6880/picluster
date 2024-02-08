if [ -z $1 ]; then
  echo "please provide range xx-xx";
  exit 1;
fi;

# install mariadb

dpkg -i /apps/pkgs/mariadb-server/*.deb

# install and configure slurm on head node

dpkg -i /apps/pkgs/slurm-head/*.deb
cp /apps/prep-scripts/configs/slurm.conf /etc/slurm/slurm.conf
cp /apps/prep-scripts/configs/slurmdbd.conf /etc/slurm/slurmdbd.conf
chown slurm:slurm /etc/slurm/slurmdbd.conf
chmod 600 /etc/slurm/slurmdbd.conf

# install and configure slurm on compute nodes

su -c "pdsh -w pi-hpc-compute[$1] sudo dpkg -i /apps/pkgs/slurm-compute/*.deb" admin
su -c "pdsh -w pi-hpc-compute[$1] sudo cp /apps/prep-scripts/configs/slurm.conf /etc/slurm/slurm.conf" admin

# copy munge key to nodes

cp /etc/munge/munge.key /shared/munge.key
su -c "pdsh -w pi-hpc-compute[$1] sudo cp /shared/munge.key /etc/munge/munge.key" admin
su -c "pdsh -w pi-hpc-compute[$1] sudo chwon munge:munge /etc/munge/munge.key" admin
su -c "pdsh -w pi-hpc-compute[$1] sudo chwon 600 /etc/munge/munge.key" admin
su -c "pdsh -w pi-hpc-compute[$1] sudo systemctl restart munge" admin

# setup slurm database

mysql --execute="create database slurm_acct_db;"
mysql --execute="create user 'slurm'@'localhost';"
mysql --execute="set password for 'slurm'@'localhost' = password('tuxcluster');"
mysql --execute="grant all privileges on slurm_acct_db.* to 'slurm'@'localhost';"

# start slurm

systemctl enable slurmd systemctld slurmdbd
systemctl start slurmd systemctld slurmdbd

# ensure cluster is added

sudo sacctmgr -i add cluster pi-hpc-cluster

# start slurm on compute nodes

su -c "pdsh -w pi-hpc-compute[$1] sudo systemctl enable slurmd" admin
su -c "pdsh -w pi-hpc-compute[$1] sudo systemctl start slurmd" admin

# output result and test

sinfo -N -l
srun --nodes=4 hostname
