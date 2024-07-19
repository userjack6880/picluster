page
Module 2 - Keeping Time
Set up timesyncd to keep time.

---

# Module 2 - Keeping Time

## Objective

**Set up chronyd to keep time**

Because of the intercommunication between storage, compute, and head nodes, it's important that every node in the system is in lockstep with each other. An additional complication with our setup is that not only is it isolated from the internet (so it can't grab the time automatically), Raspberry Pi 4's and Pi Zero's do not have a hardware clock, so every time they are powered off, the time is reset. They make an attempt at trying to keep time moving forward by using a fake hardware clock (aka, saving the time on shutdown), but this does not always work, especially if they are powered off suddenly.

Our goal is to setup a time server and have every node sync time with it using [NTP](https://en.wikipedia.org/wiki/Network_Time_Protocol). While Raspbian comes with `systemd-timesyncd`, we're going to replace it with `chrony` as it can act as both a time server and local 

## Selecting the Time Server

Before we put hands on keyboards, we need to think about which node should be the time server. Off the bat, a compute or storage node is not appropriate - these should dedicate resources to performing calculations or providing high-speed storage. In our setup, it leaves us with the head node. This node will need to be the first one to be turned on, and should always be properly shutdown. Optionally, and preferred, you should set the time on this node every time you turn it on.

## Setting the Time

<span class="small">resources:
[timedatectl](https://www.freedesktop.org/software/systemd/man/timedatectl.html),
[grep](https://linux.die.net/man/1/grep)
</span>

You can check the current status of the time by using `timedatectl status`.

The time zone should automatically be set, but if it isn't, you can set it:

```
sudo timedatectl set-timezone <time zone>
```

If you are unsure what timezones are available, use `timedatectl list-timezones` to list out all available timezones - `grep` can be useful for narrowing the list down.

The time is set using:

```
sudo timedatectl set-time 'Y:M:D HH:mm:ss'
sudo timedatectl set-time 'Y:M:D'
sudo timedatectl set-time 'HH:mm:ss'
```

The examples above show that you can either give it a full timestamp or a partial one. Keep in mind that time is represented using 24-hour time. You don't want to be 12 hours off!

NOTE: `timedatectl` is unable to set the time if NTP is being used. Stop NTP service before attempting to set time.

## Replacing timesyncd With chrony on the Server

<span class="small">resources:
[systemd-timesyncd](https://wiki.archlinux.org/title/Systemd-timesyncd),
[chrony](https://chrony-project.org),
[apt](https://linux.die.net/man/8/apt)
</span>

The first thing we need to do is stop and disable `systemd-timesyncd`.

```
sudo systemctl stop systemd-timesyncd
sudo systemctl disable systemd-timesyncd
```

Now uninstall it using apt and then install the `chrony` package via dpkg.

```
sudo apt remove systemd-timesyncd
sudo dpkg -i /apps/pkgs/chrony*arm64.deb
```

`chrony` will need to be configured. First, stop `chrony`.

```
sudo systemctl stop chrony
```

Now edit `/etc/chrony/chrony.conf`. Clear all lines and make sure it only contains these lines:

```
driftfile /var/lib/chrony/chrony.drift
server 127.127.1.1
local stratum 8
allow all
```

The IP address `127.127.1.1` is the loopback address for NTP. You are telling `chrony` to sync with the system's clock driver. This isn't considered best practice, but for our purposes, it'll do the trick. Now restart `chrony`.

```
sudo systemctl start chrony
```

You can check the status of `chrony` using `chronyc tracking` and see if it's actually using the loopback address with `chronyc sources`.

## Replacing timesyncd With chrony on the Nodes

<span class="small">resources:
[pdsh](https://linux.die.net/man/1/pdsh),
[grep](https://linux.die.net/man/1/grep)
</span>

Repeat the above process to stop, disable, and uninstall `systemd-timesyncd`. When installing `chrony`.

You can use `pdsh` from **'pi-hpc-head01'** to issue commands to the compute nodes all at once. Instead of `apt remove`, you will need to use `apt-get -y remove` as `pdsh` is non-interactive. The nodes are configured in a way that you will be allowed to use `sudo`.

```
pdsh -w pi-hpc-compute[01-04] hostname
```

On each of the "client" nodes, you'll need to edit `/etc/chrony/chrony.conf` to be the following:

```
driftfile /var/lib/chrony/chrony.drift
server 10.0.0.2 iburst
```

Because `pdsh` is not interactive, you will have to end up logging into each node individually to edit those files. However, the config file has been shared under `/apps/configs` - you can use `pdsh` to copy that file where it needs to be.

```
pdsh -w pi-hpc-compute[01-04] sudo cp /apps/configs/chrony-client.conf /etc/chrony/chrony.conf
```

Give the client nodes some time to come back into sync with the server. You can monitor this by using this command.

```
pdsh -w pi-hpc-compute0[1-4] chronyc tracking | grep "System time"
```

Once everybody is pretty much within 0 seconds of NTP time, we're ready for the next module.

## [Next Module - Setup Scheduler](module-3)
