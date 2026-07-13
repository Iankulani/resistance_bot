# Dockerfile for RESISTANCE-BOT
FROM python:3.11-slim

# Metadata
LABEL maintainer="Ian Carter Kulani"
LABEL version="1.0.0"
LABEL description="RESISTANCE-BOT - Advanced Cybersecurity Command & Control Platform"

# Environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # Network tools
    nmap \
    curl \
    netcat-openbsd \
    traceroute \
    whois \
    dnsutils \
    iputils-ping \
    telnet \
    # SSH
    openssh-client \
    # Web
    wget \
    # PDF
    wkhtmltopdf \
    # Database
    sqlite3 \
    # Build tools
    build-essential \
    gcc \
    python3-dev \
    # Qt dependencies for pyautogui
    libxcb-xinerama0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-shape0 \
    libxcb-xfixes0 \
    libxcb-xkb1 \
    libxkbcommon-x11-0 \
    # X11
    xvfb \
    x11-utils \
    # Cleanup
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir \
        gunicorn \
        eventlet \
        gevent

# Copy application
COPY . .

# Create necessary directories
RUN mkdir -p .resistance_bot \
    resistance_reports \
    payloads \
    phishing_pages \
    phishing_templates \
    captured_credentials \
    ssh_keys \
    traffic_logs \
    nikto_results \
    reports

# Create non-root user
RUN useradd -m -u 1000 resistance \
    && chown -R resistance:resistance /app

# Switch to non-root user
USER resistance

# Expose ports
EXPOSE 5000 5555 8080 4444

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/ || exit 1

# Entry point
ENTRYPOINT ["python3", "resistance_bot.py"]

# Default command (can be overridden)
CMD []