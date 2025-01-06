#!/bin/bash

# Parameters
N=1024 # iterations
GRID_SIZE=400
# T=100  # iterations
PROGRAM=./apf # Replace with your program's executable name
FILENAME1='data_strong_scaling_mpi_only.csv'
FILENAME2='data_strong_scaling_hybrid.csv'

# Strong scaling study: MPI Only

for P in 8 4 2; do
    echo "Running with P=$P processes MPI Only..."
    # only 1D
    echo "  Testing geometry px=1, py=$P..."
    export OMP_NUM_THREADS=1 && mpirun -np $P $PROGRAM -o $FILENAME1 -n $GRID_SIZE  -i $N -x  1 -y $P
done

# Strong scaling study: MPI+OpenMP
# for P in 8 4 2; do
#     echo "Running with $P MPI processes..."
#     echo "  Testing geometry px=1, py=$P..."
#     for OMP_THREADS in 2 4 8; do
#         echo "  Testing with OMP_NUM_THREADS=$OMP_THREADS..."
#         export OMP_NUM_THREADS=$OMP_THREADS && mpirun -np $P $PROGRAM -o $FILENAME2 -n $GRID_SIZE  -i $N -x  1 -y $P
#     done
# done
for OMP_THREADS in 2 4 8; do
    echo "Running with OMP_NUM_THREADS=$OMP_THREADS..."
    export OMP_NUM_THREADS=$OMP_THREADS
    for P in 8 4 2; do
        echo "  Testing with $P MPI processes..."
        echo "  Testing geometry px=1, py=$P..."
        mpirun -np $P $PROGRAM -o $FILENAME2 -n $GRID_SIZE -i $N -x 1 -y $P
    done
done
echo "MPI+OpenMP scaling study completed."
