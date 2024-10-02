page
Module 2 - Operating System Installation


---

# Module 2 - Operating System Installation

## Objective
Create a Base environment to start from when going through the modules

## Where to Start
Provided are ready to run images for boards we test, as well as scripts to configure base Raspbian images to our starting point.

## From Ready-Made images
- download the image that matches your board model from [here](place.holder)
- If using the linux command linde: run `cat {the image} | gz -d | dd of=/dev/sdX bs=4k conv=fsync status=progress` where `/dev/sdX` is the block device of your SD/SSD
- If using the the RPi imager, select your model, then custom image, select the image, then write.
#### Considerations for using an SSD
it can be difficult to access the Pi's SSD from another computer. a decent workaround is the following:
- Flash the default raspbian lite image to an SD card or USB stick
- Boot the Pi
- Establish networking. If you're connected directly to the pi, you will need to add manual IP's in the same subnet on both the pi and your machine
- ssh to the pi and run `lsblk` to determine the disk name
- Run `cat {image} | gz -d | ssh pi@{pi's hostname or ip} dd of=/dev/sdX bs=4k conv=fsync status=progress`

## From a Script
*NOTE*: it is recommended that you use the ready-made images as these have been tested to work through the whole project. they also don't require internet once they've been written to the Pi's
- flash the latest version of rasbian lite to an sd card using the RPi Imager
- connect the Pi to a network and power
- run `curl -LO https://github.com/userjack6880/picluster/raw/refs/heads/ww-wip/headnode.sh | sudo bash`
- the node will reboot when done



## Module 3 - Networking Configuration

