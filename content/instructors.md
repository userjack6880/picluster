page
Notes for Instructors
Notes for Instructors

---

# Notes for Instructors

## Module Format

The modules will go through each step on how to setup a RaspberryPi-based HPC compute cluster just as a production cluster. Before each section of each module are a set of links listed as "resources" that the students may review before going through the section. Most of are man pages, while the rest will be a combination of documentation, project pages, or Wikipedia articles.

Additionally, modules will have an introduction explaining the purpose of the module, and what topics will be covered. In addition to the introduction, at the end there will be some discussions questions for instructors and students to go over once the module is finished.

Unless otherwise indicated, the modules are intended to be performed *in order*, so skipping modules is not advised.

## Materials

It is suggested that at minimum 4 Raspberry Pi 4B's 5's be purchased for these modules with adaquate storage provided for at least one (a large SD card or external drive). 1 SD card will be required for setup regardless of head node storage choice. At least one network switch to allow all of the SBC's to connect to each other is required, as well as some way to access to cluster, via a laptop or a direct montior/keyboard connection to one of the SBC's.

The following list of materials were used as the reference hardware:

***TODO: Placeholder BOM***

Finally, get the official [Raspberry Pi Imager](https://www.raspberrypi.com/software/).

A few things you will need to know:

- There are two interactive users:
  - `admin` - this will be the user you will do administrative tasks with - this user has `sudo` access.
  - `user` - this will be an unprivleged user
  - both users have the same password - `tuxcluster`
- Your cluster will not have direct access to the internet. All packages you will need will be included on the pre-formated drive. feel free to read [this](modules/internet) if networking is desired after the fact.
- Your cluster will be accessible using a priavte IP range of 10.0.0.0/24
  - the head node runs a dhcp server which will automatically give client devices an ip in the range of `10.0.0.200-254`
- The nodes are assigned names and IP addresses as follows:

| Hostname              | Address        |
| --------------------- | -------------- |
| pi-hpc-head01         | `10.0.0.2`     |
| pi-hpc-compute[01-40] | `10.0.0.11-50` |
| pi-hpc-storage[01-40] | `10.0.0.51-90` |

### Downloads

[Head-Node Image](https://j3b.in/pihpc/pi-hpc-head01-full.img.xz): the image needed to prepare the head node is available in a compressed, raw disk image format.

[Github Repo](https://github.com/userjack6880/picluster/tree/ww-wip): while it's not recommended, the scripts required to create the head-node image can be viewed, on the github.

## Configuring the Bootloaders

By default, the RPi's aren't set to boot from USB or the network, only the SD card. we must flash their firmware with the correct option. The following table outlines which boot mode each device needs:

| - | RPi 4 | RPi 5 |
|-|-|-|
| Head-Node | USB/SD | NVMe/SD |
| Compute | Network | Network |
| Storage | Network | Network |

For Each Pi:

1. Open the RPi imager
2. Choose Device -> your board
3. Choose OS -> Misc utility images -> Bootloader -> (See matrix)
4. Choose Storage -> Your SD Card
5. Next
6. Insert the SD card into the Pi
7. Power Apply Power
8. Wait for a green screen
9. Remove Power

## Flashing the Head-Node

1. Download the [Head-Node Image](https://j3b.in/pihpc/pi-hpc-head01-full.img.xz)
2. Open the RPi imager
3. Choose Board -> Select your board
4. Choose OS -> Custom Image -> browse to the downloaded image
5. Choose Storage -> Your SSD
6. Next

## First Boot

Attach the Head-Node's SSD and power, optionally a keybaord and monitor. Wait for it to boot. At this point. Compute Nodes and Client devices can be connected. Any storage nodes attached will function as compute nodes until later configured in the modules

## Automatically Running Through the Modules

A series of scripts are also included under `/opt/picluster/scripts`. These will run through the module automatically - it is suggested that you delete this directory after preparing the nodes for the students.