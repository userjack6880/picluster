page
Scheduling Processes
Build and install slurm packages.

---

# Scheduling Processes

## Objective

### The Scheduler

[Slurm Workload Manager](https://schedmd.com), or simply Slurm, allocates resources to users for a duration of time, provides a framework for starting, executing, and monitoring work, and manages a queue of pending jobs. Slurm is essentially the de-facto job scheduler for Linux and is used by most of the world's supercomputers, this guide will show you how to install it on your own cluster.

## Install MariaDB on the Head Node

<span class="small">resources:
[mariadb](https://mariadb.org/documentation/)
</span>

While Slurm does work without MariaDB, it's fairly common to set it up to use MariaDB as it's useful for archiving account records and easily accessing these records.

```bash
sudo dnf install /apps/pkgs/mariadb-server/*.rpm
```

Note: `dnf` may complain about failures the first time you run this - running it a second time will usually be successful.

## Install Slurm on the Head Node

The head node will be responsible for accepting jobs from users, scheduling jobs on the cluster, and keeping a record of all jobs that ran. Packages installed are `slurm`, `slurmdbd`, and `slurmctld` and their dependencies.

```bash
sudo dnf install /apps/pkgs/slurm-head/*.rpm
```

## Setup Munge

I gotta be honest. I pulled a sneaky on ya'. when you installed the slurm packages, I snuck munge in as well. Munge is a cryptographic authentication suite that uses a "key" and the current time. we need to create a key before slurm will start. thankfully the folks who make munge were kind enough to include a script. as root, run the following

```bash
create-munge-key
```

## Setup Slurm

<span class="small">resources:
[slurmd](https://man.archlinux.org/man/slurmd.8.en),
[Slurm control group](https://slurm.schedmd.com/cgroups.html)
</span>

Copy then extract the example template config file to `/etc/slurm` as root

```bash
cp /usr/share/doc/slurm-client/examples/slurm.conf.simple.gz /etc/slurm
gzip -d /etc/slurm/slurm.conf.simple.gz
mv /etc/slurm/slurm.conf.simple /etc/slurm/slurm.conf
```

Now edit the config to reflect your configuration (only *changed and added lines* are shown):

```conf
## General
SlurmctldHost=pi-hpc-head01
MpiDefault=pmi2
# ^- this will need to be updated to pmix
ProctrackType=proctrack/linuxproc

## Logging and Accounting
AccountingStorageHost=pi-hpc-head01
AccountingStoragePort=6819
AccountingStorageType=accounting_storage/slurmdbd
ClusterName=<your_cluster_name>
JobAcctGatherType=jobacct_gather/linux

## Compute Nodes
NodeName=pi-hpc-head01 CPUs=<num_cpus> Sockets=<sockets> CoresPerSocket=<num_cores> ThreadsPerCore=<threads> RealMemory=<memory> State=UNKNOWN
NodeName=pi-hpc-compute[01-04] CPUs=<num_cpus> Sockets=<sockets> CoresPerSocket=<num_cores> ThreadsPerCore=<threads> RealMemory=<memory> State=UNKNOWN
PartitionName=<partition_name> Nodes=pi-hpc-compute[01-04] Default=YES MaxTime=INFINITE State=UP
```

We won't go into too much detail about what all the options mean just yet. The goal is to get the cluster working. You may chose what you want to call your cluster and what the default partition is called.

To get the values for `NodeName`, you can run `/usr/sbin/slurmd -C` on the compute nodes and get those values. Multiple `NodeName` entries can be added if your cluster has different architectures.

Finally, we need to create the `/etc/slurm/slurmdbd.conf` file for the Slurm database:

```conf
AuthType=auth/munge
DbdHost=pi-hpc-head01
DbdPort=6819
SlurmUser=slurm
DebugLevel=verbose
LogFile=/var/log/slurmdbd.log
PidFile=/var/run/slurmdbd.pid
StorageType=accounting_storage/mysql
StoragePass=<slurmdb_password>
StorageUser=slurm
StorageLoc=slurm_acct_db
```

You can set the `StoragePass` password to be anything you want. Just remember what this is. Now, change the permissions of `slurmdbd.conf` to read/writeable only by the `slurm` user:

```bash
chown slurm:slurm /etc/slurm/slurmdbd.conf
chmod 600 /etc/slurm/slurmdbd.conf
```

Now copy the slurm config to where all of the nodes can see it:

```bash
cp /etc/slurm/slurm.conf /shared/slurm.conf
cp /etc/munge/munge.key /shared/munge.key
```

## Install Slurm on the Compute Nodes

Use the following command to enter the compute node container chroot with the right binds:

```bash
sudo su
wwctl container exec --bind /shared:/shared base-rocky9-dracut /bin/bash
```

Inside the warewulf contianer chroot, install the required packages.

```bash
rpm --install --verbose --force /apps/pkgs/slurm-compute/*.rpm 
```

Now, move the slurm config files and the munge key to their respective places:

```bash
cp /shared/slurm.conf /etc/slurm/slurm.conf
cp /shared/munge.key /etc/munge/munge.key
chown munge:munge /etc/munge/munge.key
chmod 600 /etc/munge/munge.key
```

Enable the services so that they start on boot:

```bash
systemctl enable slurmd
```

And finally, exit and rebuild the contianer with `exit`

## Copy Munge Key to Nodes

<span class="small">resources:
[munge](https://linux.die.net/man/7/munge)
</span>
To provide the necessary authentication between thea head node and compute nodes, all nodes will need the same `munge.key`. Copy the files to the nodes and restart `munge` on all the nodes.

## Setup Slurm Database

First, log into `mysql` as `root`:

```bash
mysql
```

The prompt should now show `MariaDB [(none)]> `. Create the `slurm_acct_db`:

```bash
create database slurm_acct_db;
```

Confirm that it was created:

```bash
show databases;
```

Now create the `slurm` mysql user and set the password (use the one you used to configure `/etc/slurm/slurmdbd.conf`):

```bash
create user 'slurm'@'localhost';
set password for 'slurm'@'localhost' = password('<yourpassword>');
```

Grant this user privileges for `slurm_acct_db`:

```bash
grant all privileges on slurm_acct_db.* to 'slurm'@'localhost';
```

You can exit out using `exit` (semi-colon is not needed). Now, check to see if the `slurm` user is able to log in and see the database.

```bash
mysql -u slurm -p
```

Type in your password, and if you able to get the `MariaDB [(none)]> ` prompt, then show databases again.

```bash
show databases;
```

Your output should be:

```sql
+--------------------+
| Database           |
+--------------------+
| information_schema |
| slurm_acct_db      |
+--------------------+
2 rows in set (0.002 sec)
```

And finally:

```bash
exit;
```

## Start Slurm on the Head Node

If everything is good, then the following should work.

```bash
systemctl enable slurmdbd slurmctld 
systemctl start slurmdbd slurmctld 
```

If you encounter errors, you can look at `systemctl status [service]`, where `[service]` is either `slurmd`, `slurmctld`, `slurmdbd`. Additionally, there should be logs under `/var/log/slurm`. 

Finally, setup accounting and create the cluster within `sacctmgr`. It may already be created and give you an error. This is fine.

```bash
sacctmgr -i add cluster <your cluster name>
```

## Start Slurm on the Compute Nodes

<span class="small">resources:
[srun](https://slurm.schedmd.com/srun.html)
</span>

Reboot the nodes with the updated image. Slurm should start automatically. In the case that thye need to be nanully restarted, run the following:

```bash
sudo pdsh -g nodes systemctl start slurmd
```

If all is good, the output of `sinfo -Nl` should look like the following:

```sql
NODELIST          NODES PARTITION       STATE CPUS    S:C:T MEMORY TMP_DISK WEIGHT AVAIL_FE REASON              
pi-hpc-compute01      1   pi-hpc*        idle 4       1:4:1   3794        0      1   (null) none                
pi-hpc-compute02      1   pi-hpc*        idle 4       1:4:1   3794        0      1   (null) none                
pi-hpc-compute03      1   pi-hpc*        idle 4       1:4:1   3794        0      1   (null) none                
pi-hpc-compute04      1   pi-hpc*        idle 4       1:4:1   3794        0      1   (null) none 
```

Finally, you should be able to run commands on the compute ndoes without using `pdsh`:

```bash
srun --nodes=4 hostname
```

Output should look like this:

```bash
pi-hpc-compute02
pi-hpc-compute01
pi-hpc-compute03
pi-hpc-compute04
```

## [Next Module - Supporting Software](supporting-software)
