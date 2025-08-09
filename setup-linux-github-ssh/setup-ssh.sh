#!/bin/bash

# ======================================================================================
# GitHub SSH Key Setup Script (Revised)
#
# This script creates a new SSH key, configures SSH to use it for GitHub,
# and provides instructions for adding the public key to your GitHub account.
#
# DO NOT RUN THIS SCRIPT WITH SUDO.
# ======================================================================================

set -euo pipefail
IFS=$'\n\t'

echo "============================================="
echo "      GitHub SSH Key Setup Utility"
echo "============================================="
echo "This script will generate a new SSH key and help you add it to GitHub."
echo ""

# Prevent running with sudo/root
if [ "${EUID:-$(id -u)}" -eq 0 ] || [ -n "${SUDO_USER:-}" ]; then
  echo "❌ Do not run this script with sudo or as root. Run as your regular user."
  exit 1
fi

# --- Step 1: Get User Email ---
read -p "Please enter the email address associated with your GitHub account: " github_email

# Validate that an email was entered
if [ -z "$github_email" ]; then
    echo "❌ No email entered. Aborting."
    exit 1
fi

echo "✅ Using email: $github_email"
echo ""

# --- Step 2: Generate the SSH Key ---
# Using a specific name like 'id_github_ed25519' avoids overwriting other keys.
key_file_path="$HOME/.ssh/id_github_ed25519"

# Check if the key file already exists
if [ -f "$key_file_path" ]; then
    echo "⚠️  SSH key file already exists at '$key_file_path'. Aborting to prevent overwriting."
    echo "    If you want to create a new key, please remove the existing one first."
    exit 1
fi

echo "--> Generating a new ED25519 SSH key..."
ssh-keygen -t ed25519 -f "$key_file_path" -N "" -C "$github_email"

echo ""
echo "⚠️  SECURITY WARNING: A key with no passphrase was generated."
echo "    This is convenient but less secure. Protect your private key file."
echo ""

# --- Step 3: Create/Update SSH Config File ---
echo "--> Configuring SSH to use the new key for GitHub..."
ssh_config_path="$HOME/.ssh/config"
# Create the .ssh directory if it doesn't exist
mkdir -p "$HOME/.ssh"
# Set secure permissions for the .ssh directory
chmod 700 "$HOME/.ssh"

# Add a configuration block for GitHub to the SSH config file
# This tells SSH to use our specific key for any connection to github.com
if ! grep -q "^Host github.com$" "$ssh_config_path" 2>/dev/null; then
  cat <<EOF >> "$ssh_config_path"

# GitHub Configuration for ${github_email}
Host github.com
  HostName github.com
  User git
  IdentityFile ${key_file_path}
  IdentitiesOnly yes
EOF
else
  echo "✅ SSH config already contains a 'Host github.com' entry. Skipping append."
fi

# Set secure permissions for the config file
chmod 600 "$ssh_config_path"
echo "✅ SSH configuration updated at '$ssh_config_path'"
echo ""


# --- Step 4: Display Public Key and Instructions ---
echo "================================================================================"
echo "          ✅ Your SSH Key is Ready. Add it to GitHub. "
echo "================================================================================"
echo ""
echo "Copy the entire block of text below (starting with 'ssh-ed25519')."
echo "--------------------------------- COPY KEY BELOW ---------------------------------"
cat "${key_file_path}.pub"
echo "---------------------------------- END OF KEY ----------------------------------"
echo ""
echo "Now, follow these steps:"
echo "  1. Go to your GitHub SSH keys settings: https://github.com/settings/keys"
echo "  2. Click the 'New SSH key' or 'Add SSH key' button."
echo "  3. Give it a descriptive 'Title' (e.g., 'My Work Laptop')."
echo "  4. Paste the key you copied into the 'Key' field."
echo "  5. Click 'Add SSH key'."
echo ""


# --- Step 5: Test the Connection ---
read -p "Once you have added the key to GitHub, press [Enter] to test the connection..."

echo ""
echo "--> Testing connection to GitHub..."
# The -T command returns an exit code of 1 on success, which would normally
# cause a script with 'set -e' to fail. We add '|| true' to prevent this.
ssh -T git@github.com || true

echo ""
echo "🎉 Setup complete! You should now be able to clone and push to your repositories using SSH."