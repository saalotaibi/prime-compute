This document outlines a problem involving counting prime numbers in a large dataset using both serial and parallel programming approaches.

## Problem: Counting Prime Numbers in a Large Dataset

**Goal:** Count the number of prime numbers in an array of 200 million consecutive integers starting from 2.

### Requirements:

1.  **Input Data:**

    - Create an array of size `N = 200,000,000` (200 million) of `unsigned int`.
    - Initialize the array with consecutive integers starting from 2 (e.g., `arr[0] = 2`, `arr[1] = 3`, ..., `arr[N-1] = N+1`).

2.  **Serial Version:**

    - Loop through the entire array.
    - For each number, check if it's prime (divisible only by 1 and itself).
    - Count the total number of primes found.
    - Measure execution time using `omp_get_wtime()` and print it.

3.  **Parallel Version:**

    - Use `#pragma omp parallel for` to distribute the loop iterations among multiple threads.
    - Employ `reduction(+:count)` to ensure safe updates to the prime counter.
    - Print the final prime count after the parallel region.
    - Measure execution time using `omp_get_wtime()` and print it.
    - Run the parallel version with different numbers of threads: **2, 4, 6, 8, 16, 18, 20**.
    - For each thread count, run the parallel version with the following schedule types:
      - `static` (default)
      - `static, 1000`
      - `dynamic, 1000`
      - `guided, 1000`
    - Compare serial vs. parallel performance using the provided table. For each experiment, run it three times and report the **average** execution time.

    **Performance Table:**

    | Threads    | Schedule         | Execution Time (s) | Notes (Faster/Slower than Serial) |
    | :--------- | :--------------- | :----------------- | :-------------------------------- |
    | **Serial** | --               |                    | Baseline                          |
    | 2          | static (default) |                    |                                   |
    | 2          | static, 1000     |                    |                                   |
    | 2          | dynamic, 1000    |                    |                                   |
    | 2          | guided, 1000     |                    |                                   |
    | 4          | static (default) |                    |                                   |
    | 4          | static, 1000     |                    |                                   |
    | 4          | dynamic, 1000    |                    |                                   |
    | 4          | guided, 1000     |                    |                                   |
    | ...        | ...              | ...                | ...                               |
    | 20         | static (default) |                    |                                   |
    | 20         | static, 1000     |                    |                                   |
    | 20         | dynamic, 1000    |                    |                                   |
    | 20         | guided, 1000     |                    |                                   |

### Important Notes:

- **Memory:** An array of 200 million `unsigned int`s requires approximately 800 MB of RAM. Ensure sufficient memory is available.
- **Runtime:** Trial division up to $\sqrt{N}$ for 200 million elements is very time-consuming. Expect long run times. If your machine struggles, consider reducing `N` (e.g., 50-100 million) for initial testing.
- **Correctness:** The prime counts from the serial and parallel versions must match.
- **Procedure:** Always run the serial version first and record its time as the baseline. Then, perform all parallel runs and fill in the results.
- **Comparison:** All parallel run times should be compared against the serial baseline to determine speedup.

### Submission:

1.  **C Code:**

    - `prime_serial.c`: Your serial C code for prime counting.
    - `prime_parallel.c`: Your parallel C code using OpenMP for prime counting.

2.  **Report:** Include the following sections in your report:
    - **A. Machine Details:**
      - CPU model
      - Number of cores
      - RAM size
      - Operating system
    - **B. Compiler Information:**
      - Compiler version (e.g., `gcc -v`)
      - Compilation flags used (e.g., `gcc -O2 -fopenmp`).
    - **C. Screenshots:**
      - Screenshots of your program's output for both serial and parallel runs.
      - For parallel outputs, clearly label each run with the thread count and schedule type.
    - **D. Results Table:**
      - A filled version of the performance table provided above, including all execution times and comparisons to the serial baseline.
    - **E. Discussion:**
      - **Best Performance:** Identify the combination of schedule type and thread count that yielded the shortest execution time.
      - **Thread Scaling:** Discuss whether increasing the number of threads consistently made the program faster. Explain potential reasons why it might not (e.g., scheduling overhead, memory bandwidth limitations, load imbalance).
      - **Diminishing Returns:** Identify the point where adding more threads provided little or no further speed improvement. Explain why performance tends to level off as thread count increases.

Here's an example of how a simple screenshot of the output might look (you will replace this with your actual output):
