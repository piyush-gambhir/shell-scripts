#!/bin/bash

# ======================================================================================
# (Final Version) All-Inclusive Headless Ubuntu Development Environment Setup Script
#
# This version uses pipx to install uv, which is a best-practice for Python CLI tools.
# It also includes tmux, a powerful terminal multiplexer.
# ======================================================================================

# Exit on error, use unset vars as errors, and fail on pipeline errors; safer IFS
set -euo pipefail
IFS=$'\n\t'
export DEBIAN_FRONTEND=noninteractive

# --- Pre-flight Checks ---
echo "--- Running Pre-flight Checks ---"

# Basic OS/Package manager guard
if ! command -v apt-get >/dev/null 2>&1; then
  echo "❌ Error: 'apt-get' not found. This script supports Debian/Ubuntu systems."
  exit 1
fi

# Check if running as root/sudo
if [ "$EUID" -ne 0 ]; then
  echo "❌ Error: Please run this script with sudo."
  exit 1
fi
echo "✅ Sudo check passed."

# Determine the user who will receive the configurations (docker group, zsh shell)
if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
    RUN_USER=$SUDO_USER
elif [ -n "$SUDO_USER" ] && [ "$SUDO_USER" = "root" ]; then
    RUN_USER=$SUDO_USER
    echo "⚠️ Warning: Running as root. Zsh and Docker permissions will be applied to the 'root' user."
else
    # This case handles direct execution by a user without sudo.
    # We still need to find a suitable user.
    # The default is to use the 'root' user if no other user is specified.
    RUN_USER="root"
fi

echo "✅ Configurations will be applied to user: $RUN_USER"
echo "--- Pre-flight Checks Complete ---"
echo ""

# Simple retry helper for transient network/lock errors
retry() {
  local attempts=0
  local max_attempts=3
  local delay_seconds=3
  until "$@"; do
    attempts=$((attempts+1))
    if [ "$attempts" -ge "$max_attempts" ]; then
      echo "❌ Command failed after ${attempts} attempts: $*"
      return 1
    fi
    echo "⚠️ Command failed (attempt ${attempts}/${max_attempts}): $*"
    echo "   Retrying in ${delay_seconds}s..."
    sleep "$delay_seconds"
  done
}

echo "============================================="
echo "      STARTING HEADLESS DEV ENV SETUP"
echo "============================================="

# =============================================
# 1. SYSTEM UPDATE AND UPGRADE
# =============================================
echo "--> Section 1: Updating package list and upgrading system..."
retry apt-get update -qq
retry apt-get upgrade -y -qq
echo "✅ Section 1 Complete."
echo ""

# =============================================
# 2. INSTALL ESSENTIAL BUILD TOOLS & UTILITIES
# =============================================
echo "--> Section 2: Installing essential build tools..."
retry apt-get install -y -qq build-essential software-properties-common apt-transport-https \
                   curl wget unzip htop jq
echo "✅ Section 2 Complete."
echo ""

# =============================================
# 3. INSTALL GIT (VERSION CONTROL)
# =============================================
echo "--> Section 3: Installing Git..."
if ! command -v git &> /dev/null; then
    retry apt-get install -y -qq git
    echo "✅ Git installed successfully."
else
    echo "✅ Git is already installed."
fi
echo "✅ Section 3 Complete."
echo ""


# =============================================
# 4. INSTALL PYTHON, PIP, VENV, PIPX, and UV
# =============================================
echo "--> Section 4: Installing Python tools..."

if ! command -v pipx &> /dev/null; then
    echo "   - Installing python3-pip, python3-venv, and pipx via apt..."
    retry apt-get install -y -qq python3-pip python3-venv pipx
else
    echo "✅ pipx is already installed."
fi

# Switch to the target user to run pipx, which respects user-level configurations
# This is crucial for uv to be installed in the correct user's path.
if ! command -v uv &> /dev/null; then
    echo "   - Using pipx to install uv..."
    su -c "pipx install uv" -s /bin/sh "$RUN_USER"
    echo "✅ uv installed successfully."
else
    echo "✅ uv is already installed."
fi

# Ensure PATH for pipx-installed tools for the target user
su - "$RUN_USER" -s /bin/bash -c 'pipx ensurepath >/dev/null 2>&1 || true'

