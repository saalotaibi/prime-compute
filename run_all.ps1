# Prime Number Counting Experiment Automation Script (PowerShell)
# This script automates the testing of serial and parallel prime counting
# with different thread counts and scheduling policies

# Configuration
$N = 200000000
$THREAD_COUNTS = @(2, 4, 6, 8, 16, 18, 20)
$SCHEDULE_TYPES = @("default", "static,1000", "dynamic,1000", "guided,1000")
$RUNS_PER_CONFIG = 3

Write-Host "=== Prime Number Counting Experiment ===" -ForegroundColor Blue
Write-Host "Dataset size: $N elements"
Write-Host "Runs per configuration: $RUNS_PER_CONFIG"
Write-Host ""

# Compile programs
Write-Host "Compiling programs..." -ForegroundColor Yellow
gcc -O3 -fopenmp prime_serial.c -o prime_serial.exe -lm
gcc -O3 -fopenmp prime_parallel.c -o prime_parallel.exe -lm

if ($LASTEXITCODE -ne 0) {
    Write-Host "Compilation failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Compilation successful!" -ForegroundColor Green
Write-Host ""

# Test serial version (baseline)
Write-Host "=== Serial Baseline ===" -ForegroundColor Blue
$serial_times = @()

for ($run = 1; $run -le $RUNS_PER_CONFIG; $run++) {
    Write-Host "Serial run $run/$RUNS_PER_CONFIG..." -ForegroundColor Yellow
    $output = .\prime_serial.exe 2>$null
    $time_output = ($output | Select-String "Execution time:" | ForEach-Object { $_.Line.Split()[2] })
    $serial_times += [double]$time_output
    Write-Host "Time: $time_output seconds"
}

# Calculate serial average
$serial_avg = ($serial_times | Measure-Object -Average).Average
Write-Host "Serial average: $serial_avg seconds" -ForegroundColor Green
Write-Host ""

# Create results file
$results_file = "experiment_results.txt"
@"
Prime Number Counting Experiment Results
=====================================
Dataset size: $N elements
Runs per configuration: $RUNS_PER_CONFIG
Serial baseline average: $serial_avg seconds

Performance Comparison Table:

"@ | Out-File -FilePath $results_file -Encoding UTF8

# Print table header
Write-Host ("{0,-12} {1,-18} {2,-20} {3,-25}" -f "Threads", "Schedule", "Avg Time (s)", "Notes")
Write-Host ("{0,-12} {1,-18} {2,-20} {3,-25}" -f "--------", "--------", "------------", "-----")
Write-Host ""

# Test parallel versions
foreach ($threads in $THREAD_COUNTS) {
    foreach ($schedule in $SCHEDULE_TYPES) {
        Write-Host "Testing: $threads threads, $schedule" -ForegroundColor Blue
        $times = @()

        for ($run = 1; $run -le $RUNS_PER_CONFIG; $run++) {
            Write-Host "Run $run/$RUNS_PER_CONFIG..." -ForegroundColor Yellow

            # Set environment variables
            $env:OMP_NUM_THREADS = $threads

            # Run with appropriate schedule
            if ($schedule -eq "default") {
                $output = .\prime_parallel.exe 2>$null
                $time_output = ($output | Select-String "Execution time:" | ForEach-Object { $_.Line.Split()[2] })
            } else {
                $env:OMP_SCHEDULE = $schedule
                $output = .\prime_parallel.exe 2>$null
                $time_output = ($output | Select-String "Execution time:" | ForEach-Object { $_.Line.Split()[2] })
                Remove-Item env:OMP_SCHEDULE -ErrorAction SilentlyContinue
            }

            $times += [double]$time_output
            Write-Host "Time: $time_output seconds"
        }

        # Calculate average
        $avg_time = ($times | Measure-Object -Average).Average

        # Calculate speedup
        $speedup = $serial_avg / $avg_time
        $speedup_note = "Speedup: {0:F2}x" -f $speedup

        # Determine if faster/slower
        if ($avg_time -lt $serial_avg) {
            $performance_note = "Faster than serial"
        } else {
            $performance_note = "Slower than serial"
        }

        # Display results
        Write-Host ("{0,-12} {1,-18} {2,-20} {3,-25}" -f $threads, $schedule, ("{0:F6}" -f $avg_time), $speedup_note)

        # Save to file
        "$threads, $schedule, $avg_time, $speedup_note, $performance_note" | Out-File -FilePath $results_file -Append -Encoding UTF8
    }
}

Write-Host ""
Write-Host "=== Experiment Complete ===" -ForegroundColor Green
Write-Host "Results saved to: $results_file"

# Cleanup
Remove-Item env:OMP_NUM_THREADS -ErrorAction SilentlyContinue
Write-Host ""
Write-Host "Cleaning up compiled programs..." -ForegroundColor Yellow
Remove-Item prime_serial.exe, prime_parallel.exe -ErrorAction SilentlyContinue

Write-Host "Done!" -ForegroundColor Green