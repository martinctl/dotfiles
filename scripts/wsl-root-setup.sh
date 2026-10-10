#!/usr/bin/env bash
# Root part of a fresh WSL (Ubuntu) setup. Run it once with:
#   sudo bash ~/dev/dotfiles/scripts/wsl-root-setup.sh
# (or from Windows, without a password: wsl -u root -- bash /home/<user>/dev/dotfiles/scripts/wsl-root-setup.sh <user>)
# Run it again after Homebrew is installed so that fish becomes the login shell.
set -euo pipefail
U="${1:-${SUDO_USER:-}}"
[ -n "$U" ] || { echo "Usage: sudo bash $0   (or, as root: bash $0 <user>)" >&2; exit 1; }

apt-get update
apt-get -y upgrade
# Basics (unzip for fnm, build-essential for go test -race, Homebrew and native modules)
apt-get install -y unzip zip build-essential ca-certificates curl gnupg jq git
install -m 0755 -d /etc/apt/keyrings
ARCH=$(dpkg --print-architecture); CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")

# Docker Engine (official Docker repository)
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $CODENAME stable" > /etc/apt/sources.list.d/docker.list
# GitHub CLI (official GitHub repository)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /etc/apt/keyrings/githubcli-archive-keyring.gpg
chmod a+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin gh

# Docker without sudo, started with WSL
usermod -aG docker "$U"
systemctl enable --now docker

# Homebrew: its folder belongs to the user, so it installs without sudo afterwards
mkdir -p /home/linuxbrew/.linuxbrew
chown -R "$U:$U" /home/linuxbrew

# fish as the login shell (once Homebrew has installed it)
FISH=/home/linuxbrew/.linuxbrew/bin/fish
if [ -x "$FISH" ]; then
  grep -qx "$FISH" /etc/shells || echo "$FISH" >> /etc/shells
  chsh -s "$FISH" "$U"
fi

echo
echo "Done. Close and reopen the Ubuntu terminal."
