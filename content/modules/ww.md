page
Module 4 - Warewulf Installation


---

# Module 4 - Warewulf Installation

## Objective
Understand how Warewulf(ww) is setup on the Head Node and how it works.

## References:
- [WareWulf Docs](https://warewulf.org/docs/v4.5.x/)
- [iPXE](https://ipxe.org/docs)

## What is WarewWulf?
Warewulf is a purpose-built stateless booting system built for large-scale HPC's. It's what the HPC2 uses to boot and maintain the state of thousands(literally) of cluster nodes. it does this by maintaining a "Golden Image" of a compute node as desired and sending it to each node when it boots. This means that every time a node reboots. it's entirely wiped and returned to the desired state. There are some advantages and some drawbacks to this approach. Careful consideration must be taken when building these images so that they will consistently work on all nodes. 

## Using WareWulf:
Due to the complexity of warewulf and the RPi's boot process. WareWulf has already been setup for you, this doc is to acquaint you with how it works and give some instructions required later on such as how to modify the node image.

## How Warewulf Works:
a number of moving parts come together for warewulf to work. A desired server hosts a number of services including warewulf's server daemon, dhcp, and tftp which are all needed for different stages of the boot process. Every node booted with warewulf requires the following during its boot processes: a container which acts as a traditional system's root drive, a linux kernel, and an assortment of overlays which are stacked on top of the container depending on certain environmental differences. These overlays allow a single container to be used for many, if not all, nodes, changing what's necessary between them.

## The Warewulf Boot Process:
Bringing an entire working operating system up with no internal storage is no small task. Warewulf accomplishes it in stages. Furthermore, compliations with the RPi's Pre-Boot environment require one or more additional steps.
1. RPi PXE Boot: since the RPi's have no firmware, they don't support traditional PXE booting. on the server, we provide a special PXE image that will load a UEFI environment onto the Pi's for traditional booting.
2. PXE Boot: PXE is the the standard netboot protocol for most machines. The WW server hosts a PXE image for its custom boot environment
3. iPXE: iPXE is a similar standard to PXE but much more extensible. iPXE reaches out to the WW server, handshakes, and retrieves necessary files
4. Initramfs: normally, iPXE would just pull the kernel, container, and be off the the races. this is different with the RPi's, however. Since the Pi's have very limited memory, compounded by a DMA bug in the silicon, we must take this extra step to load as little as possible before booting the kernel.
5. /bin/init: once the initramfs is copied, it pulls the container and overlays, sets up the new root, and executes /bin/init. from there the system comes up just as a traditional system.

## Adding Extra Nodes:
On the official image, Warewulf has already been setup for 4 nodes. If you have more than 4 nodes, you'll want to issue this command as root to register them with he warewulf server:
```
wwctl node add pi-hpc-compute[05-XX] -I 10.0.0.15
```
where ***XX*** is the highest number of nodes you have (leading zero if necessary)

## Common/Useful Warewulf commands:
Chrooting into the container to make changes to the compute nodes interactively:
- **Note:** the exit status of the last command dictates whether warewulf saves changes made in the chroot. this is indicated in the prompt by either a "write" or a "discard". exit the container with either Ctrl+D or `exit`
```
wwctl container exec base-rocky9-dracut /bin/bash
```

Copying Contianers, useful when testing changes
```
wwctl container cp original-container copy-container
```

Changing a node's container
```
wwctl node set --container container-name node-name
```

Rebuilding Overlays, must be rebuild after most config changes
```
wwctl overlay build [node]
```

## Power On the Nodes:
At this point, power on the nodes. They should begin booting and pulling their images. We'll configure these images in future steps.

