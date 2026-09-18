# Brice's Dotfiles

## A new machine

From a bare Debian/Ubuntu account with sudo:

```sh
curl -fsSL https://raw.githubusercontent.com/bricef/dotfiles/master/setup/bootstrap.sh | bash
```

That installs git and ansible, clones this repository to
`~/Code/github.com/bricef/dotfiles`, and runs [`setup/baseline.yml`](setup/baseline.yml):
zsh with oh-my-zsh as the login shell, starship, every tool
[`bin/env-audit`](bin/env-audit) checks for, gh, claude, and the dotfiles
stowed into `$HOME`. Files already in the way (a fresh account's `.bashrc`,
`.profile`) are moved to `~/.dotfiles-backup-<date>/`, never deleted. The
play ends by running `env-audit` and starting a login zsh, and fails if
either complains.

Re-run it any time — `ansible-playbook setup/baseline.yml` from the
checkout (`-K` if sudo wants a password); a second run changes nothing.
Versions that are pinned (Go, asdf, wtf) are at the top of the play.

What it leaves to you: `gh auth login`, the first `claude` run (both OAuth),
and an ssh key on GitHub so pushes work — origin is already the ssh remote.

## Using GNU Stow

[GNU Stow](https://www.gnu.org/software/stow/) can be used to symlink the home directory locations to this repo.

to set up the symlinks, navigate to the root of the dotfiles repository and run 

```sh
$ stow --simulate --target /home/brice/ .
```

This will symlink the home directory to the dotfiles repository.

Note that the above command will perform a dry-run. Remove the `--simulate` flag to create the symlibnks for real.

