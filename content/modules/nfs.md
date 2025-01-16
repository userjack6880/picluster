page
Module 4 - Sharing Storage
Setting up a simple NFS storage server.

---

# Module 4 - Sharing Storage

## Objective: Setup an NFS shared file system

While distributed filesytems (such as Lustre, GPFS, and others) are commonly used in clustered computing environments, [NFS (Network File System)](https://en.wikipedia.org/wiki/Network_File_System) is still used for filesharing between systems within a network. Your objective is to create commonly used NFS shares to be used by all of the nodes within our cluster.

A few things you will need to know:

- we'll setup NFS twice, first as one would normally do it, then as required by warewulf. While following along the normal way will work temporarily, it's not recommended as it's not needed nor will it persist across warewulf configuration changes.

- There are two interactive users:
  - `admin` - this will be the user you will do administrative tasks with - this user has `sudo` access.
  - `user` - this will be an unprivileged user
  - both users have the same password - `tuxcluster`
- Your cluster will not have direct access to the internet. All packages you will need will be included on the pre-formatted drive.
- Your cluster will be accessible using a private IP range. The optional **'pi-hpc-terminal'** node will be configured to have an interface in this private range.
  - It is suggested that you use `10.0.0.101` with a subnet of `255.255.255.0` if you aren't using a Pi Zero terminal.
- The nodes will be assigned names and IP addresses as follows:
  - **pi-hpc-head01** - `10.0.0.2`
  - **pi-hpc-terminal** - `10.0.0.101`
  - **pi-hpc-compute[01-40]** - `10.0.0.11-50`
  - **pi-hpc-storage[01-40]** - `10.0.0.51-90`

All nodes are accessible via [`ssh`](https://linux.die.net/man/1/ssh) using `admin:tuxcluster` as the username:password.

## Setting up NFS shares normally (Optional)

**Note: Performing the following steps is not necessary or permanent. The instructions exist only as a teaching aid.**

<span class="small">resources:
[dpkg](https://linux.die.net/man/1/dpkg),
[systemctl](https://www.man7.org/linux/man-pages/man1/systemctl.1.html),
[exportfs](https://linux.die.net/man/8/exportfs)
</span>

While typically packages on a RHEL-based system would be installed using `dnf` or `yum`, we are working within an environment that does not have access to the network. All necessary packages are available under `/apps/pkgs`.

The first step will be to install the NFS server package.

```bash
sudo dnf install /apps/pkgs/nfs-kernel-server*.rpm
```

Now, create the export entries in `/etc/exports` using `vim`

```bash
/home           10.0.0.0/24(rw,async,root_squash)
/mnt/apps       10.0.0.0/24(ro,async,root_squash)
/mnt/shared     10.0.0.0/24(rw,async,root_squash)
```

This will allow any computer in the `10.0.0.0` subnet (`10.0.0.1` - `10.0.0.254`) to mount the exported directories. `/mnt/apps` is exported as read only so that this path is preserved from accidental writing from computers that mount these directories.

Now, start the NFS server:

```bash
sudo systemctl start nfs-server
sudo systemctl status nfs-server
sudo exportfs -a
```

You should get an `active (exited)` status. At this point, `/home`, `/mnt/apps`, and `/mnt/shared` should be available to mount. Note: it seems that on these raspberry pi's that `showmounts -e` will cause it to hang.
<!-- TODO: check if showmount -e still hangs -->

If you want to make a change to `/etc/exports` after the NFS server has been started, you can set the new exports running `exportfs -a` as root.

## Setting up NFS using warewulf (Required)

Warewulf is heavily container oriented, so it uses many containerized practices for both the compute nodes and the head. One such practice is the use of overlays for configurable files such as `/etc/exports`. We can use warewulf's configuration file to automatically do everything we've just explained.

Edit /opt/warewulf/etc/warewulf/warewulf.conf to look like the following:

```yaml
...
nfs:
    enabled: true
    export paths:
        - path: /home
          export options: rw,sync
          mount options: defaults
          mount: true
        - path: /apps
          export options: ro,sync,no_root_squash
          mount options: defaults
          mount: true
        - path: /shared
          export options: ro,sync,no_root_squash
          mount options: defaults
          mount: true
    systemd name: nfs-server
...
```

Now run the following command as root to populate the changes to the host system:

```bash
wwctl configure nfs
```

That's it. Warewulf handles the rest.

## [Next Module - Keeping Time](module-5)
