page
Supporting Software
Installing OpenMPI and mpi4py

---

# Module 8 - Supporting Software

## Objective

**Install Open MPI and `mpi4py`**

Now that Slurm is installed, we need ways to program in a parallel clustered fashion. The [Message Passing Interface](https://en.wikipedia.org/wiki/Message_Passing_Interface) (MPI) is a standardized and portable standard that's designed to function on parallel computing architectures for C, C++, and Fortran. Additionally, there are packages available that extend this to other langauges, such as [Python](https://www.python.org).

## Install Open MPI on Head Node

<span class="small">
[Open MPI](https://www.open-mpi.org)
</span>

<!-- TODO: Building OpenMPI -->

Open MPI is an open source implementation of the Message Passing Interface(MPI) standard developed and maintained by a consortium of academic, research, and industry parnters. It is commonly available on a lot of clusters.

While it's possible to install the binary release from the distribution repository, this is a rapidly evolving field, and as such, it's recommended to build it from source. Furthermore, since we are using slurm, building openmpi with slurm allows a number of integrations the standalone binary lacks. Finally, manually building also allows us to place the binaries in a location accessible to all nodes, that way we only need to install once.

## Building OpenMPI from source (Recommended)

The source tarball for the latest release of OpenMPI as of head-node creation is located in `/apps/src/openmpi`

As a non-elevated user in a directory of your choice:

```bash
# extract the tarball and enter dir
tar -xf /apps/src/openmpi/*.tar.*
cd openmpi*
# configure w/ required options
CC=gcc CXX=g++ ./configure --with-slurm --enable-shared --prefix=/apps/openmpi
# build and install
make -j4
sudo make install
# add our custom install dir to the path
echo 'PATH=$PATH:/apps/openmpi/bin' | sudo tee /etc/profile.d/openmpi.sh
```

# Installing OpenMPI from distro repo's (Not Recommended)

Install OpenMPI and supporting packages, including development packages:

```bash
sudo rpm install /apps/pkgs/openmpi/*.rpm
```

**Note: this will also need to be installed in the compute node image. Instructions [Here](ww)**

## (Optional) Install mpi4py on Head Node

<span class="small">resources:
[mpi4py](https://mpi4py.readthedocs.io),
[pip](https://pip.pypa.io/en/stable/),
[gzip](https://linux.die.net/man/1/gzip),
[tar](https://linux.die.net/man/1/tar),
[python](https://linux.die.net/man/1/python)
</span>

`mpi4py` gives Python the ability to exploit MPI and makes Python practical for cluster computing. Since we won't have direct access to the web, `pip` will not be available, and we will need to manually build and install `mpi4py`.

The source files have already been downloaded and are located under `/apps/src/mpi4py`. Extract the files:

```bash
gzip -d mpi4py*.tar.gz
tar -xf mpi4py*.tar
```

Now go into the directory that was just created and build `mpi4py`:

```bash
python setup.py build
```

This will take a while. Once it completes, install using `sudo`:

```bash
sudo python setup.py install
```

## [Next Module - Hello World(s)!](hello-world)
