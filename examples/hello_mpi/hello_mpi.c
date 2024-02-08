#include <stdio.h>
#include <mpi.h>

int main(int argc, char** argv) {
  int node;
  MPI_Init(&argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &node);

  // this is the stuff that's parallelized
  printf("Hello World from compute node %d!\n", node);

  MPI_Finalize();
}