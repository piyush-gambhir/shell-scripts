#!/bin/bash

# ======================================================================================
# GitHub SSH Key Setup Script
#
# This script guides a user through creating a new SSH key and provides instructions
# for adding it to their GitHub account.
#
# DO NOT RUN THIS SCRIPT WITH SUDO.
# ======================================================================================

echo "============================================="
echo "      GitHub SSH Key Setup Utility"
echo "============================================="
echo "This script will generate a new SSH key and help you add it to GitHub."
echo ""

# --- Step 1: Get User Email ---
read -p "Please enter the email address associated with your GitHub account: " github_email

# Validate that an email was entered
if [ -z "$github_email" ]; then
    echo "❌ No email entered. Aborting."
    exit 1
fi

echo "✅ Using email: $github_email"
echo ""

# Define the SSH key file path
# Using a specific name like 'id_github' avoids overwriting other keys.
key_file_path="$HOME/.ssh/id_github"

# --- Step 2: Generate the SSH Key ---
echo "--> Generating a new ED25519 SSH key..."
# -t specifies the algorithm (ed25519 is recommended)
# -f specifies the filename for the key
# -N "" specifies an empty passphrase (non-interactive)
# -C provides a comment (your email)
ssh-keygen -t ed25519 -f "$key_file_path" -N "" -C "$github_email"

echo ""
echo "⚠️  SECURITY WARNING: A key with no passphrase was generated."
echo "    This is convenient for automated scripts but less secure."
echo "    Protect your private key file ('$key_file_path') as you would a password."
echo ""

# --- Step 3: Start SSH Agent and Add Key ---
echo "--> Starting the ssh-agent..."
# Start the agent and set environment variables for the current session
eval "$(ssh-agent -s)"

echo "--> Adding your new SSH key to the ssh-agent..."
ssh-add "$key_file_path"
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
echo "  1. Open your web browser and go to GitHub."
echo "  2. Click on your profile picture in the top-right corner, then 'Settings'."
echo "  3. In the left sidebar, click 'SSH and GPG keys'."
echo "  4. Click the 'New SSH key' or 'Add SSH key' button."
echo "  5. Give it a descriptive 'Title' (e.g., 'My Ubuntu VM')."
echo "  6. Paste the key you copied into the 'Key' field."
echo "  7. Click 'Add SSH key'."
echo ""


# --- Step 5: Test the Connection ---
read -p "Once you have added the key to GitHub, press [Enter] to test the connection..."

echo ""
echo "--> Testing connection to GitHub..."
# The `ssh -T` command returns an exit code of 1 on success, which would normally
# cause a script with 'set -e' to fail. We add '|| true' to prevent this.
ssh -T git@github.com || true

echo ""
echo "🎉 Setup complete! You should now be able to clone your repositories using SSH."