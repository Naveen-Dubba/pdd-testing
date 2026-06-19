# Windows PowerShell script to execute Appium E2E testing suite

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "      Starting Appium E2E Test Suite      " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Ensure reports and screenshots folders exist
New-Item -ItemType Directory -Force -Path "reports" | Out-Null
New-Item -ItemType Directory -Force -Path "screenshots" | Out-Null

# Verify python virtual environment is initialized
if (-not (Test-Path "venv")) {
    Write-Host "Creating Python virtual environment..." -ForegroundColor Yellow
    python -m venv venv
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Python is not installed or not in PATH." -ForegroundColor Red
        Exit
    }
}

# Activate virtual environment and install/update requirements
Write-Host "Activating virtual environment & checking dependencies..." -ForegroundColor Yellow
& ".\venv\Scripts\Activate.ps1"
pip install -r requirements.txt --quiet

# Check if Appium Server is responding on default port 4723
Write-Host "Verifying Appium Server is running..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:4723/status" -TimeoutSec 3 -ErrorAction Stop
    Write-Host "Appium server is UP (version: $($response.value.build.version))." -ForegroundColor Green
} catch {
    Write-Host "Warning: Appium server does not appear to be running on http://127.0.0.1:4723/status." -ForegroundColor Red
    Write-Host "Please start the Appium server using command: appium" -ForegroundColor Yellow
    Write-Host "Continuing anyway hoping Appium will be ready..." -ForegroundColor DarkYellow
}

# Run pytest E2E tests
Write-Host "Running pytest E2E test suite..." -ForegroundColor Yellow
python -m pytest tests/ -v --html=reports/report.html --self-contained-html

# Check test outcome
if ($LASTEXITCODE -eq 0) {
    Write-Host "All tests completed successfully!" -ForegroundColor Green
} else {
    Write-Host "Some tests failed. Please review the reports." -ForegroundColor Red
}

# Open Excel report and HTML report
$excel_reports = Get-ChildItem "reports/test_report_*.xlsx" | Sort-Object LastWriteTime -Descending
if ($excel_reports.Count -gt 0) {
    $latest_excel = $excel_reports[0].FullName
    Write-Host "Opening Excel Report: $latest_excel" -ForegroundColor Green
    Start-Process $latest_excel
} else {
    Write-Host "Excel report not found." -ForegroundColor Yellow
}

if (Test-Path "reports/report.html") {
    Write-Host "Opening HTML Report: reports/report.html" -ForegroundColor Green
    Start-Process "reports/report.html"
}
