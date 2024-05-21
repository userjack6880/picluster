page
Notes for Instructors
Notes for Instructors

---

# Notes for Instructors

## Module Format

The modules will go through each step on how to setup a Raspberry Pi compute cluster. Before each section of each module are a set of links listed as "resources" that the students may review before going through the section. Most of these will be man pages, while the rest will be a combination of documentation, project pages, or Wikipedia articles.

The modules are intended to be performed *in order*, so skipping modules is not advised. Each module should take anywhere between 5 - 10 minutes, depending on skill level.

## Materials

You will need the hardware listed in the [introduction](index) along with a USB drive. You will need to copy the configuration scripts located [here](https://j3b.in/pihpc/scripts.zip) and extract them to the drive. Ensure the contents are in the root of the drive or scripts will not function. Additionally, you should get the official [Raspberry Pi Imager](https://www.raspberrypi.com/software/).

Optionally, you can use git to download a copy of these scripts (and this documentation). Git is not installed with Raspberry Pi OS by default - this can be installed using 'sudo apt get install git'.

A few things you will need to know:

- There are two interactive users:
  - `admin` - this will be the user you will do administrative tasks with - this user has `sudo` access.
  - `user` - this will be an unprivleged user
  - both users have the same password - `tuxcluster`
- Your cluster will not have direct access to the internet except during this initial setup stage. The setup scripts will ensure you have all the pacakges you'll need later.
- Your cluster will be accessible using a priavte IP range. The optional **'pi-hpc-terminal'** node will be configured to have an interface in this private range.
  - It is suggested that you use `10.0.0.101` with a subnet of `255.255.255.0`/`CIDR /24` if you aren't using a Pi Zero terminal.
- The nodes will be assigned names and IP addresses as follows:

| Hostname              | Address        |
| --------------------- | -------------- |
| pi-hpc-head01         | `10.0.0.2`     |
| pi-hpc-terminal       | `10.0.0.101`   |
| pi-hpc-compute[01-40] | `10.0.0.11-50` |
| pi-hpc-storage[01-40] | `10.0.0.51-90` |

### Downloads
[Preparation Scripts](https://j3b.in/pihpc/scripts.zip): the scripts needed to prepare the PI's are available in a zip file, as well as a copy of this website and presentations used by MSU SIG-HPC.

[Github](https://github.com/userjack6880/picluster): all files included in the ZIP file above, including the ZIP file itself, are also hosted on github.

## Creating the SD Cards

Using the Raspberry Pi Imager, format each SD card, using the **Raspberry Pi OS (Legacy, 64-bit) Lite** image for each of the compute, storage, and head nodes. For the service node, if you are using a Pi Zero/Zero 2, use the **Raspberry Pi OS (Legacy, 32-bit) Lite** image. Newer versions of Raspberry Pi Imager will ask for the board type. Before writing, you will need to set the following:

| Setting                                  | Value                             |
| ---------------------------------------- | --------------------------------- |
| Set hostname                             | pi-hpc-\[nodename\]               |
| Enable SSH - Use password authentication | yes                               |
| Set username and password                | user: admin, password: tuxcluster |
| Set locale settings                      | use your local values             |

Hostnames needed are listed above. For the compute and storage nodes, it really won't matter much as their names will get overwritten by the prep scripts.

## First Boot

Make sure on the head node and storage nodes that the external drives are already attached. This ensures that they are set to `/dev/sda`. Once the Pi has booted, then you can insert the USB disk you have prepared.

### Head Node

Let the Pi go through it's initial boot cycle (boot, then reboot). Once it has finished, mount the USB Key. **Do everything in an elevated terminal**. Once the script has run, it will reboot. Plug in the private network port at that time.

*The following should be done with an Internet connection:*

if you plan on using a usb drive:
```
sudo su
mkdir /mnt/usb
mount /dev/sdb1 /mnt/usb
cd /mnt/usb
./headnode.sh format
```

Ensure `ls /mnt/usb` yields the scripts and not a folder containing them.

if you plan on using git:
```
sudo su
apt install git -y
mkdir /mnt/usb
git clone https://github.com/userjack6880/picluster.git /mnt/usb
cd /mnt/usb
./headnode.sh format
```

When it gets to the partitioning step, you will want to make the following:

- Partition 1: 10 GB
- Partition 2: 50 GB

If you've already formatted the disk, you can omit `format`.

It should automount those partitions. Once it comes back from the reboot, check the following:

- `/apps` should exist and contain a `pkgs` directory with `.deb` files and a `prep-scripts` directory containing the files on the USB. It will be owned by root.
- `/home` should contain two user directories - `admin` and `user`.
- a `df -h` should show that `/dev/sda1` is mounted under `/home` and `/dev/sda2` is mounted under `/mnt/apps`

### Compute Nodes

As with before, let them go through their cycles and insert the USB drive last. Mount the disk like before. Note that because there are no external disks, the USB drive will be `/dev/sda1`.

Run the compute script:

```
cd /mnt/usb
./compute.sh [node_number]
```

Replace `[node_number]` with the number of the compute (01-04 at time of writing). To avoid a problem with hostnames later, ensure the preceeding 0 is included for single digit node numbers, e.g. `./compute.sh 01`.

### Terminal Node

Do the same as the head node, but omit `format`.

### Storage Nodes

Do the same as the compute nodes, but include `format` like in the head node if the SSD's attached aren't formatted.

You may want to review `configs/terminal-boot.txt` to set the boot resolution.

## Automatically Running Through the Modules

A series of scripts are also included under `/mnt/usb/module_scripts`. These will run through the module automatically - it is suggested that you delete this directory after preparing the nodes for the students.

For Module 1, these will need to be run from the USB drive on the clients. After NFS mounts are created and available to all the nodes, you can access them from `/apps/prep-scripts`. The name should be self-explanatory.
