# Brice's Dotfiles

## Using GNU Stow

[GNU Stow](https://www.gnu.org/software/stow/) can be used to symlink the home directory locations to this repo.

to set up the symlinks, navigate to the root of the dotfiles repository and run 

```sh
$ stow --simulate --target /home/brice/ .
```

This will symlink the home directory to the dotfiles repository.

Note that the above command will perform a dry-run. Remove the `--simulate` flag to create the symlibnks for real.

