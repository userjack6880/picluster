# check for network first
if ping -c 1 72.14.177.74 &> /dev/null
then

	# update locales (eww, purge the british)
	perl -pi -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
	sudo sed -ri 's/en_GB.UTF-8 UTF-8/# en_GB.UTF-8 UTF-8/' /etc/locale.gen
	sudo sed -ri 's/LANG=en_GB.UTF-8/LANG=en_US.UTF-8/' /etc/default/locale

	# update repos

	apt-get update
	apt-get -y upgrade
	apt-get -y install vim pdsh python3-distutils python3-dev

	# configure pdsh
	echo "ssh" > /etc/pdsh/rcmd_default

	# move admin home directory to /var/tmp

	cp -r /home/admin /var/tmp
	rm -r /home/admin

	# create mount points
	mkdir /mnt/apps

	# if formatting disks, do it here
	if [ "$1" == "format" ]; then
		fdisk /dev/sda
		mke2fs -t ext4 /dev/sda1
		mke2fs -t ext4 /dev/sda2
	fi

	# add to fstab
	blkid | grep /dev/sda1 | awk '{ print $5 "\t/home\text4\tdefaults\t0\t2" }' >> -a /etc/fstab
	blkid | grep /dev/sda2 | awk '{ print $5 "\t/mnt/apps\text4\tdefaults\t0\t2" }' >> -a /etc/fstab

	# mount all
	mount -a

	# create symlinks

	ln -s /mnt/apps /apps

	# copy admin home back to the new /home

	cp -r /var/tmp/admin /home
	rm -r /var/tmp/admin

	# fix permissions

	chown -R admin:admin /home/admin
	chown -R root:admin /mnt/apps

	chmod g+w /mnt/apps

	# copy public/private keys
	mkdir /home/admin/.ssh
	cp ./configs/admin_privkey /home/admin/.ssh/id_rsa
	cp ./configs/admin_pubkey /home/admin/.ssh/authorized_keys
	chown -R admin:admin /home/admin/.ssh
	chmod 600 /home/admin/.ssh/id_rsa
	chmod 644 /home/admin/.ssh/authorized_keys

	# create additional users
	useradd -d /home/user -g users -M -p '$5$cOTJhkxlC4$kEFPIJaKPriv16lcwNBsS4dVMT1sC/a9vFPNlZDHug1' -s /bin/bash -u 1001 user
	mkdir /home/user
	cp /home/admin/.bashrc /home/user/.bashrc
	cp /home/admin/.profile /home/user/.profile
	chown -R user:users /home/user

	# download needed packages to /apps/pkgs
	mkdir /mnt/apps/pkgs
	rm -r /mnt/apps/pkgs/*.deb
	rm /var/cache/apt/archives/*.deb
	apt-get -y --download-only install nfs-kernel-server chrony
	cp /var/cache/apt/archives/*.deb /mnt/apps/pkgs

	mkdir /mnt/apps/pkgs/isc-dhcp-server
	rm /var/cache/apt/archives/*.deb
	apt-get -y --download-only install isc-dhcp-server
	cp /var/cache/apt/archives/*.deb /mnt/apps/pkgs/isc-dhcp-server

	mkdir /mnt/apps/pkgs/mariadb-server
	rm /var/cache/apt/archives/*.deb
	apt-get -y --download-only install mariadb-server gawk
	cp /var/cache/apt/archives/*.deb /mnt/apps/pkgs/mariadb-server

	mkdir /mnt/apps/pkgs/slurm-head
	rm /var/cache/apt/archives/*.deb
	apt-get -y --download-only install slurm-wlm slurmdbd slurm-client 
	cp /var/cache/apt/archives/*.deb /mnt/apps/pkgs/slurm-head

	mkdir /mnt/apps/pkgs/slurm-compute
	rm /var/cache/apt/archives/*.deb
	apt-get -y --download-only install slurmd slurm-client
	cp /var/cache/apt/archives/*.deb /mnt/apps/pkgs/slurm-compute

	mkdir /mnt/apps/pkgs/openmpi
	rm /var/cache/apt/archives/*.deb
	apt-get -y --download-only install openmpi-bin openmpi-common libopenmpi-dev libopenmpi3 libltdl7
	cp /var/cache/apt/archives/*.deb /mnt/apps/pkgs/openmpi

	mkdir /mnt/apps/pkgs/glusterfs-server
	rm /var/cache/apt/archives/*.deb
	apt-get -y --download-only install glusterfs-server
	cp /var/cache/apt/archives/*.deb /mnt/apps/pkgs/glusterfs-server

	mkdir /mnt/apps/pkgs/glusterfs-client
	rm /var/cache/apt/archives/*.deb
	apt-get -y --download-only install glusterfs-client
	cp /var/cache/apt/archives/*.deb /mnt/apps/pkgs/glusterfs-client

	# mkdir /mnt/apps/pkgs/mpich
	# rm /var/cache/apt/archives/*.deb
	# apt-get -y --download-only install mpich
	# cp /var/cache/apt/archives/*.deb /mnt/apps/pkgs/mpich

	mkdir /mnt/apps/src
	mkdir /mnt/apps/src/mpi4py
	wget https://github.com/mpi4py/mpi4py/releases/download/3.1.5/mpi4py-3.1.5.tar.gz -P /apps/src/mpi4py
	chown -R root:users /apps/src/mpi4py
	chmod -R 770 /apps/src/mpi4py

	# make a copy of the files on this drive and save in apps/scripts and make it run only by root
	cp -r . /mnt/apps/prep-scripts
	chown -R root:root /mnt/apps/prep-scripts
	chmod -R 700 /mnt/apps/prep-scripts

	# copy /etc/hosts
	cp ./configs/hosts /etc/hosts

	# copy /etc/sudoers
	cp ./configs/sudoers /etc/sudoers

	# copy dhcpcd.conf
	cp ./configs/dhcpcd-head.conf /etc/dhcpcd.conf
	chown root:netdev /etc/dhcpcd.conf
	chmod 664 /etc/dhcpcd.conf

	# copy genders file
	cp ./configs/genders /etc/genders

	# copy chrony.conf to an accessible location
	mkdir /mnt/apps/configs
	cp ./configs/chrony-client.conf /mnt/apps/configs

	# copy chrony.conf to an accessible location
	cp ./configs/dhcpd.conf /mnt/apps/configs

	# wait
	echo "done!"
	sleep 10

	# reboot
	reboot now

else
	echo "Internet Access Required, Please Connect to Network"
fi
