@echo off
:: RESISTANCE-BOT - Windows Installation Script
:: Author: Ian Carter Kulani

title RESISTANCE-BOT Installation

echo ╔════════════════════════════════════════════════════════════╗
echo ║        RESISTANCE-BOT v1.0.0 - Installation Script        ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

:: Check Python
echo 🔍 Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python not found. Please install Python 3.7+ from python.org
    echo 📥 Download: https://www.python.org/downloads/
    pause
    exit /b 1
)

:: Get Python version
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VER=%%i
echo ✅ Python %PYTHON_VER% detected

:: Check pip
echo 🔍 Checking pip...
python -m pip --version >nul 2>&1
if errorlevel 1 (
    echo 📦 Installing pip...
    python -m ensurepip --default-pip
)

:: Upgrade pip
echo ⬆️  Upgrading pip...
python -m pip install --upgrade pip setuptools wheel

:: Install system dependencies (via Chocolatey)
echo 📦 Installing system dependencies...
where choco >nul 2>&1
if errorlevel 1 (
    echo ⚠️  Chocolatey not found. Installing required tools manually...
    echo 📥 Please install manually:
    echo    - Nmap: https://nmap.org/download.html
    echo    - Curl: https://curl.se/download.html
    echo    - Git: https://git-scm.com/download/win
) else (
    echo ✅ Chocolatey found. Installing dependencies...
    choco install -y nmap curl git wget openssh sqlite
)

:: Create virtual environment
echo 🐍 Creating virtual environment...
python -m venv .venv
call .venv\Scripts\activate.bat

:: Install Python dependencies
echo 📦 Installing Python dependencies...
pip install -r requirements.txt

:: Create directories
echo 📁 Creating directories...
if not exist ".resistance_bot" mkdir ".resistance_bot"
if not exist "resistance_reports" mkdir "resistance_reports"
if not exist "payloads" mkdir "payloads"
if not exist "phishing_pages" mkdir "phishing_pages"
if not exist "phishing_templates" mkdir "phishing_templates"
if not exist "captured_credentials" mkdir "captured_credentials"
if not exist "ssh_keys" mkdir "ssh_keys"
if not exist "traffic_logs" mkdir "traffic_logs"
if not exist "nikto_results" mkdir "nikto_results"
if not exist "logs" mkdir "logs"
if not exist "data" mkdir "data"

:: Create default config
echo ⚙️  Creating default configuration...
if not exist ".env" copy .env.example .env

echo.
echo ✅ Installation complete!
echo ╔════════════════════════════════════════════════════════════╗
echo ║  🎉 RESISTANCE-BOT has been successfully installed!        ║
echo ║                                                          ║
echo ║  Start with: .venv\Scripts\activate & python resistance_bot.py
echo ║  Help: python resistance_bot.py --help                   ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
pause