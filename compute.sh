# check for network first
if ping -c 1 72.14.177.74 &> /dev/null
then

	# update locales
	perl -pi -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
	sudo sed -ri 's/en_GB.UTF-8 UTF-8/# en_GB.UTF-8 UTF-8/' /etc/locale.gen
	sudo sed -ri 's/LANG=en_GB.UTF-8/LANG=en_US.UTF-8/' /etc/default/locale

	# update repos

	apt-get update
	apt-get -y upgrade
	apt-get -y install vim python3-distutils python3-dev

	# create additional users
	useradd -d /home/user -g users -M -p '$5$cOTJhkxlC4$kEFPIJaKPriv16lcwNBsS4dVMT1sC/a9vFPNlZDHug1' -s /bin/bash -u 1001 user

	# copy /etc/hosts
	cp ./configs/hosts /etc/hosts

	# copy /etc/sudoers
	cp ./configs/sudoers /etc/sudoers

	# # copy dhcpcd.conf
	cp ./configs/dhcpcd-compute.conf /etc/dhcpcd.conf
	sed -i "s/10.0.0.xx/10.0.0.$(($1+10))/g" /etc/dhcpcd.conf
	chown root:netdev /etc/dhcpcd.conf
	chmod 664 /etc/dhcpcd.conf

	# use nmcli to set static IP
	# nmcli connection modify 'Wired connection 1' ipv4.address 10.0.0.$(($1+10))/24
	# nmcli connection modify 'Wired connection 1' ipv4.method manual

	# set hostname
	echo "pi-hpc-compute$1" > /etc/hostname

	# wait
	echo "done!"
	sleep 10

	# reboot
	reboot now

else
	echo "Internet Access Required, Please Connect to Network"
fi
