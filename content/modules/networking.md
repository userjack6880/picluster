page
Module 3 - Networking Configuration


---

# Module 3 - Networking Configuration

## Objective

to setup networking between nodes in a way that adheres with current HPC best-practices

**NOTE: the changes made to the cluster in this document have not been reflected throughout the documents, but not much should've changed.**

## Installing and configuring isc-dhcp-server on the head:

<span class="small">resources:
[isc-dhcp-server installation](https://ubuntu.com/server/docs/how-to-install-and-configure-isc-dhcp-server),
[dhcpd.conf](https://linux.die.net/man/5/dhcpd.conf)
</span>

After basic installation, all the nodes are setup up with static IP's. This isn't desirable for a number of reasons including:
1. Any changes in IP's must be reflected across all nodes manually
2. Nodes will not wait for the head to be up before progressing past the network section of their bootstrap routine
3. We cannot automatically provide the location to network resources such as a time-syncing server

Installing the server is simple, just issue: `sudo dpkg -i /apps/pkgs/isc-dhcp-server/*.deb`

For configuration, we have a little bit of work to do. For now, let's just create a configuration that mirrors the current static setup. We can make changes later if we want.

For anything to work, we'll need to add our internal network interface to the `INTERFACESv4=""` line of `/etc/default/isc-dhcp-server`

next we'll need to define the DHCP server's subnet. Provided is a basic configuration, let's copy it with:
```
sudo cp /apps/configs/dhcpd.conf /etc/dhcp/dhcpd.conf
```

## Creating Hardware reservations for the nodes

Since we've defined the nodes location in terms of manual IP addresses, we don't want them changing IP addresses. To accomplish this, we have to define "host address reservations" in the DHCP server's configuration

before we can write definitions, we need some info from the nodes:
```
pdsh -g nodes ip addr show eth0
```
here we'll need to note the following per node:
1. The node's hostname
2. The node's IP
3. The node's mac address (appears like `..:..:..:..:..:..` after `link/ether`)

With this information, let's use our favorite editor to edit `/etc/dhcp/dhcpd.conf`:

At the end there are already a few "host" definitions. Use these as a template to complete the rest. There should be one definition for each node.

Ex:
```
host pi-hpc-compute01 {
  hardware ethernet d8:3a:dd:64:72:94;
  fixed-address 10.0.0.11;
}
```



## [Next Module - Sharing Storage through NFS](module-4)

