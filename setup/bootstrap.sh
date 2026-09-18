#!/usr/bin/env bash
# setup/bootstrap.sh — from a bare Debian/Ubuntu account to the baseline.
#
#   curl -fsSL https://raw.githubusercontent.com/bricef/dotfiles/master/setup/bootstrap.sh | bash
#
# or, from a checkout, `setup/bootstrap.sh`. Either way it: installs git
# and ansible with apt (the only thing done outside the playbook, because
# the playbook needs them to run); clones this repository to its canonical
# path if it is not there; then runs setup/baseline.yml, which does
# everything else and can be re-run at any time.
#
# Needs sudo. Passwordless sudo just works; otherwise pass -K through:
#   setup/bootstrap.sh -K
#
#   DOTFILES       where the checkout lives   (~/Code/github.com/bricef/dotfiles)
#   DOTFILES_REPO  where to clone it from     (https://github.com/bricef/dotfiles.git —
#                  https so a machine with no GitHub key yet can fetch; the
#                  playbook points origin at the ssh remote afterwards)
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Code/github.com/bricef/dotfiles}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/bricef/dotfiles.git}"

say() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
die() { printf '\n\033[1;31m✗ %s\033[0m\n' "$*" >&2; exit 1; }

command -v apt-get >/dev/null || die "this bootstrap is for Debian/Ubuntu (apt); on another OS run the playbook by hand"
command -v sudo >/dev/null || die "sudo is required"

if ! command -v ansible-playbook >/dev/null || ! command -v git >/dev/null; then
    say "Installing git and ansible"
    # Non-interactive throughout: needrestart otherwise blocks on a TTY that
    # is not there and holds the dpkg lock.
    sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt-get update -qq
    sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt-get install -y -qq git ansible >/dev/null
fi

if [ ! -d "$DOTFILES/.git" ]; then
    say "Cloning $DOTFILES_REPO to $DOTFILES"
    mkdir -p "$(dirname "$DOTFILES")"
    git clone -q "$DOTFILES_REPO" "$DOTFILES"
fi

say "Running the baseline playbook"
exec ansible-playbook "$DOTFILES/setup/baseline.yml" "$@"
