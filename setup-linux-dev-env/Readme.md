Of course. Here is a complete `README.md` file that explains the script, its features, and how to use it. This file is designed to be placed in a repository (like on GitHub) alongside the `setup_dev_env.sh` script.

You can save this content as `README.md`.

-----

# Ubuntu Headless Development Environment Setup

This repository contains a comprehensive shell script, `setup_dev_env.sh`, designed to automate the setup of a complete, modern development environment on a headless Ubuntu server.

The script is idempotent-safe (can be run multiple times without causing issues) and is optimized for recent Ubuntu LTS releases (22.04, 24.04). It handles common setup hurdles, such as the `externally-managed-environment` error for Python packages.

## Features

This single script will provision your VM with the following tools and configurations:

  * **System Update:** Fully updates and upgrades all system packages via `apt`.
  * **Core Build Tools:** Installs `build-essential`, `curl`, `wget`, `htop`, `jq`, and other common utilities.
  * **Version Control:** Installs the latest version of **Git**.
  * **Python Environment:**
      * Installs **Python 3**, **pip**, and **venv**.
      * Installs **pipx** for managing Python CLI applications in isolated environments.
      * Installs the high-performance package manager **uv** using `pipx`.
  * **Node.js Environment:**
      * Installs the latest Long-Term Support (LTS) version of **Node.js**.
      * Installs **npm** (Node Package Manager).
  * **Containerization:**
      * Installs **Docker Engine** and **Docker Compose**.
      * Adds the executing user to the `docker` group to allow running Docker commands without `sudo`.
  * **Enhanced Shell:**
      * Installs the **Z shell (Zsh)**.
      * Installs the **Oh My Zsh** framework to manage Zsh configuration.
      * Sets Zsh as the default shell for the user.

## Requirements

  * A server or VM running a fresh installation of **Ubuntu Server 22.04 LTS** or **24.04 LTS**.
  * Internet access from the VM to download packages and scripts.
  * Access to a user with `sudo` privileges.

## How to Use

Follow these three simple steps to set up your environment.

### Step 1: Get the Script

Log into your Ubuntu server and create the script file using `nano` (or your preferred editor).

```bash
nano setup_dev_env.sh
```

Copy the entire content of the final `setup_dev_env.sh` script and paste it into the `nano` editor. Save and exit by pressing `Ctrl + X`, then `Y`, then `Enter`.

### Step 2: Make the Script Executable

Give the script execute permissions so that it can be run.

```bash
chmod +x setup_dev_env.sh
```

### Step 3: Run the Script

Execute the script with `sudo`. It requires administrative privileges to install system-wide packages.

```bash
sudo ./setup_dev_env.sh
```

The script will now run, providing detailed output for each step of the installation process. It will take several minutes to complete.

## Crucial Post-Installation Steps

After the script finishes, you **must** perform the following steps to finalize the setup.

1.  **Reboot the System**
    This is not optional. A reboot is required to apply two key changes:

      * The user's new group membership (`docker`).
      * The change of the default login shell to Zsh.

    <!-- end list -->

    ```bash
    sudo reboot
    ```

2.  **Configure Git**
    After you log back in, configure Git with your personal details. This is essential for version control.

    ```bash
    git config --global user.name "Your Name"
    git config --global user.email "your.email@example.com"
    ```

## Verification

After rebooting and logging back in, you can verify that everything was installed correctly by running the following commands:

```bash
# Check the shell (should output /bin/zsh or /usr/bin/zsh)
echo $SHELL

# Check Docker version (should run without sudo)
docker --version

# Check Node.js and npm versions
node -v
npm -v

# Check Python and pip versions
python3 --version
pip3 --version

# Check uv and pipx versions
uv --version
pipx --version
```

Your development environment is now ready. Happy coding\!