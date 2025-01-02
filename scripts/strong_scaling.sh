#!/bin/bash
# Parameters
N=1024 # iterations
GRID_SIZE=400
# T=100  # iterations
MAX_PROCS=16 # Maximum number of processes
PROGRAM=./apf # Replace with your program's executable name
FILENAME='data_strong_scaling.csv'
# Strong scaling study
for P in 1 2 4 8 16; do
    echo "Running with P=$P processes..."
    # Try different processor geometries
    for px in $(seq 1 $P); do
        if (( P % px == 0 )); then
            py=$((P / px)) # Calculate corresponding py
            echo "  Testing geometry px=$px, py=$py..."
            export OMP_NUM_THREADS=1 && mpirun -np $P $PROGRAM -o $FILENAME -n $GRID_SIZE  -i $N -x  $px -y $py
        fi
    done
done

echo "Strong scaling study completed."
