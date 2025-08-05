Understood. We will now create the final, all-inclusive script that installs everything we've discussed.

This script will set up a complete, headless development environment by default, including:

  * Core system utilities (`jq`, `htop`, etc.)
  * Git
  * Python, pip, and `uv`
  * Node.js (LTS) and npm
  * Docker and Docker Compose
  * **Zsh and the Oh My Zsh framework**, setting it as the default shell.

This is the definitive script based on all your requests.

-----

### Instructions

1.  **Create the file:**

    ```bash
    nano setup_dev_env.sh
    ```

2.  **Copy and Paste:**
    Copy the entire script below and paste it into the editor.

3.  **Save and Exit:**
    Press `Ctrl + X`, then `Y`, then `Enter`.

4.  **Make it Executable:**

    ```bash
    chmod +x setup_dev_env.sh
    ```

5.  **Run the Script:**
    Execute it with `sudo`. It will run automatically.

    ```bash
    sudo ./setup_dev_env.sh
    ```

-----

### The Final All-Inclusive Script: `setup_dev_env.sh`

```sh
#!/bin/bash

# ======================================================================================
# All-Inclusive Headless Ubuntu Development Environment Setup Script
#
# This script installs and configures a comprehensive, CLI-focused development
# environment on a fresh Ubuntu server. It includes, by default:
#   - Core build tools and utilities (including jq)
#   - Git version control
#   - Python 3, pip, venv, and the fast 'uv' installer
#   - Node.js (LTS) and npm
#   - Docker and Docker Compose
#   - Zsh and the Oh My Zsh framework
#
# Designed for a non-GUI server environment.
# ======================================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if running as root/sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
fi

echo "============================================="
echo "      STARTING HEADLESS DEV ENV SETUP"
echo "============================================="

# =============================================
# 1. SYSTEM UPDATE AND UPGRADE
# =============================================
echo "--> Updating package list and upgrading system..."
apt-get update && apt-get upgrade -y

# =============================================
# 2. INSTALL ESSENTIAL BUILD TOOLS & UTILITIES
# =============================================
echo "--> Installing build-essential, curl, wget, unzip, htop, jq..."
apt-get install -y build-essential software-properties-common apt-transport-https \
                   curl wget unzip htop jq

# =============================================
# 3. INSTALL GIT (VERSION CONTROL)
# =============================================
echo "--> Installing Git..."
apt-get install -y git

echo "--> Git has been installed."
echo "--> IMPORTANT: Configure Git with your details manually after setup:"
echo "    git config --global user.name \"Your Name\""
echo "    git config --global user.email \"your.email@example.com\""


# =============================================
# 4. INSTALL PYTHON 3, PIP, VENV, and UV
# =============================================
echo "--> Installing Python 3, pip, and venv..."
apt-get install -y python3-pip python3-venv

echo "--> Installing uv (the fast Rust-based Python installer) using pip..."
pip3 install uv

echo "--> Verifying Python, Pip, and uv installation..."
python3 --version
pip3 --version
# The uv binary is installed to the root user's local bin when run with sudo.
/root/.local/bin/uv --version


# =============================================
# 5. INSTALL NODE.JS (LTS) and NPM
# =============================================
echo "--> Installing Node.js (LTS version) and npm..."
# Use the official NodeSource repository for a recent version.
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
apt-get install -y nodejs

echo "--> Verifying Node.js and npm installation..."
node -v
npm -v


# =============================================
# 6. INSTALL DOCKER AND DOCKER COMPOSE
# =============================================
echo "--> Installing Docker..."
apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

echo "--> Installing Docker Engine, CLI, Containerd, and Compose plugin..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "--> Adding current user to the docker group..."
# This adds the user who invoked `sudo` to the 'docker' group.
usermod -aG docker ${SUDO_USER:-$USER}


# =============================================
# 7. INSTALL ZSH AND OH MY ZSH
# =============================================
echo "--> Installing Zsh..."
apt-get install -y zsh

echo "--> Installing Oh My Zsh for the current user..."
# The following command is run as the user who invoked sudo, not as root.
# The --unattended flag prevents it from starting an interactive zsh session.
sudo -u ${SUDO_USER:-$USER} sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "--> Setting Zsh as the default shell for the user..."
chsh -s $(which zsh) ${SUDO_USER:-$USER}


echo "===================================================================="
echo "           ✅ DEVELOPMENT ENVIRONMENT SETUP COMPLETE! ✅"
echo "===================================================================="
echo ""
echo "IMPORTANT NEXT STEPS:"
echo "1. !! REBOOT THE VIRTUAL MACHINE to apply all changes correctly !!"
echo "   (This is required for the new default shell and Docker permissions)."
echo "2. After rebooting, configure Git with your name and email."
echo ""
echo "Your new default shell will be Zsh. Enjoy the enhanced features!"
echo "Happy coding!"
```
