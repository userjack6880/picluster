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
Then, Modify the following lines in `/opt/warewulf/etc/warewulf/warewulf.conf to be:
```
ipaddr: 10.0.0.2
netmask: 255.255.255.0
network: 10.0.0.0
    range start: 10.0.0.201
    range end: 10.0.0.255
nfs:
    enabled: false
```
Now start all warewulf services with:
```
wwctl configure --all
systemctl enable --now warewulfd
```

## Setting up the Container:
Originally, warewulf used what they called "Virtual Node FileSystems"(vnfs) which were created from a chroot. While they're still refered to as vnfs', the advent of containerization has made creating and distributing these much easier. Since this guide is for offline use. we've provided the OCI container we need as a .tar file. we'll need to import it into our warewulf config:
```
wwctl container import /apps/images/base-rocky-9.4.tar base-rocky-9.4
```

## Setting up Profiles:
each node has it's own configuration but all nodes will share most of their configuration. we'll use a profile to ease the setting of these configurations:
```
wwctl profile add picluster
wwctl profile set --cluster picluster
wwctl profile set --container base-rocky-9.4
```

## Defining Nodes:
Once we have our profiles defined, we're ready to define our nodes in the same way:
```
wwctl node add pi-hpc-node01
wwctl node set --ipaddr 10.0.0.11 --discoverable
# do the above for each node, incrementing the ip and hostname
wwctl node set --profile picluster --all
```

## Power On the Nodes:
At this point. power on the nodes. they should begin booting and pulling their images. we'll configure these images in future steps.

