page
Module 11 - Install And Setup GlusterFS
Install and configure network storage

---

# Module 11 - Install And Setup GlusterFS

## Objective

**Install, setup and configure Storage Nodes with GlusterFS**

[GlusterFS](https://docs.gluster.org/en/latest/Administrator-Guide/GlusterFS-Introduction/) (short for GNU Cluster FileSystem) is an open source cluster filesystem that uses a "Peer" based architecture and FUSE (filesystem in userspace) client. This way no one node is responsible for managing the system. GlusterFS allows us to pool together storage devices across nodes as well as it allows us to write to the same file concurrently from different machines. We will be installing and configuring the storage nodes to be GlusterFS peers and configuring all other nodes to be GlusterFS clients.

## Install Glusterd on the Storage nodes

The storage nodes will be storage daemon peers. Any one can be reached to access the pool.

From the head node:

```
pdsh -g storage sudo dpkg -i /apps/pkgs/glusterfs-server/*.deb
pdsh -g storage sudo systemctl enable --now glusterd
pdsh -g storage systemctl status glusterd
```
Look for `(Active) Running`

## Install GlusterFS on the client nodes
it's the same as before except all other nodes only need the client version of GlusterFS
```
pdsh -g storage sudo dpkg -i /apps/pkgs/glusterfs-client/*.deb
pdsh -g storage sudo systemctl enable --now glusterd
pdsh -g storage systemctl status glusterd
```

## Prepare the drives
Since glusterd stores its blocks on top of an existing filesystem, the drives need to be formatted and mounted automatically for gluster to use

```
pdsh -g storage mkfs.xfs -i size=512 /dev/sda1
pdsh -g storage mkdir -p /data/brick1
pdsh -g storage ./apps/prep-scripts/configs/fstab.sh
pdsh -g storage mount -a && mount
```

## Probe Peers:

In order for glusterd to know how to reach the other servers, it needs to probe them.

From a single storage node w/ an elevated prompt:
```
for i in {02..04}; do gluster peer probe pi-hpc-compute$i; done
```

Replace "04" in the loop bounds with however many storage nodes are present

now from any other storage node, run:
```
sudo gluster peer probe pi-hpc-compute01
sudo gluster peer status
```

You should see something like:
```
Number of Peers: 3

Hostname: pi-hpc-storage02
Uuid: f0e7b138-4874-4bc0-ab91-54f20c7068b4
State: Peer in Cluster (Connected)

Hostname: pi-hpc-storage03
Uuid: f0e7b138-4532-4bc0-ab91-54f20c701241
State: Peer in Cluster (Connected)

Hostname: pi-hpc-storage04
Uuid: f0e7b138-4532-4bc0-ab91-54f20c701241
State: Peer in Cluster (Connected)
```

## Create the Storage Pool
There are a number of architectures you could implement that would weigh data capacity with resiliency. Since gluster stores its blocks on top of an underlying filesystem, it's very possible to layer gluster with something like ZFS. In our case, each node only has 1 drive, so we will be setting up a "Dispersed" which allows a combination of speed and redundancy. Other architecture schemes are described [here](https://docs.gluster.org/en/latest/Quick-Start-Guide/Architecture/#types-of-volumes)
**Note:** since gluster uses a peer architecture, any redundancy done on the gluster level will impact write performance. expect $\dfrac{link\ bandwidth}{no.\ of\ copies+1}$  

On all storage nodes eg. On the head w/ pdsh:
```
sudo mkdir -p /data/brick1/gv0
```
Then from a single storage node:
```
sudo gluster volume create gv0 disperse 3 redundancy 1 \
pi-hpc-storage01:/data/brick1/gv0 \
pi-hpc-storage02:/data/brick1/gv0 \
pi-hpc-storage03:/data/brick1/gv0 \
pi-hpc-storage04:/data/brick1/gv0
sudo gluster volume start gv0
sudo gluster volume info
```
You should see:
```
Volume Name: gv0
Type: Disperse
Volume ID: a63005a2-9e47-4d22-987e-605de17166cd
Status: Started
Snapshot Count: 0
Number of Bricks: 1 x (3 + 1) = 4
Transport-type: tcp
Bricks:
Brick1: pi-hpc-storage01:/data/brick1/gv0
Brick2: pi-hpc-storage02:/data/brick1/gv0
Brick3: pi-hpc-storage03:/data/brick1/gv0
Brick4: pi-hpc-storage04:/data/brick1/gv0
Options Reconfigured:
nfs.disable: on
transport.address-family: inet
storage.fips-mode-rchecksum: on
```

## Testing the pool
before we configure all the nodes to connected to the pool on boot, we should make sure the pool works. From any node:
```
sudo mkdir /mnt/test
sudo mount -t glusterfs pi-hpc-storage01:/gv0 /mnt/test
```
You should be able to create and view files here. Once you're done. Lets clean up w/
```
sudo umount /mnt/test
sudo rmdir /mnt/test
```

## Configuring Clients
Now that the GlusterFS pool is running, we need to connect all other nodes to it. Pdsh makes this easy.

```
sudo mkdir /mnt/scratch
echo "pi-hpc-storage01:gv0 /mnt/scratch glusterfs defaults 0 2" | sudo tee -a /etc/fstab
sudo mount -a && df -h
```
You should see a line that says something like:
```
pi-hpc-storage01:/gv0  671G   12G  659G   2% /scratch
```



