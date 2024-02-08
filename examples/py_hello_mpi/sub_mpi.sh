#!/bin/bash

cd $SLURM_SUBMIT_DIR

# print hostname of the submission node
echo "submitted from $(hostname)"

# run the program
mpirun python hello_mpi.py