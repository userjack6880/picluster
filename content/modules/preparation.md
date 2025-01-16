page
Cluster Preparation
Prepare your cluster.

---

# Cluster Preparation

## Module Format

The modules will go through each step on how to setup a Raspberry Pi-based HPC compute cluster just as a production cluster. Before each section of each module are a set of links listed as "resources" that the students may review before going through the section. Most of are man pages, while the rest will be a combination of documentation, project pages, or Wikipedia articles.

Additionally, modules will have an introduction explaining the purpose of the module, and what topics will be covered. In addition to the introduction, at the end there will be some discussions questions for instructors and students to go over once the module is finished.

Unless otherwise indicated, the modules are intended to be performed *in order*, so skipping modules is not advised.

## Materials

The following is a minimum list of required materials:

| 4th Gen                                                               | QTY       | 5th Gen                                                                    | QTY         | Purpose                   |
| --------------------------------------------------------------------- | --------- | -------------------------------------------------------------------------- | ----------- | ------------------------- |
| [Cluster Enclosure](https://www.amazon.com/dp/B09JNHKL2N)             | 1         | (Same as 4th Gen)                                                          | 1           | Enclose Cluster           |
| [Short USB C](https://www.amazon.com/dp/B0BZ7D43C4)                   | 2 Cables  | (Same as 4th Gen)                                                          | 2 Cables    | Enclosure Fan Power       |
| [Type-C Female Breakout Board](https://www.amazon.com/gp/B0CKN56SLN)  | 2 Boards  | (Same as 4th Gen)                                                          | 2 Boards    | Enclosure Fan Power       |
| [Sumper Wires](https://www.amazon.com/gp/B08M3QLL3Q)                  | 4 Wires   | (Same as 4th Gen)                                                          | 4 Wires     | Enclosure Fan Power       |
| [Double Sided Tape](https://www.amazon.com/gp/B092VS7Q48)             | 1         | (Same as 4th Gen)                                                          | 1           | Enclosure Fan Power       |
| [Head Node Enclosure](https://www.amazon.com/dp/B0BRXSZHXW)           | 1         | [Head Node Enclosure](https://www.amazon.com/dp/B0D6R8GV1C)                | 1           | Enclose Head Node         |
| Raspberry Pi 4B (4GB or 8GB)                                          | 5         | Rapberry Pi 5 (4GB or 8GB)                                                 | 5           | Compute                   |
| [60W USB Hub w/7 or more ports](https://www.amazon.com/dp/B09V2K7NTZ) | 1         | [260W USB C Hub w/7 or more ports](https://www.amazon.com/dp/B0BGLTD816)   | 1           | Provide Power to Cluster  |
| HDMI Capable Monitor                                                  | 1         | (Same as 4th Gen)                                                          | 1           | View Output from Pis      |
| [MicroHDMI Cable](https://www.amazon.com/dp/B004C4WFEE)               | 1         | (Same as 4th Gen)                                                          | 1           | Provide Signal to Monitor |
| [12 Pack 1FT Cat6 Cable](https://www.amazon.com/dp/B08VRD28NY)        | 1         | (Same as 4th Gen)                                                          | 1           | Networking                |
| [M.2 SATA SSD 2280](https://www.amazon.com/dp/B079X7K6VP)             | 1         | [M.2 NVME 2242](https://www.amazon.com/dp/B09P48LF9H)                      | 1           | Head Node Storage         |
| [Heatsink Kit](https://www.amazon.com/dp/B082RWXFR2)                  | 1         | (Same as 4th Gen)                                                          | 1           | Dissapate Heat            |
| [DS3231 RTC](https://www.amazon.com/dp/B09SG9CPRN)                    | 5 Modules | [CR2032 Lithium Battery](https://www.amazon.com/dp/B0002RID4G)             | 5 Batteries | Real Time Clock           |
| --                                                                    |           | [Battery Holders](https://www.amazon.com/dp/B0D3HBNRKQ)                    | 5 Holders   | Real Time Clock           |
| [Short 90 Degree USB C](https://www.amazon.com/dp/B0765B253T)         | 4 Cables  | [Short 90 Degree USB C](https://www.amazon.com/dp/B0B5QJTT8M)              | 4 Cables    | Power Compute Nodes       |
| [Long USB C](https://www.amazon.com/dp/B0765B253T)                    | 1 Cable   | [Long USB C](https://www.amazon.com/dp/B0CLLTGBFM)                         | 1 Cable     | Power Head Node           |
| [32 GB MicroSD Card](https://www.amazon.com/dp/B09WRHRDLZ)            | 5 Cards   | (Same as 4th Gen)                                                          | 5 Cards     | OS Storage                |

Links are to recommended specific listing, quantitites are dependent on what is purchased. Head node enclosures should include an expansion board to provide a storage interface. This can be expanded to up to 40 compute nodes if desired. Quantities need to be adjusted for larger clusters.

### Downloads

[Raspberry Pi Imager](https://www.raspberrypi.com/software/): used to put images on SD cards for the Raspberry Pis.

[Head-Node Image](https://j3b.in/pihpc/pi-hpc-head01-full.img.xz): the image needed to prepare the head node is available in a compressed, raw disk image format.

[Github Repo](https://github.com/userjack6880/picluster/tree/ww-wip): while it's not recommended, the scripts required to create the head-node image can be viewed, on the github.

## Important Information

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

<!-- | pi-hpc-storage[01-40] | `10.0.0.51-90` | we're ignoring storage for now -->

## Configuring the Bootloaders

By default, the RPi's aren't set to boot from USB or the network, only the SD card. we must flash their firmware with the correct option. The following table outlines which boot mode each device needs:

| Node      | RPi 4   | RPi 5   |
| --------- | ------- | ------- |
| Head Node | USB/SD  | NVMe/SD |
| Compute   | Network | Network |

<!-- | Storage   | Network | Network | -->

### All Nodes

(See the Head-Node section if you are using NVMe before executing this part.)

- Open the RPi Imager
- Choose Device -> Your Board
- Choose OS -> Misc Utility Images -> Bootloader -> (See Table)
- Choose Storage -> Your SD Card
- Next
- Insert the SD Card into the Pi
- Apply Power
- Wait for a Green Screen
- Remove Power

### Head Node

- Open the RPi Imager
- Choose Board -> Your Board
- Choose OS -> Custom Image -> Head-Node Image (downloaded earlier)
- Choose Storage -> Your SSD (via USB)
- Next

Once it's done imaging, continue onto the SD cards.

As a note, when using the Raspberry Pi NVMe hat, you may not be able to flash the NVMe via USB. The following method can be used instead:

- Flash the default Raspbian Lite image to an SD card or USB stick using the RPi Imager.
- Insert the SD card and power on the Pi.
- Establish networking. If you're connected directly to the Pi, you will need to add manual IP's in the same subnet on both the Pi and your machine.
- `ssh` to the Pi and run `lsblk` to determine the disk name.
- Run the following command where 'X' is the drive revealed by `lsblk`. This can take a while. 

```bash
cat {image} | xz -d | ssh pi@{pi's hostname or ip} 'dd of=/dev/sdX bs=4k conv=fsync status=progress'
```

## First Boot

Attach the head node's SSD and power, optionally a keybaord and monitor. Wait for it to boot. At this point. Compute nodes and client devices can be connected.

<!-- let's not include this text for now 
## Automatically Running Through the Modules

A series of scripts are also included under `/opt/picluster/scripts`. These will run through the module automatically. -->

## [Next Module - Sharing Storage](nfs)
