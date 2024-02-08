# check for network first
if ping -c 1 72.14.177.74 &> /dev/null
then

	# update locales
	perl -pi -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen

	# update repos

	apt-get update
	apt-get -y upgrade
	apt-get -y install vim

	# create additional users
	useradd -d /home/user -g users -m -p '$5$cOTJhkxlC4$kEFPIJaKPriv16lcwNBsS4dVMT1sC/a9vFPNlZDHug1' -s /bin/bash -u 1001 user

	# copy /etc/hosts
	cp /mnt/usb/configs/hosts /etc/hosts

	# copy /etc/sudoers
	cp /mnt/usb/configs/sudoers /etc/sudoers

	# copy dhcpcd.conf
	cp /mnt/usb/configs/dhcpcd-terminal.conf /etc/dhcpcd.conf
	chown root:netdev /etc/dhcpcd.conf
	chmod 664 /etc/dhcpcd.conf

	# copy boot config
	cp /mnt/usb/configs/terminal-boot.txt /boot/config.txt
	chmod 755 /boot/config.txt

	# wait
	echo "done!"
	sleep 10

	# reboot
	reboot now

else
	echo "Internet Access Required, Please Connect to Network"
fi
