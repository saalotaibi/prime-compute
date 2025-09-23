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

int main()
{
    unsigned int *arr;
    unsigned long long count = 0;
    double start_time, end_time;

    // Allocate memory for the array
    arr = (unsigned int *)malloc(N * sizeof(unsigned int));
    if (arr == NULL)
    {
        printf("Memory allocation failed!\n");
        return 1;
    }

    // Initialize array with consecutive integers starting from 2
    printf("Initializing array with %lu elements...\n", N);
    for (unsigned long long i = 0; i < N; i++)
    {
        arr[i] = (unsigned int)(i + 2);
    }

    // Start timing
    start_time = omp_get_wtime();

    // Count prime numbers
    printf("Counting prime numbers...\n");
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
    printf("Serial Execution Results:\n");
    printf("Number of prime numbers found: %llu\n", count);
    printf("Execution time: %.6f seconds\n", end_time - start_time);
    printf("Performance: %.2f million elements/second\n",
           N / ((end_time - start_time) * 1000000.0));

    // Free memory
    free(arr);

    return 0;
}
