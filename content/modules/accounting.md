page
Module 6 - User Management
Configuring FreeIPA to manage users accross the picluster

---

# Module 6 - User Management

## Objective: Setting up LDAP to manage users

<span class="small">resources:
[FreeIPA Quickstart](https://www.freeipa.org/page/Quick_Start_Guide)
[FreeIPA Docs Home](https://www.freeipa.org/page/Documentation.html)
</span>

Lightweight Directory Access Protocol (LDAP) is the defacto standard for enterprises to manage users across devices and platforms. 
In our cluster, we want to be able to add, delete, and modify users and have those changes be reflected across all nodes. 
Since the picluster is an emulation of best practice in HPC, we'll be using the industry standard: FreeIPA.

## Concepts

LDAP requires fully qualified domain names (FQDN) for each node. 
These take the form of `hostname.subdomain(optional).domain`. 
The FQDN's for each supported node in the picluster have been populated in `/etc/hosts/` on the head node. 
Since the picluster is only using `/etc/hosts` and not expecting inbound traffic, we'll use `.pi.local`to denote it's only local.

## Installing the Server

Installation is very simple: the head node needs the `ipa-server` package and the nodes need the `ipa-client` package.

As root, install the server package on the head node:

```bash
rpm --install --verbose /apps/pkgs/ipa-server/*.rpm
```

## Configuring DNSMASQ

Since we're working on a local network without internet, we'll need to setup DNS accordingly, replace the contents of `/etc/dnsmasq.conf` with the following:

```bash
no-resolv #don't use /etc/resolve since it points to dnsmasq
#server=8.8.8.8 #add google's dns for when external connected
user=dnsmasq
group=dnsmasq
bind-interfaces
conf-dir=/etc/dnsmasq.d,.rpmnew,.rpmsave,.rpmorig
```

Then enable it now with:

```bash
systemctl enable --now dnsmasq
```

## Configuring the Server

Next, we need to configure LDAP. 
In the past, this has required quite a bit of knowledge, forethought, and understanding. 
Thankfully, FreeIPA provides a script that asks a few questions and sets everything up with good defaults. 
Since our use case is very limited, these defaults are perfect.

As root, run the following:

```bash
ipa-server-install --mkhomedir
```

**Notes:**
- This script will ask a few questions. 
We'll be using all defaults here so whenever a question has a bracketed answer, hit enter.
- The password is up to you but I recommend using the one we've been using: `tuxcluster`. 
You'll need to enter this 4 times.
- At the end, the script will prompt you to confirm the setup before continuing. 
The default is [no] so you must type yes.
- The server install process can take some time.

## Adding a User

Once the server is up and running, we'll need to add users.

```bash
kinit admin # the password is as entered before: tuxcluster
ipa config-mod --defaultshell=/bin/bash # this only needs to be run once, to set bash as the default shell
ipa user-add <your username>
ipa passwd <your username>
# enter a temporary password
```

The next time you logon as the user, you'll be prompted to set your preferred password.

## Signing into the WebGUI (Optional)

Along with the CLI, FreeIPA provides an intuitive Web-based Graphical User Interface (WebGUI) to manage the system.
The WebGUI is available at [http://pi-hpc-head01.pi.local](http://pi-hpc-head01.pi.local), however, since the dns server is local to the pi's you'll have to do a little configuration to access it.

According to whether your client is running, Windows, MacOS, or Linux, you'll have to follow different instructions.

**For Linux and MacOS:**
- Add the following line to `/etc/hosts`:

```bash
10.0.0.2 pi-hpc-head01.pi.local
```

**For Windows:**

- Open Notepad as Administrator: Press Win + R, type notepad and press Ctrl + Shift + Enter to run Notepad with administrative privileges. 
Alternatively, right-click on Notepad in the Start menu and select “Run as administrator”.
- Open the Hosts File: In Notepad, go to File > Open. 
Navigate to C:\Windows\System32\drivers\etc and select hosts. 
Ensure “All Files” is selected as the file type, as the hosts file does not have an extension.
- Add the following entry to the end

```bash
10.0.0.2 pi-hpc-head01.pi.local
```

- Save the File: After making changes, click File > Save to save the file. You may need to save it again if Notepad warns that the file has been modified by another program.

Once completed, use a browser to navigate to [pi-hpc-head01.pi.local](pi-hpc-head01.pi.local). 
Login with the Username:password of admin:tuxcluster. 
Instructions can be read from [their docs](https://www.freeipa.org/page/Documentation.html)

## Module 7 - The Scheduler
