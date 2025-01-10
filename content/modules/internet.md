page
Internet Access


---

# Internet Access

## Objective

while the clutser was designed to be used offline, there is an easy way to setup an internet connection on the head node to pull files for projects, etc.

## Host configuration:
the easiest way to get internet on the cluster is to share a client computer's (Currently LINUX only) internet with the picluster. This is achieved by setting up ip forwarding and a NAT on the client

While having it connected to the cluster via ethernet (currently not easy to do WiFi->WiFi), issue the following commands ***OR*** run [this](placeholder) script as root:
```
TODO: placeholder
ip a add 10.0.0.2 dev eth0
```

## Head Node Config
The Head node is already configured to look for a default route at 10.0.0.1 so no further configuration is necessary

## Testing an Internet Connection:
Run the following command to test for an uplink:
```
ping 1.1.1.1 -c1
```
If that doesn't return "unreachable", then run this command to check DNS:
```
ping google.com
```
If all goes well, internet is setup 
