page
Module 3 - Networking Configuration


---

# Module 3 - Networking Configuration

## Objective

## Installing and configuring isc-dhcp-server on the head:

After basic installation, all the nodes are setup up with static IP's. This isn't desireable for a number of reasons including:
1. Any changes in ip's must be reflected accross all nodes manually
2. Nodes will not wait for the nead to be up before progressing past the network section of their bootstrap routine
3. We cannot automatically provide the location to network resources such as a timesyncing server

Installating the server is simple, just issue: `sudo dpkg -i /apps/pkgs/isc-dhcp-server/*.deb`

For configuration, we have a little bit of work to do. For now, let's just create a configuration that mirrors the current static setup. We can make changes later if we want.

For anything to work, we'll need to add our internal network interface to the `INTERFACESv4=""` line of `/etc/default/isc-dhcp-server`

next we'll need to define the dhcp server's subnet. Provided is a basic configuration, let's copy it with:
```
sudo cp /apps/configs/dhcpd.conf /etc/dhcp/dhcpd.conf
```

## Creating Hardware reservations for the nodes

Since we've defined the nodes location in terms of manual ip addresses, we don't want them chaning ip addresses. To accomplish this, we have to define "host address reservations" in the dhcp server's configuration

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



## Module 4 - 

