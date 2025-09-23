#!/bin/bash

# Quick test of different scheduling options
echo "Testing different scheduling options with 2 threads..."

# Test default scheduling
echo "=== Default (static) ==="
export OMP_NUM_THREADS=2
./prime_parallel 2 | grep "Execution time:" | head -1

# Test static with chunk size
echo "=== Static,1000 ==="
export OMP_SCHEDULE="static,1000"
./prime_parallel 2 | grep "Execution time:" | head -1
unset OMP_SCHEDULE

# Test dynamic with chunk size
echo "=== Dynamic,1000 ==="
export OMP_SCHEDULE="dynamic,1000"
./prime_parallel 2 | grep "Execution time:" | head -1
unset OMP_SCHEDULE

# Test guided with chunk size
echo "=== Guided,1000 ==="
export OMP_SCHEDULE="guided,1000"
./prime_parallel 2 | grep "Execution time:" | head -1
unset OMP_SCHEDULE

# Cleanup
unset OMP_NUM_THREADS
rm -f prime_serial prime_parallel
