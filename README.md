# izidor's dotfiles

Collection of my various configs (aka dotfiles) and installation scripts.



## Get started

The philosophy of the dotfiles is that you keep your configs in home and once in
a while you collect them into the dotfiles, submit to the git and publish them.
No symlinking, no forced edits in the dotfiles repo.

Folder structures:

 - [config.yaml](config.yaml) has configuration such as:
   - what non-dotfiles folders to include
   - what folders to exclude as they might not have a human-written config / I
     don't care about them
   - what keys should be ignored from various `.plist` configs
 - [dotfiles/](dotfiles/) contains the configuration files
 - [scripts/](scripts/) has installation scripts. Each script should be
   idempotent
 - [tools/](tools/) has scripts for management.

You can create sub folders in `work/` and `private/` to keep some dotfiles
private (you don't want to leak your work configuration to the internet, right?)

There is a convenient script to manage your dotfiles:

```shell
# Show modified config files and select which ones should be copied to the repo
./management.py
# Override the config files in home
./management.py install
# Interactively choose which script(s) to run
./management.py run
```

The interactive choose is [FZF](https://github.com/junegunn/fzf).
