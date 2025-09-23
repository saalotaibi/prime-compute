#!/bin/bash

# Prime Number Counting Experiment Automation Script
# This script automates the testing of serial and parallel prime counting
# with different thread counts and scheduling policies

# Configuration
N=200000000
THREAD_COUNTS=(2 4 6 8 16 18 20)
SCHEDULE_TYPES=("default" "static,1000" "dynamic,1000" "guided,1000")
RUNS_PER_CONFIG=3

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Prime Number Counting Experiment ===${NC}"
echo "Dataset size: $N elements"
echo "Runs per configuration: $RUNS_PER_CONFIG"
echo ""

# Compile programs
echo -e "${YELLOW}Compiling programs...${NC}"
gcc -O3 -fopenmp prime_serial.c -o prime_serial -lm
gcc -O3 -fopenmp prime_parallel.c -o prime_parallel -lm

if [ $? -ne 0 ]; then
    echo -e "${RED}Compilation failed!${NC}"
    exit 1
fi

echo -e "${GREEN}Compilation successful!${NC}"
echo ""

# Test serial version (baseline)
echo -e "${BLUE}=== Serial Baseline ===${NC}"
serial_times=()

for run in $(seq 1 $RUNS_PER_CONFIG); do
    echo -e "${YELLOW}Serial run $run/$RUNS_PER_CONFIG...${NC}"
    time_output=$(./prime_serial 2>/dev/null | grep "Execution time:" | awk '{print $3}')
    serial_times+=($time_output)
    echo "Time: $time_output seconds"
done

# Calculate serial average
serial_sum=0
for time in "${serial_times[@]}"; do
    serial_sum=$(echo "$serial_sum + $time" | bc -l)
done
serial_avg=$(echo "$serial_sum / $RUNS_PER_CONFIG" | bc -l)
echo -e "${GREEN}Serial average: ${serial_avg} seconds${NC}"
echo ""

# Create results file
results_file="experiment_results.txt"
echo "Prime Number Counting Experiment Results" > "$results_file"
echo "=====================================" >> "$results_file"
echo "Dataset size: $N elements" >> "$results_file"
echo "Runs per configuration: $RUNS_PER_CONFIG" >> "$results_file"
echo "Serial baseline average: $serial_avg seconds" >> "$results_file"
echo "" >> "$results_file"
echo "Performance Comparison Table:" >> "$results_file"
echo "" >> "$results_file"

# Print table header
printf "%-12s %-18s %-20s %-25s\n" "Threads" "Schedule" "Avg Time (s)" "Notes"
printf "%-12s %-18s %-20s %-25s\n" "--------" "--------" "------------" "-----"
echo ""

# Test parallel versions
for threads in "${THREAD_COUNTS[@]}"; do
    for schedule in "${SCHEDULE_TYPES[@]}"; do
        echo -e "${BLUE}Testing: ${threads} threads, ${schedule}${NC}"
        times=()

        for run in $(seq 1 $RUNS_PER_CONFIG); do
            echo -e "${YELLOW}Run $run/$RUNS_PER_CONFIG...${NC}"

            # Set environment variables
            export OMP_NUM_THREADS=$threads

            # Run with appropriate schedule
            if [ "$schedule" = "default" ]; then
                time_output=$(./prime_parallel 2>/dev/null | grep "Execution time:" | awk '{print $3}')
            else
                export OMP_SCHEDULE="$schedule"
                time_output=$(./prime_parallel 2>/dev/null | grep "Execution time:" | awk '{print $3}')
                unset OMP_SCHEDULE
            fi

            times+=($time_output)
            echo "Time: $time_output seconds"
        done

        # Calculate average
        sum=0
        for time in "${times[@]}"; do
            sum=$(echo "$sum + $time" | bc -l)
        done
        avg_time=$(echo "$sum / $RUNS_PER_CONFIG" | bc -l)

        # Calculate speedup
        speedup=$(echo "$serial_avg / $avg_time" | bc -l)
        speedup_note="Speedup: ${speedup}x"

        # Determine if faster/slower
        if (( $(echo "$avg_time < $serial_avg" | bc -l) )); then
            performance_note="Faster than serial"
        else
            performance_note="Slower than serial"
        fi

        # Display results
        printf "%-12s %-18s %-20s %-25s\n" "$threads" "$schedule" "$avg_time" "$speedup_note"

        # Save to file
        echo "$threads, $schedule, $avg_time, $speedup_note, $performance_note" >> "$results_file"
    done
done

echo ""
echo -e "${GREEN}=== Experiment Complete ===${NC}"
echo "Results saved to: $results_file"

# Cleanup
unset OMP_NUM_THREADS
echo ""
echo -e "${YELLOW}Cleaning up compiled programs...${NC}"
rm -f prime_serial prime_parallel

echo -e "${GREEN}Done!${NC}"
