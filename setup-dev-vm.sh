#!/bin/bash

# ======================================================================================
# (Revised) All-Inclusive Headless Ubuntu Development Environment Setup Script
#
# This version includes more verbose logging to make troubleshooting easier.
# ======================================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Pre-flight Checks ---
echo "--- Running Pre-flight Checks ---"

# Check if running as root/sudo
if [ "$EUID" -ne 0 ]; then
  echo "❌ Error: Please run this script with sudo."
  exit 1
fi
echo "✅ Sudo check passed."

# Determine the user who will receive the configurations (docker group, zsh shell)
# This handles cases where the script is run with `sudo` or after `sudo su`.
if [ -n "$SUDO_USER" ]; then
    RUN_USER=$SUDO_USER
else
    # If SUDO_USER is not set, it's likely the root user themselves.
    # Fallback to the USER variable, but warn the user.
    RUN_USER=$USER
    if [ "$RUN_USER" = "root" ]; then
        echo "⚠️ Warning: Running as root without sudo. Zsh and Docker permissions will be applied to the 'root' user."
    fi
fi
echo "✅ Configurations will be applied to user: $RUN_USER"
echo "--- Pre-flight Checks Complete ---"
echo ""


echo "============================================="
echo "      STARTING HEADLESS DEV ENV SETUP"
echo "============================================="

# =============================================
# 1. SYSTEM UPDATE AND UPGRADE
# =============================================
echo "--> Section 1: Updating package list and upgrading system..."
apt-get update && apt-get upgrade -y
echo "✅ Section 1 Complete."
echo ""

# =============================================
# 2. INSTALL ESSENTIAL BUILD TOOLS & UTILITIES
# =============================================
echo "--> Section 2: Installing essential build tools..."
apt-get install -y build-essential software-properties-common apt-transport-https \
                   curl wget unzip htop jq
echo "✅ Section 2 Complete."
echo ""

# =============================================
# 3. INSTALL GIT (VERSION CONTROL)
# =============================================
echo "--> Section 3: Installing Git..."
apt-get install -y git
echo "✅ Section 3 Complete."
echo ""


# =============================================
# 4. INSTALL PYTHON 3, PIP, VENV, and UV
# =============================================
echo "--> Section 4: Installing Python, Pip, Venv, and UV..."
echo "   - Installing python3-pip and python3-venv..."
apt-get install -y python3-pip python3-venv
echo "   - Installing uv using pip..."
pip3 install uv
echo "   - Verifying installations..."
python3 --version
pip3 --version
# The uv binary is installed to the root user's local bin when run with sudo.
if [ -f "/root/.local/bin/uv" ]; then
    /root/.local/bin/uv --version
else
    echo "⚠️ Warning: uv executable not found at /root/.local/bin/uv"
fi
echo "✅ Section 4 Complete."
echo ""


# =============================================
# 5. INSTALL NODE.JS (LTS) and NPM
# =============================================
echo "--> Section 5: Installing Node.js (LTS) and npm..."
echo "   - Downloading NodeSource setup script..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
echo "   - Installing nodejs package..."
apt-get install -y nodejs
echo "   - Verifying installations..."
node -v
npm -v
echo "✅ Section 5 Complete."
echo ""


# =============================================
# 6. INSTALL DOCKER AND DOCKER COMPOSE
# =============================================
echo "--> Section 6: Installing Docker and Docker Compose..."
echo "   - Installing prerequisite packages..."
apt-get install -y ca-certificates curl
echo "   - Adding Docker's official GPG key..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "   - Setting up the Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
echo "   - Updating apt package index for Docker repo..."
apt-get update
echo "   - Installing Docker Engine, CLI, Containerd, and Compose plugin..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
echo "   - Adding user '$RUN_USER' to the docker group..."
usermod -aG docker "$RUN_USER"
echo "✅ Section 6 Complete."
echo ""


# =============================================
# 7. INSTALL ZSH AND OH MY ZSH
# =============================================
echo "--> Section 7: Installing Zsh and Oh My Zsh..."
echo "   - Installing zsh package..."
apt-get install -y zsh
echo "   - Installing Oh My Zsh for user '$RUN_USER'..."
sudo -u "$RUN_USER" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
echo "   - Setting Zsh as the default shell for user '$RUN_USER'..."
chsh -s "$(which zsh)" "$RUN_USER"
echo "✅ Section 7 Complete."
echo ""


echo "===================================================================="
echo "           ✅ DEVELOPMENT ENVIRONMENT SETUP COMPLETE! ✅"
echo "===================================================================="
echo ""
echo "IMPORTANT NEXT STEPS:"
echo "1. !! REBOOT THE VIRTUAL MACHINE to apply all changes correctly !!"
echo "   (This is required for the new default shell and Docker permissions)."
echo "2. After rebooting, configure Git with your name and email:"
echo "   git config --global user.name \"Your Name\""
echo "   git config --global user.email \"your.email@example.com\""
echo ""
echo "Happy coding!"
