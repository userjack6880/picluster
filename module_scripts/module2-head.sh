if [ -z $1 ]; then
  echo "please provide range xx-xx";
  exit 1;
fi;

# stop and uninstall systemd-timesyncd

systemctl stop systemd-timesyncd
apt-get -y remove systemd-timesyncd

# install chrony

dpkg -i /apps/pkgs/chrony*.deb

# stop chrony and install new config

systemctl stop chrony
cp /apps/prep-scripts/configs/chrony-server.conf /etc/chrony/chrony.conf
systemctl start chrony

# and time to do it on the compute nodes

su -c "pdsh -w pi-hpc-compute[$1] sudo systemctl stop systemd-timesyncd" admin
su -c "pdsh -w pi-hpc-compute[$1] sudo apt-get -y remove systemd-timesyncd" admin
su -c "pdsh -w pi-hpc-compute[$1] sudo dpkg -i /apps/pkgs/chrony*arm64.deb" admin
su -c "pdsh -w pi-hpc-compute[$1] sudo systemctl stop chrony" admin
su -c "pdsh -w pi-hpc-compute[$1] sudo cp /apps/configs/chrony-client.conf /etc/chrony/chrony.conf" admin
su -c "pdsh -w pi-hpc-compute[$1] sudo systemctl start chrony" admin

# now prompt to run timedatectl

echo "run timedatectl set-time to set current time"
