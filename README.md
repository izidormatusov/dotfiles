# My dotfiles

Collection of my dotfiles.

Originally,
[dotfiles module](https://pypi.python.org/pypi/dotfiles) was used for dotfiles
management. That module has serious limitations (e.g. managing a single file
beyond 2nd folder level) and was replaced by my custom script
[dotfiles.py](dotfiles.py). The script keeps the list of manage files/folders in
[.install.list](.install.list) file.

## Installation

    ./dotfiles.py install
