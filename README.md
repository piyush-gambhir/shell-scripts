# shell-scripts

A small collection of personal shell scripts for bootstrapping a new Linux dev box and configuring GitHub access.

## Contents

| Path | What it does |
|---|---|
| [`setup-pat.sh`](setup-pat.sh) | Configure git's credential store with a GitHub Personal Access Token, then clone a repo over HTTPS without re-entering credentials |
| [`setup-linux-github-ssh/setup-ssh.sh`](setup-linux-github-ssh/setup-ssh.sh) | Generate a passphrase-less ED25519 SSH key (`~/.ssh/id_github`), add it to `ssh-agent`, walk you through adding it on github.com, and verify with `ssh -T` |
| [`setup-linux-dev-env/run.sh`](setup-linux-dev-env/run.sh) | Provision a headless Ubuntu 22.04/24.04 box with build tools, git, Python (`pipx` + `uv`), Node LTS, Docker, Zsh + Oh My Zsh, and tmux |

Each subdirectory has its own `Readme.md` with full usage notes.

## Usage

### GitHub PAT credential setup

```bash
./setup-pat.sh
# Prompts: GitHub username, PAT (silent), repo URL.
# Stores credentials via `git credential approve` (avoids embedding token in URL),
# then clones the repo. Refuses to run as root.
```

### GitHub SSH key setup

```bash
cd setup-linux-github-ssh
./setup-ssh.sh
# Prompts for your GitHub email, generates ~/.ssh/id_github,
# prints the public key, pauses while you add it on github.com,
# then runs `ssh -T git@github.com` to verify.
```

Do not run with `sudo` — the key must belong to your user, not root.

### Headless Ubuntu dev environment

```bash
cd setup-linux-dev-env
chmod +x run.sh
sudo ./run.sh
sudo reboot   # required: applies docker group membership and zsh as default shell
```

Idempotent-safe — can be re-run. Targets Ubuntu Server LTS (22.04, 24.04). After reboot, set your git identity:

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

## License

MIT
