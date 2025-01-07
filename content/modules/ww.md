page
Module 4 - Warewulf Installation


---

# Module 4 - Warewulf Installation

## Objective
Setup Warewulf(ww) on the Head node and configure the ww node images

## References:
- [WareWulf Docs](https://warewulf.org/docs/v4.5.x/)
- [iPXE](https://ipxe.org/docs)

## What is WarewWulf?
Warewulf is a purpose-built stateless booting system for HPC. It's what the HPC2 uses to boot and maintain the state of thousands(literally) of cluster nodes. it does this by maintaining a "Golden Image" of a compute node as desired and sending it to each node when it boots. This means that every time a node reboots. it's entirely wiped and returned to the desired state. There are some advantages and some drawbacks to this approach. Careful consideration must be taken when building these images so that they will consistently work on all nodes. 

## Using WareWulf:
Due to the complexity of warewulf and the RPi's boot process. WareWulf has already been setup for you, this doc is to acquant you with how it works and give some instructions required later such as how to modify the node image.

## Adding Extra Nodes:
WareWulf has already been setup for 4 nodes. If you have more than 4 nodes, you'll want to issue this command as root to register them witht he warewulf server:
```
wwctl node add pi-hpc-compute[05-XX] -I 10.0.0.15
```
where ***XX*** is the highest number of nodes you have (leading zero if necessary)

## Power On the Nodes:
At this point. power on the nodes. they should begin booting and pulling their images. we'll configure these images in future steps.

