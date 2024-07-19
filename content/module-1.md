page
Module 1 - Sharing Storage
Setting up a simple NFS storage server.

---

# Module 1 - Sharing Storage

## Objective

**Setup an NFS shared file system**

While distributed filesytems (such as Lustre, GPFS, and others) are commonly used in clustered computing environments, [NFS (Network File System)](https://en.wikipedia.org/wiki/Network_File_System) is still used for filesharing between systems within a network. Your objective is to create, format, and share a partition, along with two other pre-created filesystems, between all of the nodes within our cluster.

A few things you will need to know:

- There are two interactive users:
  - `admin` - this will be the user you will do administrative tasks with - this user has `sudo` access.
  - `user` - this will be an unprivleged user
  - both users have the same password - `tuxcluster`
- Your cluster will not have direct access to the internet. All packages you will need will be included on the pre-formated drive.
- Your cluster will be accessible using a priavte IP range. It is suggested that you use `10.0.0.101` with a subnet of `255.255.255.0`.
- The nodes will be assigned names and IP addresses as follows:
  - **pi-hpc-head01** - `10.0.0.2`
  - **pi-hpc-compute[01-40]** - `10.0.0.11-50`
  - **pi-hpc-storage[01-40]** - `10.0.0.51-90`

All nodes are accessible via [`ssh`](https://linux.die.net/man/1/ssh) using the `admin` user.

## Partitioning the Hard Drive

<span class="small">resources:
[fdisk](https://linux.die.net/man/8/fdisk)
</span>

First, you need to see what drives are installed on the head node. Log into **`pi-hpc-head01`** and issue the following command:

```
sudo fdisk -l
```

Take node of the disk you'll need to add a partition to. It'll be the (approximately) 120 GiB disk. If the output is, for example:

```
Disk /dev/sda: 119.24 GiB, 128035676160 bytes, 250069780 sectors
```

then your disk is `/dev/sda`.

Now, we need to add the partition.

```
sudo fdisk /dev/sda
```

At this point, you can press `m` to view your options. The key ones you'll need for this objective, though, are:

- `n` : add a new partition
- `w` : write table to disk and exit

You will want to create a *primary* partition, it will be the third partition on the drive, and will go from the last free sector to the end of the disk (i.e. the default values). Essentially all default options.

Note: `fdisk` may complain about an existing filesystem signature on the partition - this is fine, as this system may have been reused and some residual partitioning signatures are left behind - acknowledge it and continue on.

## Creating a Filesystem

<span class="small">resources: 
[mke2fs](https://linux.die.net/man/8/mke2fs)
</span>

Creating an ext4 filesytem on linux is very straightforward.

```
sudo mke2fs -t ext4 /dev/sda3
```

Make sure you specify the correct partition. If you are unsure, you can do a `sudo fdisk -l` and it should be the last device listed - approximately 60 GiB.

## Mounting the Filesystem

<span class="small">resources:
[mount points](https://www.ibm.com/docs/en/aix/7.3?topic=mounting-mount-points),
[mkdir](https://linux.die.net/man/1/mkdir),
[fstab](https://linux.die.net/man/5/fstab),
[blkid](https://linux.die.net/man/8/blkid),
[mount](https://linux.die.net/man/8/mount),
[chgrp](https://linux.die.net/man/1/chgrp),
[chmod](https://linux.die.net/man/1/chmod),
[ln](https://linux.die.net/man/1/ln)
</span>

Now that we have a filesystem on the third partition, we need to mount it. First, create a mount point:

```
sudo mkdir /mnt/shared
```

Now, find the partition id of the partition - we will need this to add it to `/etc/fstab`.

```
sudo blkid /dev/sda3
```

The output should include a portion similar to `PARTUUID="6B728F42-03"`. Add this to `/etc/fstab` using the `vim` editor (remember to use `sudo`!). The line should look like this:

```
PARTUUID="6B728F42-03"  /mnt/shared      ext4    defaults     0      2
```

The `fstab` file lists all available disk partitions, file systems, and datasources and where they are mounted on the system's file structure. In our case, we are mounting the partition of the disk we just formatted to `/mnt/shared` using the `ext4` filesystem.

Once you've added the new line, mount the file system:

```
sudo mount -a
```

You can check if the filesystem is mounted usng `df -h`. Now, we need to give users permission to add and remove files from this directory.

```
sudo chgrp users /mnt/shared
sudo chmod g+w /mnt/shared
```

Finally, to make it easier to access, create a symbolic link to this path in the root directory.

```
sudo ln -s /mnt/shared /shared
```

## Setup and Configure the NFS Server

<span class="small">resources:
[dpkg](https://linux.die.net/man/1/dpkg),
[systemctl](https://www.man7.org/linux/man-pages/man1/systemctl.1.html),
[exportfs](https://linux.die.net/man/8/exportfs)
</span>

While typically packages on a Debian-based system would be installed using `apt` or `apt-get`, we are working within an environment that does not have access to the network. All necessary packages are available under `/apps/pkgs`.

The first step will be to install the NFS server package.

```
sudo dpkg -i /apps/pkgs/nfs-kernel-server*.deb
```

Now, create the export entries in `/etc/exports` using `vim`

```
/home           10.0.0.0/24(rw,async,no_root_squash)
/mnt/apps       10.0.0.0/24(ro,async,no_root_squash)
/mnt/shared     10.0.0.0/24(rw,async,no_root_squash)
```

This will allow any computer in the `10.0.0.0` subnet (`10.0.0.1` - `10.0.0.254`) to mount the exported directories. `/mnt/apps` is exported as read only so that this path is preserved from accidental writing from computers that mount these directories.

Now, start and enable the NFS server:

```
sudo systemctl enable nfs-server
sudo systemctl start nfs-server
sudo systemctl status nfs-server
sudo exportfs -a
```

You should get an `active (exited)` status. At this point, `/home`, `/mnt/apps`, and `/mnt/shared` should be available to mount. Note: it seems that on these raspberry pi's that `showmounts -e` will cause it to hang.

If you want to make a change to `/etc/exports` after the NFS server has been started, you can set the new exports using `sudo exportfs -a`.

## Setup and Configure Clients

<span class="small">resources:
[rm](https://linux.die.net/man/1/rm),
[ping](https://linux.die.net/man/8/ping)
</span>

The following will need to be done on all nodes *except for* the **head node**. You can access the rest of the nodes from the head-node by using `ssh` and the hostname of the node (e.g. `pi-hpc-compute01`). This section can be destructive, so be sure you are not on the head node when doing these steps.

The first step will be to remove the local home directory for `admin`:

```
sudo rm -r /home/admin
```

This will prepare `/home` for the next steps.

Now, confirm if you can see the head node.

```
ping -c 2 pi-hpc-head01
```

This should return `2 packets transmitted` - this means you are able to see the head node. If you aren't able, check to make sure everything is plugged in correctly.

Create the /apps and /shared directories. You will need to use `sudo`. Once you've have done that, edit `/etc/fstab`:

```
pi-hpc-head01:/home         /home         nfs4    defaults,user,exec          0 0
pi-hpc-head01:/mnt/apps     /apps         nfs4    defaults,user,exec          0 0
pi-hpc-head01:/mnt/shared   /shared       nfs4    defaults,user,exec          0 0
```

Mount the shares using `sudo mount -a` and you should see the `pkgs` directory under `/apps` and a home directory for `user` under `/home`.

Repeat above for every other node.

## [Next Module - Keeping Time](module-2)
