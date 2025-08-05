# GitHub SSH Key Setup Script

This script provides a simple, interactive way to generate a new SSH key and configure it for use with your GitHub account. It automates the command-line steps, displays your public key, and guides you through the process of adding it to GitHub to enable passwordless `git` operations.

## What This Script Does

  * Prompts for your GitHub email address to associate with the key.
  * Generates a new, secure **ED25519** SSH key pair named `id_github` in your `~/.ssh` directory.
  * Creates the key **without a passphrase** for convenient, non-interactive use in scripts and on servers.
  * Starts the `ssh-agent` in the background and adds the new private key to it.
  * Displays the public key for you to copy.
  * Provides clear step-by-step instructions for adding the key to your GitHub account.
  * Pauses and waits for you to complete the manual step on the GitHub website.
  * Tests the SSH connection to GitHub to verify the setup is successful.

## Prerequisites

  * A Unix-like environment (Linux, macOS, etc.).
  * The `openssh-client` package installed (which provides `ssh-keygen` and `ssh-agent`). This is included by default on most systems, including Ubuntu Server.
  * A GitHub account.

## How to Use

Follow these steps to run the script and configure your SSH key.

### Step 1: Create the Script File

Log into your VM or terminal and use a text editor like `nano` to create the script file.

```bash
nano setup_github_ssh.sh
```

Copy the entire contents of the `setup_github_ssh.sh` script and paste it into the editor. Save and exit by pressing `Ctrl + X`, then `Y`, then `Enter`.

### Step 2: Make the Script Executable

Give the script the necessary permissions to be run.

```bash
chmod +x setup_github_ssh.sh
```

### Step 3: Run the Script

Execute the script from your terminal.

> **IMPORTANT:** Do not run this script with `sudo`. It is designed to set up SSH keys for your **current user**, not the root user. Running it with `sudo` will place the keys in the root user's home directory, which is incorrect.

```bash
./setup_github_ssh.sh
```

## The Workflow: What to Expect

The script is interactive. Here is the process you will follow:

1.  **Enter Your Email:** The script will first ask for the email address associated with your GitHub account.
2.  **Copy the Public Key:** After generating the key, the script will display the public key on the screen and pause. You need to highlight and copy this entire block of text.
3.  **Add Key to GitHub:** While the script is paused, open a web browser and follow the on-screen instructions to add the copied key to your GitHub account's SSH settings.
4.  **Test the Connection:** Once you have successfully added the key on the GitHub website, return to your terminal and press `Enter`. The script will then test the connection to verify that everything is working.

## Security Note

This script intentionally creates an SSH key without a passphrase. This is highly convenient for automated processes and servers, as it prevents interactive prompts. However, this means that the security of your key rests entirely on the security of the private key file (`~/.ssh/id_github`). Protect this file as you would a password. Anyone who gains access to this file will have access to your GitHub account.