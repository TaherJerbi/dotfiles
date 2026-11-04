#!/usr/bin/env bash
# Pod start hook: the devpod runs this on every start. Only /mnt/persistent
# (= $HOME) survives a pod rebuild, so this puts back what lives outside it.
# Dotfiles themselves are untouched; that's `chezmoi apply`'s job.
set -euo pipefail

bash "$HOME/.config/setup/devpod-deps.sh"
