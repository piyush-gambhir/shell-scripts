#!/bin/bash

# ======================================================================================
# GitHub Credential Setup Script (using Personal Access Token)
#
# This script configures the local Git environment to use a PAT for authentication,
# allowing for passwordless git push/pull over HTTPS.
#
# DO NOT RUN THIS SCRIPT WITH SUDO.
# ======================================================================================

echo "============================================="
echo "   GitHub PAT Credential Setup Utility"
echo "============================================="
echo "This script will configure Git to use a Personal Access Token (PAT)."
echo "Please have your PAT, GitHub username, and repository URL ready."
echo ""

# --- Step 1: Gather User Input ---
read -p "Enter your GitHub username: " GITHUB_USERNAME

# The -s flag makes input "silent" so the token is not displayed on screen
read -s -p "Enter your GitHub Personal Access Token (ghp_...): " GITHUB_TOKEN
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
echo "--> Configuring Git to use the 'store' credential helper..."
git config --global credential.helper store
echo "✅ Git credential helper configured."
echo ""

# --- Step 4: Clone the Repository to Cache Credentials ---
echo "--> Cloning the repository to test and cache your credentials..."
echo "    (Your token will be used for this command but not stored in shell history)"

# Construct the authenticated URL
# This replaces "https://github.com" with "https://username:token@github.com"
AUTH_REPO_URL=$(echo "$REPO_URL" | sed "s|://|://$GITHUB_USERNAME:$GITHUB_TOKEN@|")

# Clone the repository
git clone "$AUTH_REPO_URL"

# --- Step 5: Verify the Outcome ---
if [ $? -eq 0 ]; then
    # $? is the exit code of the last command. 0 means success.
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
    echo "  3. Does your token have the correct 'Contents: Read and write' permissions for that specific repository?"
fi