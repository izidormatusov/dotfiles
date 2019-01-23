#!/usr/bin/env python3
"""Build and deploy a script of dotfiles from the file."""

import collections
import logging
import os
import sys

DOTFILES_DIR = 'dotfiles'
INSTALL_SCRIPT = 'install'
MINIMAL_CONFIGS = ['tmux', 'bash', 'vim']


def is_minimal_config(path):
    """Is this config a important and should be installed?"""
    for prefix in MINIMAL_CONFIGS:
        if path.startswith('.' + prefix):
            return True
    return False

def get_dotfiles():
    """Returns a mapping of dotfile type => list of dotfiles."""
    current_path = os.path.abspath(os.path.dirname(sys.argv[0]))
    dotfile_path = os.path.join(current_path, DOTFILES_DIR)
    logging.info(dotfile_path)
    dotfiles = collections.defaultdict(list)
    for dirpath, _, filenames in os.walk(dotfile_path):
        for filename in filenames:
            path = os.path.join(dirpath, filename)
            relpath = os.path.relpath(path, dotfile_path)
            config_set = 'minimal' if is_minimal_config(relpath) else 'complete'
            dotfiles[config_set].append((relpath, path))
    return dotfiles


def generate_script(install, dotfiles):
    """Writes the script into install file."""
    install.write('#!/bin/bash\n')
    install.write('CONFIG_SET="${1:-all}"\n')

    last_folder = None
    for config_set in dotfiles:
        install.write(
            '\nif [ $CONFIG_SET = "{}" -o $CONFIG_SET = "all" ]\nthen\n'.format(
                config_set))
        for config_name, config_path in sorted(dotfiles[config_set]):
            folder = os.path.dirname(config_name)
            if folder and folder != last_folder:
                install.write('\nmkdir -p ~/{}\n'.format(folder))
            last_folder = folder
            with open(config_path) as config_file:
                content = config_file.read()
            install.write('\ncat > ~/{} <<"EOF"\n{}EOF\n'.format(
                config_name, content))
        install.write('\nfi\n')


def main():
    """Build dotfiles into a shell script."""
    dotfiles = get_dotfiles()
    with open(INSTALL_SCRIPT, 'w') as install_file:
        generate_script(install_file, dotfiles)

    # Make the script executable
    os.chmod(INSTALL_SCRIPT, 0755)

if __name__ == "__main__":
    main()
