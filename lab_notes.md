# Prime Number Counting Lab - Complete Notes

## 📋 Project Overview

**Goal:** Count prime numbers in an array of 200 million consecutive integers starting from 2, comparing serial vs parallel performance.

**Key Challenge:** 200 million elements = 800MB RAM requirement

## 🎯 Implementation Requirements

### Data Structure

- **Array Size:** `N = 200,000,000` (200 million elements)
- **Data Type:** `unsigned int` (4 bytes per element)
- **Initialization:** Consecutive integers starting from 2
  - `arr[0] = 2`, `arr[1] = 3`, ..., `arr[N-1] = N+1`

### Serial Version (`prime_serial.c`)

```c
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <omp.h>

#define N 200000000UL

int is_prime(unsigned long long num) {
    // Optimized prime checking algorithm
    if (num <= 1) return 0;
    if (num <= 3) return 1;
    if (num % 2 == 0 || num % 3 == 0) return 0;

    for (unsigned long long i = 5; i * i <= num; i += 6) {
        if (num % i == 0 || num % (i + 2) == 0) return 0;
    }
    return 1;
}

int main() {
    unsigned int *arr;
    unsigned long long count = 0;

    // Allocate and initialize array
    arr = (unsigned int *)malloc(N * sizeof(unsigned int));
    for (unsigned long long i = 0; i < N; i++) {
        arr[i] = (unsigned int)(i + 2);
    }

    // Time execution
    double start = omp_get_wtime();

    // Count primes
    for (unsigned long long i = 0; i < N; i++) {
        if (is_prime(arr[i])) count++;
    }

    double end = omp_get_wtime();
    printf("Primes found: %llu\nTime: %.6f seconds\n", count, end-start);

    free(arr);
    return 0;
}
```

### Parallel Version (`prime_parallel.c`)

```c
#pragma omp parallel for reduction(+:count)
for (unsigned long long i = 0; i < N; i++) {
    if (is_prime(arr[i])) count++;
}
```

## 🔬 Experimentation Matrix

### Thread Counts to Test

- **2, 4, 6, 8, 16, 18, 20** threads

### Schedule Types to Test

- **static** (default)
- **static, 1000** (chunk size = 1000)
- **dynamic, 1000** (chunk size = 1000)
- **guided, 1000** (chunk size = 1000)

### Runs per Configuration

- **3 runs** per configuration (for averaging)
- **Total experiments:** 7 thread counts × 4 schedules × 3 runs = **84 total runs**

## 📊 Performance Table Template

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

## 🛠️ Automation Strategy

### Why Shell Scripting?

- **Manual work is impractical:** 84 runs = hours of tedious work
- **Error-prone:** Easy to make mistakes with manual timing
- **Not scalable:** Future projects will need similar automation

### Environment Variables

```bash
export OMP_NUM_THREADS=4                    # Set thread count
export OMP_SCHEDULE="dynamic,1000"          # Set schedule type
```

### Automation Script Features

```bash
#!/bin/bash
# Features needed:
# - Loop through all thread counts
# - Loop through all schedule types
# - Run each configuration 3 times
# - Calculate averages
# - Generate formatted output table
# - Handle OpenMP environment variables
```

## 📝 Report Structure

### A. Machine Details

- **CPU Model:** (e.g., Intel i7, Apple M1, etc.)
- **Number of Cores:** (check with `nproc`)
- **RAM Size:** (check system information)
- **Operating System:** (e.g., Linux, macOS)

### B. Compiler Information

- **Compiler Version:** `gcc --version`
- **Compilation Flags:** `-O3 -fopenmp`

### C. Screenshots

- **Serial:** 1 screenshot (from 3 runs)
- **Parallel:** 3 screenshots (labeled with thread count & schedule)

### D. Results Table

- **Filled performance table** with all timing data
- **Average execution times** for each configuration
- **Speedup calculations** vs serial baseline

### E. Discussion

- **Best Performance:** Which configuration was fastest?
- **Thread Scaling:** Does adding threads always help?
- **Diminishing Returns:** When does adding more threads stop helping?

## 🎓 Key Learning Points

### From Professor's Lecture

1. **Data Types Matter:** Ask ChatGPT about data type limits
2. **Use Trusted Sources:** Always specify "from trusted resources"
3. **ChatGPT for Learning:** Tool to learn, not just copy code
4. **Automation is Key:** Shell scripts for systematic experimentation
5. **Individual Work:** Different hardware = different results

### Technical Concepts

1. **Race Conditions:** Why reduction clause is critical
2. **Load Balancing:** How different schedules affect performance
3. **Memory Bandwidth:** Why too many threads can hurt performance
4. **Scheduling Overhead:** Runtime scheduling costs

## ⚡ Performance Optimization Tips

### Prime Checking Algorithm

```c
// 6k±1 optimization - only check divisibility by 2, 3, and numbers of form 6k±1
for (unsigned long long i = 5; i * i <= num; i += 6) {
    if (num % i == 0 || num % (i + 2) == 0) return 0;
}
```

### OpenMP Best Practices

```c
#pragma omp parallel for reduction(+:count) schedule(static, 1000)
```

### Memory Management

```c
// Pre-allocate and check
arr = (unsigned int *)malloc(N * sizeof(unsigned int));
if (arr == NULL) {
    printf("Memory allocation failed!\n");
    return 1;
}
```

## 🚨 Common Pitfalls

1. **Wrong Data Type:** Use `unsigned long long` for large counters
2. **Race Conditions:** Always use `reduction` for shared variables
3. **Memory Issues:** 800MB RAM required - test with smaller N first
4. **Schedule Confusion:** Default static vs explicit static,1000
5. **Timing Errors:** Use `omp_get_wtime()` consistently
6. **Compilation Issues:** Ensure `-fopenmp` flag is used

## 📚 Resources for Learning

### ChatGPT Prompts

- "What data type can hold 200 million in C?"
- "How to avoid race conditions in OpenMP?"
- "Create a shell script to automate OpenMP experiments"
- "Explain OpenMP scheduling policies"

### Key Topics to Research

- OpenMP parallel for directive
- Reduction clause in OpenMP
- Different scheduling policies (static, dynamic, guided)
- Performance analysis and benchmarking
- Shell scripting for automation

## 🎯 Success Criteria

✅ **Correctness:** Serial and parallel versions give same prime count
✅ **Completeness:** All 84 experiments completed
✅ **Automation:** Shell script handles all testing
✅ **Analysis:** Performance table with averages and comparisons
✅ **Documentation:** Comprehensive report with discussion
✅ **Learning:** Understanding of parallel computing concepts

## 💡 Pro Tips

1. **Start Small:** Test with N=10,000 first to verify correctness
2. **Monitor Resources:** Use `htop` to watch CPU and memory usage
3. **Document Everything:** Keep notes on what works/doesn't work
4. **Ask ChatGPT Smartly:** Use specific, technical questions
5. **Think About Scaling:** Why performance changes with more threads
6. **Plan for Report:** Collect screenshots and data systematically

---

_Remember: The goal is not just to complete the lab, but to understand why parallel computing matters and how to do it effectively!_

