# Makefile for Prime Number Counting Lab

CC = gcc
CFLAGS = -O3 -fopenmp -Wall
LIBS = -lm

# Default target
all: prime_serial prime_parallel

# Serial program
prime_serial: prime_serial.c
	$(CC) $(CFLAGS) prime_serial.c -o prime_serial $(LIBS)

# Parallel program
prime_parallel: prime_parallel.c
	$(CC) $(CFLAGS) prime_parallel.c -o prime_parallel $(LIBS)

# Clean up
clean:
	rm -f prime_serial prime_parallel experiment_results.txt

# Test individual programs
test_serial: prime_serial
	./prime_serial

test_parallel: prime_parallel
	./prime_parallel 4

# Run quick schedule test
test_schedule: prime_parallel test_schedule.sh
	chmod +x test_schedule.sh
	./test_schedule.sh

# Run full experiment (requires run_experiments.sh to be executable)
experiment: run_experiments.sh
	chmod +x run_experiments.sh
	./run_experiments.sh

# Help target
help:
	@echo "Available targets:"
	@echo "  all          - Compile both programs"
	@echo "  prime_serial - Compile serial program only"
	@echo "  prime_parallel - Compile parallel program only"
	@echo "  clean        - Remove compiled programs and results"
	@echo "  test_serial  - Run serial program"
	@echo "  test_parallel - Run parallel program with 4 threads"
	@echo "  test_schedule - Test different OpenMP scheduling options"
	@echo "  experiment   - Run full experiment suite"
	@echo "  help         - Show this help message"

.PHONY: all clean test_serial test_parallel test_schedule experiment help
