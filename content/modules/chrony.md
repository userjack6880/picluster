page
Module 5 - Keeping Time
Set up timesyncd to keep time.

---

# Module 5 - Keeping Time

## Objective

**Set up chronyd to keep time**

Because of the intercommunication between storage, compute, and head nodes, it's important that every node in the system is in lockstep with each other. An additional complication with our setup is that not only is it isolated from the internet (so it can't grab the time automatically), Raspberry Pi 4's and Pi Zero's do not have a hardware clock, so we'll have to add one.

Our goal is to setup a time server and have every node sync time with it using [NTP](https://en.wikipedia.org/wiki/Network_Time_Protocol). While Raspbian comes with `systemd-timesyncd`, we're going to replace it with `chrony` as it can act as both a time server(head) and client(nodes).

## Selecting the Time Server

Before we put hands on keyboards, we need to think about which node should be the time server. Off the bat, a compute or storage node is not appropriate - these should dedicate resources to performing calculations or providing high-speed storage. In our setup, this leaves us with the head node. This node will need to be the first one to be turned on, and should always be properly shutdown.

## Setting the Time

<span class="small">resources:
[timedatectl](https://www.freedesktop.org/software/systemd/man/timedatectl.html),
[grep](https://linux.die.net/man/1/grep)
</span>

You can check the current status of the time by using `timedatectl`.

The time zone should automatically be set, but if it isn't, you can set it:

```
sudo timedatectl set-timezone <time zone>
```

If you are unsure what time-zones are available, use `timedatectl list-timezones` to list out all available time-zones - `grep` can be useful for narrowing the list down.

The time is set using:

```
# if an ntp server is already running, stop if first with:
sudo service systemd-timesyncd stop
# then change the time w/
sudo timedatectl set-time 'Y:M:D HH:mm:ss'
# or individually with: 
sudo timedatectl set-time 'Y:M:D'
sudo timedatectl set-time 'HH:mm:ss'
# finally remember to restart the NTP service again w/:
sudo service systemd-timesyncd start
```

The examples above show that you can either give it a full timestamp or a partial one. Keep in mind that time is represented using **24-hour time**. You don't want to be 12 hours off!

## Using the Hardware Clock

<span class="small">resources:
[Adding a Real Time Clock to your Raspberry Pi](https://thepihut.com/blogs/raspberry-pi-tutorials/17209332-adding-a-real-time-clock-to-your-raspberry-pi)
</span>

By default, the RaspberryPi doesn't have a realtime clock. Installed on the head node is an i2c enabled realtime clock. We need to set this up in software in order for it to be functional

First lets enable the rPi's i2c functionality:
1. `sudo raspi-config`
2. Select 3 Interface options
3. Select I5 I2C
4. Select yes

Now let's install the required packages and check for the device by issuing:
```
sudo apt update && sudo apt install i2c-tools
i2cdetect -y 1
```
You should see ID #68 present

Now let's enable it with:
```
sudo modprobe rtc-ds1307
echo ds1307 0x68 | sudo tee /sys/class/i2c-adapter/i2c-1/new_device
sudo hwclock -r
# if the rtc hasn't been used before. It should return jan 1, 2000. Ensure the system time is correct and correct it with:
sudo hwclock -w
```
if all went well, let's make the changes persistent:
```
echo rtc-ds1307 | sudo tee -a /etc/modules
echo 'echo ds1307 0x68 > /sys/class/i2c-adapter/i2c-1/new_device' | sudo tee -a /etc/rc.local
echo 'sudo hwclock -s' | sudo tee -a /etc/rc.local
```


## Replacing timesyncd With chrony on the Server

<span class="small">resources:
[systemd-timesyncd](https://wiki.archlinux.org/title/Systemd-timesyncd),
[chrony](https://chrony-project.org),
[apt](https://linux.die.net/man/8/apt)
</span>

The first thing we need to do is stop and disable `systemd-timesyncd`.

```
sudo systemctl disable --now systemd-timesyncd
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
server 127.127.1.1  #sync to local server
local stratum 8     #allow much variance before errors are thrown
allow all           #host server for nodes
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

Repeat the above process to stop, disable, and uninstall `systemd-timesyncd`. When installing `chrony`. Do not do this on **'pi-hpc-terminal'**.

You can use `pdsh` from **'pi-hpc-head01'** to issue commands to the compute nodes all at once. Instead of `apt remove`, you will need to use `apt-get -y remove` as `pdsh` is non-interactive. The nodes are configured in a way that you will be allowed to use `sudo`.

Since this is the first time we're using pdsh, let's make sure that the node definitions in `/etc/genders` are correct. The only changes you should make are the numbers for nodes. Also, if storage nodes aren't present, comment out the line for storage

```
pdsh -g nodes hostname
```

On each of the "client" nodes, you'll need to edit `/etc/chrony/chrony.conf` to be the following:

```
driftfile /var/lib/chrony/chrony.drift
server 10.0.0.2 iburst
```

Note: here, `iburst` is very important; it tells chrony to immediately sync with the server upon boot.

Because `pdsh` is not interactive, you will have to end up logging into each node individually to edit those files. However, the config file has been shared under `/apps/configs` - you can use `pdsh` to copy that file where it needs to be.

```
pdsh -g nodes sudo cp /apps/configs/chrony-client.conf /etc/chrony/chrony.conf
```

Since this is the first time the nodes will have a timesync since they've been booted it, they'll be very off. You can force them to set the time to the server's time immediately by issuing:
```
pdsh -g nodes "sudo chronyc makestep"
```

Once everybody is pretty much within 0 seconds of NTP time, we're ready for the next module.

## [Module 7 - The Scheduler](module-7)
