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
Warewulf is a purpose-built stateless booting system for HPC. it's what the HPC2 uses to boot and maintain the state of thousands(literally) of cluster nodes. it does this by maintaining a "Golden Image" of a compute node as desired and sending it to each node when it boots. This means that every time a node reboots. it's entirely wiped to the desired state. There are some advantages and some drawbacks to this approach. Careful consideration must be taken when building these images so that they will consistently work on all nodes. 

## Building WareWulf:
Since the picluster's ISA isn't x86, we'll need to build warewulf from source. 

On the Head Node:
```
sudo dnf install golang
mkdir -p /apps/warewulf
git clone https://github.com/warewulf/warewulf.git /opt/warewulf/src
cd !$
make clean defaults PREFIX=/opt/warewulf
make all
make install
```
At this point warewulf should now be installed to `/opt/warewulf`

## Configuring WareWulf:
The first useful thing to configure is to add our warewulf install to our path so we can call `wwctl` and others without their absolute paths.

Add the following line to the end of `~/.bashrc`:
```
export PATH=$PATH:/opt/warewulf/bin
```
