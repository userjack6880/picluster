page
Module 4 - Supporting Software
Install Open MPI and mpi4py

---

# Module 4 - Supporting Software

## Objective

**Install Open MPI and `mpi4py`**

Now that Slurm is installed, we need ways to program in a parallel clustered fashion. The [Message Passing Interface](https://en.wikipedia.org/wiki/Message_Passing_Interface) (MPI) is a standardized and portable standard that's designed to function on parallel computing architectures for C, C++, and Fortran. Additionally, there are packages available that extend this to other langauges, such as [Python](https://www.python.org).

## Install Open MPI on Head Node

<span class="small">resources:
[Open MPI](https://www.open-mpi.org)
</span>

Open MPI is an open source implementation of the Message Passing Interface developed and maintained by a consortium of academic, research, and industry parnters. It is commonly available on a lot of clusters.

Install OpenMPI and supporting packages, including development packages:

```
sudo dpkg -i /apps/pkgs/openmpi/*.deb
```

## Install mpi4py on Head Node

<span class="small">resources:
[mpi4py](https://mpi4py.readthedocs.io),
[pip](https://pip.pypa.io/en/stable/),
[gzip](https://linux.die.net/man/1/gzip),
[tar](https://linux.die.net/man/1/tar),
[python](https://linux.die.net/man/1/python)
</span>

`mpi4py` gives Python the ability to exploit MPI and makes Python practical for cluster computing. Since we won't have direct access to the web, `pip` will not be available, and we will need to manually build and install `mpi4py`.

The source files have already been downloaded and are located under `/apps/src/mpi4py`. Extract the files:

```
gzip -d mpi4py*.tar.gz
tar -xf mpi4py*.tar
```

Now go into the directory that was just created and build `mpi4py`:

```
python setup.py build
```

This will take a while. Once it completes, install using `sudo`:

```
sudo python setup.py install
```

## Install Packages on Compute Nodes

Perform the above steps using what you've learend in past modules using `pdsh`. Additionally, `srun` is now available to you.

*Note: you do not need to extract or build* `mpi4py` *again since it was already extracted and built in a shared directory. Since the architecture on all the nodes are the same, you can simply install it.*

## [Next Module - Hello Worlds](module-5)