echo "   - Verifying installations..."
python3 --version
pip3 --version
pipx --version
su - "$RUN_USER" -s /bin/bash -c 'uv --version'
echo "✅ Section 4 Complete."
echo ""


# =============================================
# 5. INSTALL NODE.JS (LTS) and NPM
# =============================================
echo "--> Section 5: Installing Node.js (LTS) and npm..."
if ! command -v node &> /dev/null; then
    echo "   - Downloading NodeSource setup script..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    echo "   - Installing nodejs package..."
    retry apt-get install -y -qq nodejs
    echo "✅ Node.js and npm installed successfully."
else
    echo "✅ Node.js and npm are already installed."
fi
echo "   - Verifying installations..."
node -v
npm -v
echo "✅ Section 5 Complete."
echo ""


# =============================================
# 6. INSTALL DOCKER AND DOCKER COMPOSE
# =============================================
echo "--> Section 6: Installing Docker and Docker Compose..."
if ! command -v docker &> /dev/null; then
    echo "   - Installing prerequisite packages..."
    retry apt-get install -y -qq ca-certificates curl
    echo "   - Adding Docker's official GPG key..."
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    echo "   - Setting up the Docker repository..."
    if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
          $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    fi
    echo "   - Updating apt package index for Docker repo..."
    retry apt-get update -qq
    echo "   - Installing Docker Engine, CLI, Containerd, and Compose plugin..."
    retry apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    echo "✅ Docker installed successfully."
else
    echo "✅ Docker is already installed."
fi

# Add user to the docker group if not already a member
if ! groups "$RUN_USER" | grep -q '\bdocker\b'; then
    echo "   - Adding user '$RUN_USER' to the docker group..."
    usermod -aG docker "$RUN_USER"
    echo "✅ User '$RUN_USER' added to the docker group."
    echo "   - Note: You may need to log out and back in, or reboot, for group changes to take effect."
else
    echo "✅ User '$RUN_USER' is already a member of the docker group."
fi
echo "✅ Section 6 Complete."
echo ""


# =============================================
# 7. INSTALL ZSH AND OH MY ZSH
# =============================================
echo "--> Section 7: Installing Zsh and Oh My Zsh..."
if ! command -v zsh &> /dev/null; then
    echo "   - Installing zsh package..."
    apt-get install -y zsh
    echo "✅ Zsh installed successfully."
else
    echo "✅ Zsh is already installed."
fi

# Install Oh My Zsh if it's not already there
if [ ! -d "/home/$RUN_USER/.oh-my-zsh" ]; then
    echo "   - Installing Oh My Zsh for user '$RUN_USER'..."
    su -c "curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash -s -- --unattended" -s /bin/sh "$RUN_USER"
    echo "✅ Oh My Zsh installed successfully for user '$RUN_USER'."
else
    echo "✅ Oh My Zsh is already installed for user '$RUN_USER'."
fi

# Change default shell to Zsh for the user
if [ "$(getent passwd "$RUN_USER" | cut -d: -f7)" != "$(which zsh)" ]; then
    echo "   - Setting Zsh as the default shell for user '$RUN_USER'..."
    chsh -s "$(which zsh)" "$RUN_USER"
    echo "✅ Default shell for '$RUN_USER' is now Zsh."
else
    echo "✅ Default shell for '$RUN_USER' is already Zsh."
fi
echo "✅ Section 7 Complete."
echo ""

# =============================================
# 8. INSTALL TMUX (TERMINAL MULTIPLEXER)
# =============================================
echo "--> Section 8: Installing tmux..."
if ! command -v tmux &> /dev/null; then
    apt-get install -y tmux
    echo "✅ tmux installed successfully."
else
    echo "✅ tmux is already installed."
fi
echo "   - Verifying installation..."
tmux -V
echo "✅ Section 8 Complete."
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
echo "3. Learn to use tmux for powerful terminal multitasking."
echo "   - To start a new session, simply type 'tmux'."
echo "   - To detach, press 'Ctrl+b' then 'd'."
echo "   - To reattach, type 'tmux attach'."
echo ""
echo "Happy coding!"