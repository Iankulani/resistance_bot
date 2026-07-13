# RESISTANCE-BOT - PowerShell Installation Script
# Author: Ian Carter Kulani

param(
    [switch]$Help,
    [switch]$Force
)

if ($Help) {
    Write-Host "Usage: .\setup.ps1 [-Help] [-Force]"
    Write-Host "  -Help    Show this help message"
    Write-Host "  -Force   Force reinstallation"
    exit
}

# Colors
$Blue = "Blue"
$Cyan = "Cyan"
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"
$White = "White"

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $Blue
Write-Host "║        RESISTANCE-BOT v1.0.0 - Installation Script        ║" -ForegroundColor $Blue
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $Blue
Write-Host ""

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "⚠️  Not running as administrator. Some features may be limited." -ForegroundColor $Yellow
    Write-Host "   To run as admin: Right-click PowerShell -> Run as Administrator" -ForegroundColor $Yellow
    if (-not $Force) {
        $response = Read-Host "Continue anyway? (y/n)"
        if ($response -ne 'y') { exit }
    }
}

# Check Python
Write-Host "🔍 Checking Python installation..." -ForegroundColor $Yellow
try {
    $pythonVersion = python --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Python found: $pythonVersion" -ForegroundColor $Green
    } else {
        throw "Python not found"
    }
} catch {
    Write-Host "❌ Python not found. Please install Python 3.7+ from python.org" -ForegroundColor $Red
    Write-Host "📥 Download: https://www.python.org/downloads/" -ForegroundColor $White
    Read-Host "Press Enter to exit"
    exit 1
}

# Check pip
Write-Host "🔍 Checking pip..." -ForegroundColor $Yellow
try {
    python -m pip --version 2>&1 | Out-Null
    Write-Host "✅ pip found" -ForegroundColor $Green
} catch {
    Write-Host "📦 Installing pip..." -ForegroundColor $Yellow
    python -m ensurepip --default-pip
}

# Upgrade pip
Write-Host "⬆️  Upgrading pip..." -ForegroundColor $Yellow
python -m pip install --upgrade pip setuptools wheel

# Install Chocolatey if not present
Write-Host "📦 Checking Chocolatey..." -ForegroundColor $Yellow
$chocoInstalled = Get-Command choco -ErrorAction SilentlyContinue
if (-not $chocoInstalled) {
    Write-Host "📦 Installing Chocolatey..." -ForegroundColor $Yellow
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Install system dependencies
Write-Host "📦 Installing system dependencies via Chocolatey..." -ForegroundColor $Yellow
$dependencies = @("nmap", "curl", "git", "wget", "openssh", "sqlite")
foreach ($dep in $dependencies) {
    Write-Host "   Installing $dep..." -ForegroundColor $Yellow
    choco install -y $dep --ignore-checksums 2>&1 | Out-Null
}

# Create virtual environment
Write-Host "🐍 Creating virtual environment..." -ForegroundColor $Yellow
if (Test-Path ".venv") {
    if ($Force) {
        Remove-Item -Recurse -Force .venv
    } else {
        Write-Host "⚠️  Virtual environment already exists. Use -Force to reinstall." -ForegroundColor $Yellow
        Read-Host "Press Enter to continue"
    }
}
if (-not (Test-Path ".venv")) {
    python -m venv .venv
}

# Activate virtual environment
Write-Host "🔧 Activating virtual environment..." -ForegroundColor $Yellow
& .\.venv\Scripts\Activate.ps1

# Install Python dependencies
Write-Host "📦 Installing Python dependencies..." -ForegroundColor $Yellow
pip install -r requirements.txt

# Create directories
Write-Host "📁 Creating directories..." -ForegroundColor $Yellow
$directories = @(
    ".resistance_bot", "resistance_reports", "payloads", 
    "phishing_pages", "phishing_templates", "captured_credentials",
    "ssh_keys", "traffic_logs", "nikto_results", "logs", "data"
)
foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# Create default config
Write-Host "⚙️  Creating default configuration..." -ForegroundColor $Yellow
if (-not (Test-Path ".env")) {
    Copy-Item .env.example .env
}

Write-Host ""
Write-Host "✅ Installation complete!" -ForegroundColor $Green
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $Blue
Write-Host "║  🎉 RESISTANCE-BOT has been successfully installed!        ║" -ForegroundColor $Blue
Write-Host "║                                                          ║" -ForegroundColor $Blue
Write-Host "║  Start with: .\.venv\Scripts\Activate; python resistance_bot.py" -ForegroundColor $Cyan
Write-Host "║  Help: python resistance_bot.py --help                   ║" -ForegroundColor $Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $Blue
Write-Host ""
Read-Host "Press Enter to exit"