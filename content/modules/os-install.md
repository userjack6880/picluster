page
Module 2 - Operating System Installation


---

# Module 2 - Operating System Installation

## Objective
Create a Base environment to start from when going through the modules

## Where to Start
Provided are ready to run images for boards we test, as well as scripts to configure base Raspbian images to our starting point.

## From Ready-Made images
1. Download the image that matches your board model from [here](TODO: Placeholder)
2. Open Rpi imager
3. Choose device -> select your device
4. Choose OS -> Use Custom -> navigate to the downloaded image
5. Select next. 

#### Considerations for using an SSD
In some exclosures, it can be difficult to access the SSD from another computer. a decent workaround is the following:
1. Flash the default raspbian lite image to an SD card or USB stick using the Rpi Imager
2. Insert the SD card and power on the Pi
3. Establish networking. If you're connected directly to the pi, you will need to add manual IP's in the same subnet on both the pi and your machine
4. ssh to the pi and run `lsblk` to determine the disk name
5. Run the following command where 'X' is the drive revealed by lsblk. This can take a while. 
```
cat {image} | xz -d | ssh pi@{pi's hostname or ip} 'dd of=/dev/sdX bs=4k conv=fsync status=progress'
```

## From a Script
*NOTE*: Use of these scripts is not recommended. While they are what we use to generate the ready-made images, things can change between the release of sources after we publish images and issues can arise. ***You've been warned***
1. Flash the latest version of rockylinux for RPi from [their website](https://rockylinux.org/download)
2. Connect the Pi to a network and power
3. Clone the github repo to the pi. typically `/opt/picluster`
4. Run `/opt/picluster/headnode.sh` as root
5. The node will reboot when done
6. Follow the guide [here](content/internet.md) to setup an internet connection w/ the head node's networking setup
7. Run `/opt/picluster/warewulf.sh` as root
8. Run `/opt/picluster/ww-nodes.sh` as root
9. Reboot
