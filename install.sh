#!/bin/bash
# Quick install script for RESISTANCE-BOT

set -e

echo "🚀 Installing RESISTANCE-BOT..."

# Clone repository (if not already cloned)
if [ ! -f "resistance_bot.py" ]; then
    echo "📥 Cloning repository..."
    git clone https://github.com/Iankulani/resistance-bot.git .
fi

# Run setup
chmod +x setup.sh
./setup.sh

echo "✅ Installation complete!"
echo "📖 Run 'python3 resistance_bot.py' to start the bot"