#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <omp.h>

#define N 200000000UL // 200 million elements

int is_prime(unsigned long long num)
{
    if (num <= 1)
        return 0;
    if (num <= 3)
        return 1;
    if (num % 2 == 0 || num % 3 == 0)
        return 0;

    for (unsigned long long i = 5; i * i <= num; i += 6)
    {
        if (num % i == 0 || num % (i + 2) == 0)
            return 0;
    }
    return 1;
}

int main(int argc, char *argv[])
{
    unsigned int *arr;
    unsigned long long count = 0;
    double start_time, end_time;
    int num_threads;

    // Check if number of threads is provided
    if (argc > 1)
    {
        num_threads = atoi(argv[1]);
        if (num_threads <= 0)
        {
            printf("Invalid number of threads. Using default.\n");
            num_threads = omp_get_max_threads();
        }
    }
    else
    {
        num_threads = omp_get_max_threads();
    }

    // Set number of threads
    omp_set_num_threads(num_threads);

    // Allocate memory for the array
    arr = (unsigned int *)malloc(N * sizeof(unsigned int));
    if (arr == NULL)
    {
        printf("Memory allocation failed!\n");
        return 1;
    }

    // Initialize array with consecutive integers starting from 2
    printf("Initializing array with %lu elements using %d threads...\n", N, num_threads);
#pragma omp parallel for
    for (unsigned long long i = 0; i < N; i++)
    {
        arr[i] = (unsigned int)(i + 2);
    }

    // Start timing
    start_time = omp_get_wtime();

    // Count prime numbers in parallel
    printf("Counting prime numbers in parallel...\n");
#pragma omp parallel for reduction(+ : count)
    for (unsigned long long i = 0; i < N; i++)
    {
        if (is_prime(arr[i]))
        {
            count++;
        }
    }

    // End timing
    end_time = omp_get_wtime();

    // Print results
    printf("Parallel Execution Results:\n");
    printf("Number of threads: %d\n", num_threads);
    printf("Number of prime numbers found: %llu\n", count);
    printf("Execution time: %.6f seconds\n", end_time - start_time);
    printf("Performance: %.2f million elements/second\n",
           N / ((end_time - start_time) * 1000000.0));
    printf("Speedup: %.2fx compared to serial baseline\n",
           (end_time - start_time) > 0 ? 1.0 / (end_time - start_time) : 0);

    // Free memory
    free(arr);

    return 0;
}
