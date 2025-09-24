# Prime Number Counting Experiment Automation Script (PowerShell)
# Mirrors behavior of run_experiments.sh for Windows environments

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Configuration (N is defined inside the C code; used here for display only)
$N = 200000000
$THREAD_COUNTS = @(2, 4, 6, 8, 16, 18, 20)
$SCHEDULE_TYPES = @('default', 'static,1000', 'dynamic,1000', 'guided,1000')
$RUNS_PER_CONFIG = 3

# Paths
$scriptDir = $PSScriptRoot
$serialC = Join-Path $scriptDir 'prime_serial.c'
$parallelC = Join-Path $scriptDir 'prime_parallel.c'
$serialExe = Join-Path $scriptDir 'prime_serial.exe'
$parallelExe = Join-Path $scriptDir 'prime_parallel.exe'
$resultsFile = Join-Path $scriptDir 'experiment_results.txt'

Write-Host "=== Prime Number Counting Experiment (Windows) ===" -ForegroundColor Blue
Write-Host "Dataset size: $N elements"
Write-Host "Runs per configuration: $RUNS_PER_CONFIG"
Write-Host ""

# Compile programs
Write-Host "Compiling programs..." -ForegroundColor Yellow
# Try with -lm first (useful on some GCC setups); fallback without -lm for MinGW/Windows
& gcc -O3 -fopenmp $serialC -o $serialExe -lm | Out-Null
if ($LASTEXITCODE -ne 0) {
    & gcc -O3 -fopenmp $serialC -o $serialExe | Out-Null
}
if ($LASTEXITCODE -ne 0) {
    Write-Host "Compilation failed for serial program!" -ForegroundColor Red
    exit 1
}

& gcc -O3 -fopenmp $parallelC -o $parallelExe -lm | Out-Null
if ($LASTEXITCODE -ne 0) {
    & gcc -O3 -fopenmp $parallelC -o $parallelExe | Out-Null
}
if ($LASTEXITCODE -ne 0) {
    Write-Host "Compilation failed for parallel program!" -ForegroundColor Red
    exit 1
}

Write-Host "Compilation successful!" -ForegroundColor Green
Write-Host ""

# Helper for invariant formatting
$Invariant = [System.Globalization.CultureInfo]::InvariantCulture

# Test serial version (baseline)
Write-Host "=== Serial Baseline ===" -ForegroundColor Blue
$serialTimes = @()
for ($run = 1; $run -le $RUNS_PER_CONFIG; $run++) {
    Write-Host "Serial run $run/$RUNS_PER_CONFIG..." -ForegroundColor Yellow
    $output = & $serialExe 2>$null
    $joined = ($output -join "`n")
    $m = [regex]::Match($joined, 'Execution time:\s*([0-9.]+)')
    if (-not $m.Success) {
        Write-Host "Failed to parse execution time from serial output." -ForegroundColor Red
        exit 1
    }
    $time = [double]$m.Groups[1].Value
    $serialTimes += $time
    Write-Host ("Time: {0} seconds" -f $time.ToString('F6', $Invariant))
}

$serialSum = 0.0
foreach ($t in $serialTimes) { $serialSum += [double]$t }
$serialAvg = $serialSum / [double]$serialTimes.Count
Write-Host ("Serial average: {0} seconds" -f $serialAvg.ToString('F6', $Invariant)) -ForegroundColor Green
Write-Host ""

# Create results file
Set-Content -Path $resultsFile -Value "Prime Number Counting Experiment Results"
Add-Content -Path $resultsFile -Value "====================================="
Add-Content -Path $resultsFile -Value ("Dataset size: {0} elements" -f $N)
Add-Content -Path $resultsFile -Value ("Runs per configuration: {0}" -f $RUNS_PER_CONFIG)
Add-Content -Path $resultsFile -Value ("Serial baseline average: {0} seconds" -f $serialAvg.ToString('F6', $Invariant))
Add-Content -Path $resultsFile -Value ""
Add-Content -Path $resultsFile -Value "Performance Comparison Table:"
Add-Content -Path $resultsFile -Value ""

# Print table header
$fmt = "{0,-12} {1,-18} {2,-20} {3,-25}"
Write-Host ($fmt -f "Threads", "Schedule", "Avg Time (s)", "Notes")
Write-Host ($fmt -f "--------", "--------", "------------", "-----")
Write-Host ""

# Test parallel versions
foreach ($threads in $THREAD_COUNTS) {
    foreach ($schedule in $SCHEDULE_TYPES) {
        Write-Host ("Testing: {0} threads, {1}" -f $threads, $schedule) -ForegroundColor Blue
        $times = @()

        for ($run = 1; $run -le $RUNS_PER_CONFIG; $run++) {
            Write-Host "Run $run/$RUNS_PER_CONFIG..." -ForegroundColor Yellow

            # Set environment variables
            $env:OMP_NUM_THREADS = "$threads"

            # Run with appropriate schedule
            if ($schedule -eq 'default') {
                $output = & $parallelExe 2>$null
            }
            else {
                $env:OMP_SCHEDULE = $schedule
                $output = & $parallelExe 2>$null
                Remove-Item Env:OMP_SCHEDULE -ErrorAction SilentlyContinue
            }

            $joined = ($output -join "`n")
            $m = [regex]::Match($joined, 'Execution time:\s*([0-9.]+)')
            if (-not $m.Success) {
                Write-Host "Failed to parse execution time from parallel output." -ForegroundColor Red
                exit 1
            }
            $time = [double]$m.Groups[1].Value
            $times += $time
            Write-Host ("Time: {0} seconds" -f $time.ToString('F6', $Invariant))
        }

        # Calculate average
        $sum = 0.0
        foreach ($t in $times) { $sum += [double]$t }
        $avg = $sum / [double]$times.Count

        # Calculate speedup
        $speedup = $serialAvg / $avg
        $speedupNote = "Speedup: {0}x" -f $speedup.ToString('F6', $Invariant)

        # Determine if faster/slower
        if ($avg -lt $serialAvg) {
            $performanceNote = "Faster than serial"
        }
        else {
            $performanceNote = "Slower than serial"
        }

        # Display results
        Write-Host ($fmt -f $threads, $schedule, $avg.ToString('F6', $Invariant), $speedupNote)

        # Save to file
        Add-Content -Path $resultsFile -Value ("{0}, {1}, {2}, {3}, {4}" -f $threads, $schedule, $avg.ToString('F6', $Invariant), $speedupNote, $performanceNote)
    }
}

Write-Host ""
Write-Host "=== Experiment Complete ===" -ForegroundColor Green
Write-Host ("Results saved to: {0}" -f $resultsFile)

# Cleanup
Remove-Item Env:OMP_NUM_THREADS -ErrorAction SilentlyContinue
Write-Host ""
Write-Host "Cleaning up compiled programs..." -ForegroundColor Yellow
Remove-Item $serialExe, $parallelExe -ErrorAction SilentlyContinue
Write-Host "Done!" -ForegroundColor Green


