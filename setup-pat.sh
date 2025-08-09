#!/bin/bash

# ======================================================================================
# GitHub Credential Setup Script (using Personal Access Token)
#
# This script configures the local Git environment to use a PAT for authentication,
# allowing for passwordless git push/pull over HTTPS.
#
# DO NOT RUN THIS SCRIPT WITH SUDO.
# ======================================================================================

set -euo pipefail
IFS=$'\n\t'

echo "============================================="
echo "   GitHub PAT Credential Setup Utility"
echo "============================================="
echo "This script will configure Git to use a Personal Access Token (PAT)."
echo "Please have your PAT, GitHub username, and repository URL ready."
echo ""

# Prevent running with sudo/root
if [ "${EUID:-$(id -u)}" -eq 0 ] || [ -n "${SUDO_USER:-}" ]; then
  echo "❌ Do not run this script with sudo or as root. Run as your regular user."
  exit 1
fi

# --- Step 1: Gather User Input ---
read -p "Enter your GitHub username: " GITHUB_USERNAME

# The -s flag makes input "silent" so the token is not displayed on screen
read -s -p "Enter your GitHub Personal Access Token (starts with 'gh'): " GITHUB_TOKEN
echo "" # Add a newline after the silent prompt

read -p "Enter the full HTTPS URL of the repository to clone (e.g., https://github.com/user/repo.git): " REPO_URL

# --- Step 2: Validate Input ---
if [ -z "$GITHUB_USERNAME" ] || [ -z "$GITHUB_TOKEN" ] || [ -z "$REPO_URL" ]; then
    echo ""
    echo "❌ Error: Username, Token, and Repository URL cannot be empty. Aborting."
    exit 1
fi

# --- Step 3: Configure Git Credential Helper ---
echo ""
echo "--> Configuring Git credential helper to 'store' (plaintext in ~/.git-credentials)..."
echo "    Tip: Consider using GitHub CLI (gh) or a keyring helper for better security."
git config --global credential.helper store
echo "✅ Git credential helper configured."
echo ""

# --- Step 4: Pre-approve credentials securely (avoid embedding token in remote URL) ---
echo "--> Storing credentials for github.com in the credential store..."
cat <<EOF | git credential approve
protocol=https
host=github.com
username=${GITHUB_USERNAME}
password=${GITHUB_TOKEN}
EOF
echo "✅ Credentials stored for github.com."
echo ""

# --- Step 5: Clone the repository using clean URL ---
echo "--> Cloning the repository..."
if git clone "$REPO_URL"; then
    echo ""
    echo "======================================================================="
    echo "🎉 SUCCESS! The repository was cloned and your token is now cached."
    echo "======================================================================="
    echo "You can now run 'git pull' and 'git push' from within the new"
    echo "repository directory without entering your credentials again."
else
    echo ""
    echo "======================================================================="
    echo "❌ ERROR: The 'git clone' command failed."
    echo "======================================================================="
    echo "Please check the following:"
    echo "  1. Is the repository URL correct?"
    echo "  2. Is your Personal Access Token correct?"
    echo "  3. Does your token have the correct permissions for the repository?"
    exit 1
fi