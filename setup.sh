#!/bin/bash
# RESISTANCE-BOT - Linux/macOS Installation Script
# Author: Ian Carter Kulani

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${CYAN}        RESISTANCE-BOT v1.0.0 - Installation Script       ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

# Check OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     OS_TYPE="Linux";;
    Darwin*)    OS_TYPE="macOS";;
    *)          OS_TYPE="Unknown";;
esac

echo -e "${GREEN}✅ Detected OS: ${OS_TYPE}${NC}"

# Check Python version
echo -e "${YELLOW}🔍 Checking Python version...${NC}"
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
REQUIRED_VERSION="3.7.0"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo -e "${RED}❌ Python ${REQUIRED_VERSION}+ required. Found: ${PYTHON_VERSION}${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Python ${PYTHON_VERSION} detected${NC}"

# Install system dependencies
echo -e "${YELLOW}📦 Installing system dependencies...${NC}"

if [[ "$OS_TYPE" == "Linux" ]]; then
    # Detect package manager
    if command -v apt-get &> /dev/null; then
        echo -e "${GREEN}📦 Using APT package manager${NC}"
        sudo apt-get update
        sudo apt-get install -y \
            nmap \
            curl \
            netcat-openbsd \
            traceroute \
            whois \
            dnsutils \
            iputils-ping \
            openssh-client \
            wget \
            sqlite3 \
            build-essential \
            python3-dev \
            python3-pip \
            xvfb \
            x11-utils \
            git \
            nikto
    elif command -v yum &> /dev/null; then
        echo -e "${GREEN}📦 Using YUM package manager${NC}"
        sudo yum install -y \
            nmap \
            curl \
            nc \
            traceroute \
            whois \
            bind-utils \
            openssh-clients \
            wget \
            sqlite \
            gcc \
            python3-devel \
            python3-pip \
            xorg-x11-server-Xvfb \
            git
    elif command -v dnf &> /dev/null; then
        echo -e "${GREEN}📦 Using DNF package manager${NC}"
        sudo dnf install -y \
            nmap \
            curl \
            nc \
            traceroute \
            whois \
            bind-utils \
            openssh-clients \
            wget \
            sqlite \
            gcc \
            python3-devel \
            python3-pip \
            xorg-x11-server-Xvfb \
            git
    elif command -v pacman &> /dev/null; then
        echo -e "${GREEN}📦 Using PACMAN package manager${NC}"
        sudo pacman -S --noconfirm \
            nmap \
            curl \
            netcat \
            traceroute \
            whois \
            dnsutils \
            openssh \
            wget \
            sqlite \
            gcc \
            python-pip \
            xorg-server-xvfb \
            git
    else
        echo -e "${YELLOW}⚠️  Could not detect package manager. Please install dependencies manually.${NC}"
    fi

elif [[ "$OS_TYPE" == "macOS" ]]; then
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}🍺 Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    echo -e "${GREEN}📦 Installing dependencies via Homebrew${NC}"
    brew install \
        nmap \
        curl \
        netcat \
        traceroute \
        whois \
        dnsutils \
        openssh \
        wget \
        sqlite3 \
        python@3.11 \
        git \
        nikto
fi

# Create virtual environment
echo -e "${YELLOW}🐍 Creating Python virtual environment...${NC}"
python3 -m venv .venv
source .venv/bin/activate

# Upgrade pip
echo -e "${YELLOW}⬆️  Upgrading pip...${NC}"
pip install --upgrade pip setuptools wheel

# Install Python dependencies
echo -e "${YELLOW}📦 Installing Python dependencies...${NC}"
pip install -r requirements.txt

# Install additional development dependencies
pip install black flake8 mypy pytest pytest-cov

# Create necessary directories
echo -e "${YELLOW}📁 Creating directories...${NC}"
mkdir -p .resistance_bot
mkdir -p resistance_reports
mkdir -p payloads
mkdir -p phishing_pages
mkdir -p phishing_templates
mkdir -p captured_credentials
mkdir -p ssh_keys
mkdir -p traffic_logs
mkdir -p nikto_results
mkdir -p logs
mkdir -p data

# Create default config
echo -e "${YELLOW}⚙️  Creating default configuration...${NC}"
if [ ! -f .env ]; then
    cp .env.example .env
fi

# Make scripts executable
echo -e "${YELLOW}🔧 Making scripts executable...${NC}"
chmod +x scripts/*.sh

# Create database
echo -e "${YELLOW}🗄️  Initializing database...${NC}"
python3 -c "from resistance_bot import ResistanceBot; app = ResistanceBot(); app.db.init_tables()"

echo -e "${GREEN}✅ Installation complete!${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${GREEN}  🎉 RESISTANCE-BOT has been successfully installed!      ${BLUE}║${NC}"
echo -e "${BLUE}║                                                          ║${NC}"
echo -e "${BLUE}║  ${CYAN}Start with:${NC} ./scripts/start.sh                           ${BLUE}║${NC}"
echo -e "${BLUE}║  ${CYAN}Run:${NC} python3 resistance_bot.py                         ${BLUE}║${NC}"
echo -e "${BLUE}║  ${CYAN}Help:${NC} python3 resistance_bot.py --help                 ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"