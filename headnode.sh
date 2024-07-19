# check for network first
if ping -c 1 5.161.201.170 &> /dev/null
then

	# update locales
	perl -pi -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen

	# update repos

	apt update
	apt upgrade -y
	apt -y install vim pdsh python3-distutils python3-dev

	# configure pdsh
	echo "ssh" > /etc/pdsh/rcmd_default

	# move admin home directory to /var/tmp

	cp -r /home/admin /var/tmp
	rm -r /home/admin

	# create mount points
	mkdir -v /mnt/apps

	# if formatting disks, do it here
	if [ "$1" == "format" ]; then
		fdisk /dev/sda
		mke2fs -t ext4 /dev/sda1
		mke2fs -t ext4 /dev/sda2
	fi

	# add to fstab
	blkid | grep /dev/sda1 | awk '{ print $5 "\t/home\text4\tdefaults\t0\t2" }' >> /etc/fstab
	blkid | grep /dev/sda2 | awk '{ print $5 "\t/mnt/apps\text4\tdefaults\t0\t2" }' >> /etc/fstab
  echo "fstab updated";

	# mount all
  echo "mounting partitions";
	mount -a

	# create symlinks

	ln -sv /mnt/apps /apps

	# copy admin home back to the new /home

	cp -vr /var/tmp/admin /home
	rm -vr /var/tmp/admin

	# fix permissions

	chown -vR admin:admin /home/admin
	chown -vR root:admin /mnt/apps

	chmod -v g+w /mnt/apps

	# copy public/private keys
	mkdir -v /home/admin/.ssh
	cp -v /mnt/usb/configs/admin_privkey /home/admin/.ssh/id_rsa
	cp -v /mnt/usb/configs/admin_pubkey /home/admin/.ssh/authorized_keys
	chown -vR admin:admin /home/admin/.ssh
	chmod -v 600 /home/admin/.ssh/id_rsa
	chmod -v 644 /home/admin/.ssh/authorized_keys

	# create additional users
	useradd -d /home/user -g users -M -p '$5$cOTJhkxlC4$kEFPIJaKPriv16lcwNBsS4dVMT1sC/a9vFPNlZDHug1' -s /bin/bash -u 1001 user
	mkdir -v /home/user
	cp -v /home/admin/.bashrc /home/user/.bashrc
	cp -v /home/admin/.profile /home/user/.profile
	chown -vR user:users /home/user

	# download needed packages to /apps/pkgs
	mkdir -v /mnt/apps/pkgs
	rm -v /var/cache/apt/archives/*.deb
	apt -y --download-only install nfs-kernel-server chrony
	cp -v /var/cache/apt/archives/*.deb /mnt/apps/pkgs

	mkdir -v /mnt/apps/pkgs/mariadb-server
	rm -v /var/cache/apt/archives/*.deb
	apt -y --download-only install mariadb-server gawk
	cp -v /var/cache/apt/archives/*.deb /mnt/apps/pkgs/mariadb-server

	mkdir -v /mnt/apps/pkgs/slurm-head
	rm -v /var/cache/apt/archives/*.deb
	apt -y --download-only install slurm-wlm slurmdbd slurm-client 
	cp -v /var/cache/apt/archives/*.deb /mnt/apps/pkgs/slurm-head

	mkdir -v /mnt/apps/pkgs/slurm-compute
	rm -v /var/cache/apt/archives/*.deb
	apt -y --download-only install slurmd slurm-client
	cp -v /var/cache/apt/archives/*.deb /mnt/apps/pkgs/slurm-compute

	mkdir -v /mnt/apps/pkgs/openmpi
	rm -v /var/cache/apt/archives/*.deb
	apt -y --download-only install openmpi-bin openmpi-common libopenmpi-dev libopenmpi3 libltdl7
	cp -v /var/cache/apt/archives/*.deb /mnt/apps/pkgs/openmpi

	mkdir -v /mnt/apps/pkgs/glusterfs-server
	rm -v /var/cache/apt/archives/*.deb
	apt -y --download-only install glusterfs-server
	cp -v /var/cache/apt/archives/*.deb /mnt/apps/pkgs/glusterfs-server

	mkdir -v /mnt/apps/pkgs/glusterfs-client
	rm -v /var/cache/apt/archives/*.deb
	apt -y --download-only install glusterfs-client
	cp -v /var/cache/apt/archives/*.deb /mnt/apps/pkgs/glusterfs-client

	# mkdir /mnt/apps/pkgs/mpich
	# rm /var/cache/apt/archives/*.deb
	# apt-get -y --download-only install mpich
	# cp /var/cache/apt/archives/*.deb /mnt/apps/pkgs/mpich

	mkdir -v /mnt/apps/src
	mkdir -v /mnt/apps/src/mpi4py
	wget https://github.com/mpi4py/mpi4py/releases/download/3.1.5/mpi4py-3.1.5.tar.gz -P /apps/src/mpi4py
	chown -vR root:users /apps/src/mpi4py
	chmod -vR 770 /apps/src/mpi4py

	# make a copy of the files on this drive and save in apps/scripts and make it run only by root
	cp -vr /mnt/usb /mnt/apps/prep-scripts
	chown -vR root:root /mnt/apps/prep-scripts
	chmod -vR 700 /mnt/apps/prep-scripts

	# copy /etc/hosts
	cp -v /mnt/usb/configs/hosts /etc/hosts

	# copy /etc/sudoers
	cp -v /mnt/usb/configs/sudoers /etc/sudoers

	# copy dhcpcd.conf
	cp -v /mnt/usb/configs/dhcpcd-head.conf /etc/dhcpcd.conf
	chown -v root:netdev /etc/dhcpcd.conf
	chmod -v 664 /etc/dhcpcd.conf

	# copy chrony.conf to an accessible location
	mkdir -v /mnt/apps/configs
	cp -v /mnt/usb/configs/chrony-client.conf /mnt/apps/configs

	# wait
	echo "done!"
	sleep 10

	# reboot
	reboot now

else
	echo "Internet Access Required, Please Connect to Network"
fi
