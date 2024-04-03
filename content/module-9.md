page
Module 5 - Hello Worlds
Helloing all over the cluster.

---

# Module 5 - Hello Worlds

## Objective

**Implement the basic "hello world" program using C and Python**

There are many ways to tackle a problem. Even a basic "hello world" program that runs across multiple compute nodes can have more than one way to solve it. Two examples will be shown.

## Implementing Hello World with C

<span class="small">resources:
[mpicc](https://www.open-mpi.org/doc/v4.0/man1/mpicc.1.php),
[sbatch](https://slurm.schedmd.com/sbatch.html)
</span>

Log in as the `user` user instead of `admin` this time. Under `/shared`, create a new directory (you can name it something like `hello_mpi_c` or `hello_world_c`). Change to this directory and create a new file, `hello_mpi.c`:

```
#include <stdio.h>
#include <mpi.h>

int main(int argc, char** argv) {
  int node;
  MPI_Init(&argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &node);

  // this is the stuff that's parallelized
  printf("Hello World from compute node: %d!\n", node);

  MPI_Finalize();
}
```

Now, compile the program.

```
mpicc hello_mpi.c
```

This should create a new file called `a.out`. This is your program. Finally, create a shell script used to submit this program to Slurm (name it `sub_mpi.sh`):

```
#!/bin/bash

cd $SLURM_SUBMIT_DIR

# print the hostname of the submission node
echo "submitted from $(hostname)"

# run the program
mpirun a.out
```

Finally, submit a new job to the cluster.

```
sbatch --nodes=4 --ntasks-per-node=4 sub_mpi.sh
```

This should submit a job, and it should return "Hello World" 16 times with a different number after the phrase.

## Implementing Hello World with Python

<span class="small">resources:
[mpirun](https://www.open-mpi.org/doc/current/man1/mpirun.1.php)
</span>

Create a new directory under `/shared` like you did before, but use a different name to indicate that it's a python application. Create a new file `hello_mpi.py`:

```
#!/usr/bin/env python

from mpi4py import MPI
import sys

size = MPI.COMM_WORLD.Get_size()
rank = MPI.COMM_WORLD.Get_rank()
name = MPI.Get_processor_name()

sys.stdout.write(
  "Hello World! I am process %d of %d on %s.\n"
  % (rank, size, name))
```

Copy the `sub_mpi.sh` you made for the C program into this directory, and edit the last line:

```
mpirun python hello_mpi.py
```

Submit the job to the cluster:

```
sbatch --nodes=4 --ntasks-per-node=4 sub_mpi.sh
```

As before, you should see "Hello World" return 16 times.

## MPI Examples

MPI examples can be found on the [LLNL HPC Tutorials Page](https://hpc-tutorials.llnl.gov/mpi/exercise_1/). Experiment and run a few of these examples.

## [Next Module - Parallel Storage](module-6)
