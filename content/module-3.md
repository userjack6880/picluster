page
Module 3 - Build and Install Slurm
Build slurm packages and install it.

---

# Module 3 - Setup Scheduler

## Objective

**Install, setup and configure Slurm**

[Slurm Workload Manager](https://schedmd.com), or simply Slurm, resources to users for a duration of time, provides a framework for starting, executing, and monitoring work, and manages a queue of pending jobs. Slurm is essentially the de-facto job scheduler for Linux and is used by most of the world's supercomputers, and you will be installing this on your own cluster.

## Install MariaDB on the Head Node

<span class="small">resources:
[mariadb](https://mariadb.org/documentation/)
</span>

While Slurm does work without MariaDB, it's fairly common to set it up to use MariaDB as it's useful for archiving account records and easily accessing these records.

```
sudo dpkg -i /apps/pkgs/mariadb-server/*.deb
```

Note: `dpkg` may complain about failures the first time you run this - running it a second time will usually be successful.

## Install Slurm on the Head Node

The head node will be responsible for accepting jobs from users, scheduling jobs on the cluster, and keeping a record of all jobs that ran. Packages installed are `slurm-wlm`, `slurmdbd`, and `slurm-client` and their dependencies.

```
sudo dpkg -i /apps/pkgs/slurm-head/*.deb
```

## Install Slurm on the Compute Nodes

From the head node, you can use `pdsh` to install required packages on the compute nodes.

```
pdsh -w pi-hpc-compute[01-04] sudo dpkg -i /apps/pkgs/slurm-compute/*.deb
```

## Setup Slurm

<span class="small">resources:
[slurmd](https://man.archlinux.org/man/slurmd.8.en),
[Slurm control group](https://slurm.schedmd.com/cgroups.html)
</span>

Copy then extract the example template config file to `/etc/slurm`.

```
sudo cp /usr/share/doc/slurm-client/examples/slurm.conf.simple.gz /etc/slurm
sudo gzip -d /etc/slurm/slurm.conf.simple.gz
sudo mv /etc/slurm/slurm.conf.simple /etc/slurm/slurm.conf
```

Now edit the config to reflect your configuration (only *changed and added lines* are shown):

```
## General
SlurmctldHost=pi-hpc-head01
MpiDefault=pmi2
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

```
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

```
sudo chown slurm:slurm /etc/slurm/slurmdbd.conf
sudo chmod 600 /etc/slurm/slurmdbd.conf
```

Now copy the slurm config to where all of the nodes can see it:

```
sudo cp /etc/slurm/slurm.conf /shared/slurm.conf
```

And on the nodes, move these files to their respective places:

```
pdsh -w pi-hpc-compute[01-04] sudo cp /shared/slurm.conf /etc/slurm/slurm.conf
```

## Copy Munge Key to Nodes

<span class="small">resources:
[munge](https://linux.die.net/man/7/munge)
</span>

To provide the necessary authentication between thea head node and compute nodes, all nodes will need the same `munge.key`. Copy the files to the nodes and restart `munge` on all the nodes.

```
sudo cp /etc/munge/munge.key /shared/munge.key
pdsh -w pi-hpc-compute[01-04] sudo cp /shared/munge.key /etc/munge/munge.key
pdsh -w pi-hpc-compute[01-04] sudo chown munge:munge /etc/munge/munge.key
pdsh -w pi-hpc-compute[01-04] sudo chmod 600 /etc/munge/munge.key
pdsh -w pi-hpc-compute[01-04] sudo systemctl restart munge
```

## Setup Slurm Database

First, log into `mysql` as `root`:

```
sudo mysql
```

The prompt should now show `MariaDB [(none)]> `. Create the `slurm_acct_db`:

```
create database slurm_acct_db;
```

Confirm that it was created:

```
show databases;
```

Now create the `slurm` mysql user and set the password (use the one you used to configure `/etc/slurm/slurmdbd.conf`):

```
create user 'slurm'@'localhost';
set password for 'slurm'@'localhost' = password('<yourpassword>');
```

Grant this user privileges for `slurm_acct_db`:

```
grant all privileges on slurm_acct_db.* to 'slurm'@'localhost';
```

You can exit out using `exit` (semi-colon is not needed). Now, check to see if the `slurm` user is able to log in and see the database.

```
mysql -u slurm -p
```

Type in your password, and if you able to get the `MariaDB [(none)]> ` prompt, then show databases again.

```
show databases;
```

Your output should be:

```
+--------------------+
| Database           |
+--------------------+
| information_schema |
| slurm_acct_db      |
+--------------------+
2 rows in set (0.002 sec)
```

## Start Slurm on the Head Node

If everything is good, then the following should work.

```
sudo systemctl enable slurmd slurmctld slurmdbd
sudo systemctl start slurmd slurmctld slurmdbd
```

If you encounter errors, you can look at `systemctl status [service]`, where `[service]` is either `slurmd`, `slurmctld`, `slurmdbd`. Additionally, there should be logs under `/var/log/slurm`. 

Finally, setup accounting and create the cluster within `sacctmgr`. It may already be created and give you an error. This is fine.

```
sudo sacctmgr -i add cluster <your cluster name>
```

## Start Slurm on the Compute Nodes

<span class="small">resources:
[srun](https://slurm.schedmd.com/srun.html)
</span>

As with above, this should work:

```
pdsh -w pi-hpc-compute[01-04] sudo systemctl enable slurmd
pdsh -w pi-hpc-compute[01-04] sudo systemctl start slurmd
```

If all is good, the output of `sinfo -N -l` should look like the following:

```
NODELIST          NODES PARTITION       STATE CPUS    S:C:T MEMORY TMP_DISK WEIGHT AVAIL_FE REASON              
pi-hpc-compute01      1   pi-hpc*        idle 4       1:4:1   3794        0      1   (null) none                
pi-hpc-compute02      1   pi-hpc*        idle 4       1:4:1   3794        0      1   (null) none                
pi-hpc-compute03      1   pi-hpc*        idle 4       1:4:1   3794        0      1   (null) none                
pi-hpc-compute04      1   pi-hpc*        idle 4       1:4:1   3794        0      1   (null) none 
```

Finally, you should be able to run commands on the compute ndoes without using `pdsh`:

```
sudo srun --nodes=4 hostname
```

Output would look like this:

```
pi-hpc-compute02
pi-hpc-compute01
pi-hpc-compute03
pi-hpc-compute04
```

## [Next Module - Supporting Software](module-4)
