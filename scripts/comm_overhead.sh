#!/bin/bash
# Parameters
N=1024               # Initial problem size
GRID_SIZE=400        # Grid size
SHRINK_FACTOR=1.4    # Factor to shrink N (sqrt(2))
PROGRAM=./apf        # Replace with your program's executable name
OVERHEAD_THRESHOLD=25 # Per-process communication overhead threshold (%)
REPEATS=5            # Number of repetitions for averaging
OUTPUT_FILE="data/data_comm_overhead.csv" # Final results file
WITH_COMM_FILE="with_comm.csv"            # CSV file for results with communication
WITHOUT_COMM_FILE="without_comm.csv"      # CSV file for results without communication

# Ensure the data directory exists
mkdir -p data

# Create or clear the output file
echo "Number of Cores,Geometry,Avg GFlops,Avg Communication Overhead (seconds),Avg Communication Overhead (%),Avg Running Time (seconds)" > $OUTPUT_FILE

# Strong scaling study for specific processor counts and geometries
for P in 4 8 16 24; do
    echo "Running with P=$P processes..."

    # Set geometry for P processes (x=1, y=P)
    px=1
    py=$P

    # Reinitialize N for each processor count
    current_N=$N

    # Loop until N becomes too small or overhead threshold is met
    while (( $(echo "$current_N > 1" | bc -l) )); do
        echo "  Testing geometry px=$px, py=$py, N=$current_N..."

        # Initialize accumulators for averaging
        total_time_with=0
        total_time_without=0
        total_gflops_with=0

        # Run the experiment REPEATS times
        for ((i = 1; i <= REPEATS; i++)); do
            echo "    Repetition $i..."

            # Run the program with communication enabled
            export OMP_NUM_THREADS=1 && mpirun -np $P $PROGRAM -n $GRID_SIZE -i $current_N -x $px -y $py --output "$WITH_COMM_FILE"

            # Process results from WITH_COMM_FILE
            with_comm_line=$(awk -F, "NR > 1 {print}" "data/$WITH_COMM_FILE" | tail -1)
            time_with=$(echo "$with_comm_line" | awk -F, '{print $5}')
            gflops_with=$(echo "$with_comm_line" | awk -F, '{print $4}')
            total_time_with=$(echo "$total_time_with + $time_with" | bc)
            total_gflops_with=$(echo "$total_gflops_with + $gflops_with" | bc)

            # Run the program with communication disabled
            export OMP_NUM_THREADS=1 && mpirun -np $P $PROGRAM -n $GRID_SIZE -i $current_N -x $px -y $py --nocomm --output "$WITHOUT_COMM_FILE"

            # Process results from WITHOUT_COMM_FILE
            without_comm_line=$(awk -F, "NR > 1 {print}" "data/$WITHOUT_COMM_FILE" | tail -1)
            time_without=$(echo "$without_comm_line" | awk -F, '{print $5}')
            total_time_without=$(echo "$total_time_without + $time_without" | bc)
        done

        # Calculate averages
        avg_time_with=$(echo "scale=4; $total_time_with / $REPEATS" | bc)
        avg_time_without=$(echo "scale=4; $total_time_without / $REPEATS" | bc)
        avg_gflops_with=$(echo "scale=4; $total_gflops_with / $REPEATS" | bc)

        # Calculate communication overhead
        comm_overhead_seconds=$(echo "scale=4; $avg_time_with - $avg_time_without" | bc)
        comm_overhead_percent=$(echo "scale=4; 100 * $comm_overhead_seconds / $avg_time_with" | bc)

        # Save averaged results to the output file
        echo "$P,${px}x${py},$avg_gflops_with,$comm_overhead_seconds,$comm_overhead_percent,$avg_time_with" >> $OUTPUT_FILE

        echo "  Results saved: $comm_overhead_percent% overhead, $avg_time_with seconds running time"

        # Check if the communication overhead exceeds the threshold
        if (( $(echo "$comm_overhead_percent >= $OVERHEAD_THRESHOLD" | bc -l) )); then
            echo "Stopping: Communication overhead reached $comm_overhead_percent% (>= $OVERHEAD_THRESHOLD%)."
            break
        fi

        # Shrink N by sqrt(2)
        current_N=$(echo "scale=0; $current_N / $SHRINK_FACTOR" | bc)
    done
done

echo "Strong scaling study completed. Results saved to $OUTPUT_FILE."
