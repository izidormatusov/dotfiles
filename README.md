# izidor's dotfiles

Collection of my various configs (aka dotfiles) and installation scripts.

## Get started

Config files are stored under directory [dotfiles/](dotfiles/). They can be converted to
an instalation script by running:

```shell
./build.py
```

To install the configs and run provisioning scripts:

```shell
./install
```

Install profiles:

 - `./install minimal` will install important configs (bash/vim/tmux) only. No
   scripted provisioning will happen
 - `./install all` will install all configs but no provisioning will happen
 - `./install scripts` will only provision
 - `./install` (default) will install all configs and run provision

The configs can be pulled from your home directory to dotfiles:

```shell
./collect.py --no-dry_run
```
