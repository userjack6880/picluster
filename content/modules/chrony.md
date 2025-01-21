page
Keeping Time
Set up chrony to keep time.

---

# Keeping Time

## Objective: Setup chronyd to keep time

Because of the intercommunication between storage, compute, and head nodes, it's important that every node in the system is in lockstep with each other. An additional complication with our setup is that not only is it isolated from the internet (so it can't grab the time automatically), Raspberry Pi 4's and Pi Zero's do not have a hardware clock, so we'll have to add one.

Our goal is to setup a time server and have every node sync time with it using the [NTP](https://en.wikipedia.org/wiki/Network_Time_Protocol) protocol. While Rocky comes with `systemd-timesyncd`, we're going to replace it with `chrony` as it can act as both a NTP server(head) and client(nodes).

## Selecting the Time Server

Before we put hands on keyboards, we need to think about which node should be the time server. Off the bat, a compute or storage node is not appropriate - these should dedicate resources to performing calculations or providing high-speed storage. Furthermore, these nodes will be wiped every boot. In our setup, this leaves us with the head node. This node will need to be the first one to be turned on, and should always be properly shutdown.

## Setting the Time

<span class="small">resources:
[timedatectl](https://www.freedesktop.org/software/systemd/man/timedatectl.html),
[grep](https://linux.die.net/man/1/grep)
</span>

You can check the current status of the time by using `timedatectl`.

The time zone should automatically be set, but if it isn't, you can set it:

```bash
sudo timedatectl set-timezone <time zone>
```

If you are unsure what time-zones are available, use `timedatectl list-timezones` to list out all available time-zones - `grep` can be useful for narrowing the list down.

The time is set using:

```bash
# if an ntp server is already running, stop if first with:
sudo systemctl stop systemd-timesyncd
# then change the time w/
sudo timedatectl set-time "YYYY:MM:DD HH:mm:ss"
# or individually with: 
sudo timedatectl set-time "YYYY:MM:DD"
sudo timedatectl set-time "HH:mm:ss"
# finally remember to start the NTP service again w/:
sudo systemctl start systemd-timesyncd
```

The examples above show that you can either give it a full timestamp or a partial one. Keep in mind that time is represented using **24-hour time**. You don't want to be 12 hours off!

## Using the Hardware Clock

### RaspberryPi 4b

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

```bash
sudo dnf update && sudo apt install i2c-tools
i2cdetect -y 1
```

You should see ID #68 present

Now let's enable it with:

```bash
sudo modprobe rtc-ds1307
echo ds1307 0x68 | sudo tee /sys/class/i2c-adapter/i2c-1/new_device
sudo hwclock -r
# if the rtc hasn't been used before. It should return jan 1, 2000. Ensure the system time is correct and correct it with:
sudo hwclock -w
```

if all went well, let's make the changes persistent:

```bash
echo rtc-ds1307 | sudo tee -a /etc/modules
echo 'echo ds1307 0x68 > /sys/class/i2c-adapter/i2c-1/new_device' | sudo tee -a /etc/rc.local
echo 'sudo hwclock -s' | sudo tee -a /etc/rc.local
```

### RaspberryPi 5
<!-- TODO: RPi 5 HW Clock -->

## Replacing timesyncd With chrony on the Server

<span class="small">resources:
[systemd-timesyncd](https://wiki.archlinux.org/title/Systemd-timesyncd),
[chrony](https://chrony-project.org),
[apt](https://linux.die.net/man/8/apt)
</span>

The first thing we need to do is stop and disable `systemd-timesyncd`.

```bash
sudo systemctl disable --now systemd-timesyncd
```

Now uninstall it using dnf and then install the `chrony` package via rpm.

```bash
sudo dnf remove systemd-timesyncd
sudo dnf install /apps/pkgs/chrony/*.rpm
```

next we'll need to do some configuration. First, stop `chrony`.

```bash
sudo systemctl stop chronyd
```

Now edit `/etc/chrony/chrony.conf`. Clear all lines and make sure it only contains these lines:

```bash
driftfile /var/lib/chrony/chrony.drift
server 127.127.1.1  #sync to local server
local stratum 8     #allow much variance before errors are thrown
allow all           #host server for nodes
```
<!-- TODO: add an internet timesync server for head to sync w/ when connected to internet -->

The IP address `127.127.1.1` is the loopback address for NTP. You are telling `chrony` to sync with the system's clock driver. This isn't considered best practice, but for our purposes, it'll do the trick. Now restart `chrony`.

```bash
sudo systemctl start chronyd
```

You can check the status of `chrony` using `chronyc tracking` and see if it's actually using the loopback address with `chronyc sources`.

## Replacing timesyncd With chrony on the Nodes

<span class="small">resources:
[pdsh](https://linux.die.net/man/1/pdsh),
[grep](https://linux.die.net/man/1/grep)
</span>

Enter the Node container chroot:

```bash
sudo wwctl container exec base-rocky9-dracut /bin/bash
```

**Note:** while in the warewulf container chroot, the exit status of the last command deterines whether the changes are commited. This can be viewed in the prompt, either "write" or "exit"

Repeat the above process to stop, disable, and uninstall `systemd-timesyncd`. and to install `chrony`. 

Next, you'll need to edit `/etc/chrony/chrony.conf` to be the following:

```bash
driftfile /var/lib/chrony/chrony.drift
server 10.0.0.2 iburst
```

Note: here, `iburst` is very important; it tells chrony to immediately sync with the server upon boot.

Now `exit` the container and wait for it to rebuild, and reboot the nodes

Once everybody is booted and pretty much within 0 seconds of NTP time, we're ready for the next module.

## [Next Module - Scheduling Processes](slurm)
