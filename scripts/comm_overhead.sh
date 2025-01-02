#!/bin/bash
# Parameters
N=1024               # Initial problem size
GRID_SIZE=400        # Grid size
SHRINK_FACTOR=1.4    # Factor to shrink N (sqrt(2))
PROGRAM=./apf        # Replace with your program's executable name
OVERHEAD_THRESHOLD=25 # Stop when communication overhead >= 25%
OUTPUT_FILE="data/data_comm_overhead.csv" # Final results file
WITH_COMM_FILE="data/with_comm.csv"       # CSV file for results with communication
WITHOUT_COMM_FILE="data/without_comm.csv" # CSV file for results without communication

# Ensure the data directory exists
mkdir -p data

# Create or clear the output file
echo "Number of Cores,Geometry,GFlops,Communication Overhead (seconds),Communication Overhead (%),Running Time (seconds)" > $OUTPUT_FILE

# Initialize line tracking variables
WITH_COMM_TRACKED_LINE=1 # Start from line 1 (header is skipped with NR > 1)
WITHOUT_COMM_TRACKED_LINE=1

# Strong scaling study for specific processor counts and geometries
for P in 4 8 16 24; do
    echo "Running with P=$P processes..."

    # Set geometries based on P
    if [ "$P" -eq 4 ]; then
        px=2; py=2
    elif [ "$P" -eq 8 ]; then
        px=2; py=4
    elif [ "$P" -eq 16 ]; then
        px=2; py=8
    elif [ "$P" -eq 24 ]; then
        px=2; py=12
    else
        echo "Unsupported processor count: $P"
        continue
    fi

    # Loop until N becomes too small or overhead threshold is met
    current_N=$N
    while (( $(echo "$current_N > 1" | bc -l) )); do
        echo "  Testing geometry px=$px, py=$py, N=$current_N..."

        # Run the program with communication enabled
        export OMP_NUM_THREADS=1 && mpirun -np $P $PROGRAM -n $GRID_SIZE -i $current_N -x $px -y $py --output 'with_comm.csv'

        # Process new lines from WITH_COMM_FILE
        WITH_COMM_TOTAL_LINES=$(wc -l < "$WITH_COMM_FILE")
        if (( WITH_COMM_TOTAL_LINES > WITH_COMM_TRACKED_LINE )); then
            with_comm_line=$(awk -F, "NR > 1 && NR==$((WITH_COMM_TRACKED_LINE + 1)) {print}" $WITH_COMM_FILE)
            time_with=$(echo "$with_comm_line" | awk -F, '{print $5}')
            gflops_with=$(echo "$with_comm_line" | awk -F, '{print $4}')
            WITH_COMM_TRACKED_LINE=$WITH_COMM_TOTAL_LINES
        fi

        # Run the program with communication disabled
        export OMP_NUM_THREADS=1 && mpirun -np $P $PROGRAM -n $GRID_SIZE -i $current_N -x $px -y $py --nocomm --output 'without_comm.csv'

        # Process new lines from WITHOUT_COMM_FILE
        WITHOUT_COMM_TOTAL_LINES=$(wc -l < "$WITHOUT_COMM_FILE")
        if (( WITHOUT_COMM_TOTAL_LINES > WITHOUT_COMM_TRACKED_LINE )); then
            without_comm_line=$(awk -F, "NR > 1 && NR==$((WITHOUT_COMM_TRACKED_LINE + 1)) {print}" $WITHOUT_COMM_FILE)
            gflops_without=$(echo "$with_comm_line" | awk -F, '{print $4}')
            time_without=$(echo "$without_comm_line" | awk -F, '{print $5}')
            WITHOUT_COMM_TRACKED_LINE=$WITHOUT_COMM_TOTAL_LINES
        fi

        # Calculate communication overhead
        comm_overhead_seconds=$(echo "scale=2; $time_with - $time_without" | bc)
        comm_overhead_percent=$(echo "scale=2; 100 * $comm_overhead_seconds / $time_with" | bc)

        # Save results to the output file
        echo "$P,${px}x${py},$gflops_without,$comm_overhead_seconds,$comm_overhead_percent,$time_without" >> $OUTPUT_FILE

        echo "  Results saved: $comm_overhead_percent% overhead, $time_with seconds running time"

        # Check if the communication overhead exceeds the threshold
        if (( $(echo "$comm_overhead_percent >= $OVERHEAD_THRESHOLD" | bc -l) )); then
            echo "Stopping: Communication overhead reached $comm_overhead_percent% (>= $OVERHEAD_THRESHOLD%)."
            exit 0
        fi

        # Shrink N by sqrt(2)
        current_N=$(echo "scale=0; $current_N / $SHRINK_FACTOR" | bc)
    done
done

echo "Strong scaling study completed. Results saved to $OUTPUT_FILE."
