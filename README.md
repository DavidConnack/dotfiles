# dotfiles

The `init.sh` script will add all the relevant symlinks in order to link the apps to their relevant configs.

## Touch ID for sudo (incl. tmux)

`init.sh` installs `pam/sudo_local` to `/etc/pam.d/sudo_local`, enabling fingerprint
auth for `sudo` in the terminal. `/etc/pam.d/sudo` already `include`s `sudo_local`,
and that file survives macOS updates.

[`pam-reattach`](https://github.com/fabianishere/pam_reattach) (from the Brewfile) is
loaded first so Touch ID also works **inside tmux/screen** — without it, `pam_tid.so`
fails to reach the GUI session and silently falls back to a password prompt.

Installing `sudo_local` requires `sudo`, so on a fresh machine `init.sh` will prompt
for your password once (Touch ID isn't set up yet at that point).
