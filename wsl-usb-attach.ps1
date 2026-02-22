#Requires -Version 5.1
<#
.SYNOPSIS
    Checks for usbipd-win, installs if missing, then attaches a USB device to WSL.
.DESCRIPTION
    Lists all connected USB devices. If -BusId is provided, uses it directly.
    Otherwise, prompts you to select from the list.
    First-time bind requires admin -- the script self-elevates automatically.
.PARAMETER BusId
    Optional. Bus ID of the device to attach (e.g. "2-1").
    If omitted, you will be prompted to select from the list.
.EXAMPLE
    .\wsl-usb-attach.ps1
    .\wsl-usb-attach.ps1 -BusId 2-1
#>

param(
    [string]$BusId = ""
)

$ErrorActionPreference = "Stop"

function Test-Admin {
    $id        = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($id)
    return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Get-UsbDeviceLines {
    $lines = usbipd list 2>&1
    # Device lines start with a bus ID like "1-1", "2-4", etc.
    return $lines | Where-Object { $_ -match "^\s*\d+-\d+" }
}

Write-Host ""
Write-Host "=== WSL USB Attach ===" -ForegroundColor Cyan
Write-Host ""

# --- 1. Ensure usbipd-win is installed ---------------------------------------
Write-Host "[1/4] Checking usbipd-win..." -ForegroundColor Cyan

if (-not (Get-Command usbipd -ErrorAction SilentlyContinue)) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "  [!] winget not found." -ForegroundColor Red
        Write-Host "      Download usbipd-win manually:"
        Write-Host "      https://github.com/dorssel/usbipd-win/releases"
        exit 1
    }
    Write-Host "  Not found. Installing via winget..." -ForegroundColor Yellow
    winget install --interactive --exact dorssel.usbipd-win
    # Reload PATH so usbipd is available in this session
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path", "User")
    if (-not (Get-Command usbipd -ErrorAction SilentlyContinue)) {
        Write-Host "  [!] Installed but usbipd not in PATH yet. Restart PowerShell and re-run." -ForegroundColor Yellow
        exit 0
    }
}

Write-Host "  usbipd-win $(usbipd --version) ready." -ForegroundColor Green

# --- 2. List devices and select ----------------------------------------------
Write-Host ""
Write-Host "[2/4] Connected USB devices:" -ForegroundColor Cyan
Write-Host ""

$deviceLines = Get-UsbDeviceLines
if (-not $deviceLines) {
    Write-Host "  [!] No USB devices found." -ForegroundColor Red
    exit 1
}

$i = 1
$deviceList = @()
foreach ($d in $deviceLines) {
    Write-Host ("  [{0}] {1}" -f $i, $d.Trim())
    $deviceList += $d
    $i++
}
Write-Host ""

if ($BusId -eq "") {
    $selection = Read-Host "  Select device (number or Bus ID)"
    if ($selection -match "^\d+$") {
        $idx = [int]$selection - 1
        if ($idx -lt 0 -or $idx -ge $deviceList.Count) {
            Write-Host "  [!] Invalid selection." -ForegroundColor Red
            exit 1
        }
        $line = $deviceList[$idx]
        $BusId = ($line.Trim() -split "\s+")[0]
    } else {
        $BusId = $selection.Trim()
    }
}

$line = $deviceList |
    Where-Object { $_.Trim() -match "^$([regex]::Escape($BusId))\s" } |
    Select-Object -First 1

if (-not $line) {
    Write-Host "  [!] Bus ID '$BusId' not found in device list." -ForegroundColor Red
    exit 1
}

Write-Host "  Selected : $($line.Trim())" -ForegroundColor Green

$isAttached  = $line -imatch "Attached"
$isNotShared = $line -imatch "Not shared"

# --- 3. Bind if not yet shared (requires admin) ------------------------------
Write-Host ""
Write-Host "[3/4] Checking bind status..." -ForegroundColor Cyan

if ($isNotShared) {
    Write-Host "  Not yet bound." -ForegroundColor Yellow
    if (-not (Test-Admin)) {
        Write-Host "  Bind requires admin. Re-launching as Administrator..." -ForegroundColor Yellow
        $scriptArgs = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -BusId `"$BusId`""
        Start-Process powershell -ArgumentList $scriptArgs -Verb RunAs -Wait
        exit 0
    }
    Write-Host "  Binding (busid: $BusId)..." -ForegroundColor Cyan
    usbipd bind --busid $BusId
    Write-Host "  Bound." -ForegroundColor Green
} else {
    Write-Host "  Already bound -- skipping." -ForegroundColor Green
}

# --- 4. Attach to WSL --------------------------------------------------------
Write-Host ""
Write-Host "[4/4] Attaching to WSL..." -ForegroundColor Cyan

if ($isAttached) {
    Write-Host "  Already attached to WSL." -ForegroundColor Green
} else {
    usbipd attach --wsl --busid $BusId
    Write-Host "  Attached." -ForegroundColor Green
}

Write-Host ""
Write-Host "Done! Device (busid: $BusId) is ready in WSL." -ForegroundColor Green
Write-Host ""
