#!/usr/bin/env python3
"""Build an install script installing dotfiles and executing scripts."""

import base64
import collections
import logging
import os
import sys

INSTALL_SCRIPT = 'install'
SCRIPTS_FOLDER = 'scripts'
LIBRARY_FILE = os.path.join(SCRIPTS_FOLDER, 'common.sh')
DOTFILES_DIR = 'dotfiles'
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


def get_scripts():
   """Returns an ordered list of scripts to install."""
   scripts = [os.path.join(SCRIPTS_FOLDER, script)
              for script in os.listdir(SCRIPTS_FOLDER)]
   scripts = [script for script in scripts if script != LIBRARY_FILE]
   return sorted(scripts)


def install_dotfile_content(install, name, path):
    """Generate script that installs a content of dotfile.

    If a dotfile is binary, then use bas64 to decode it.
    """
    with open(path, 'rb') as dotfile:
        content = dotfile.read()
    try:
        content = content.decode('utf-8')
        command = (
            'cat > ~/{} <<"END_OF_DOTFILE"\n'
            '{}END_OF_DOTFILE'.format(name, content))
    except UnicodeDecodeError:
        content = base64.b64encode(content).decode('utf-8')
        command = (
            'base64 --decode --output ~/{} <<"END_OF_DOTFILE"\n'
            '{}\nEND_OF_DOTFILE'.format(name, content))
    install.write('\n{}\n'.format(command))

def install_dotfiles(install, dotfiles):
    """Generates the script that installs dotfiles."""
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
            install_dotfile_content(install, config_name, config_path)



        install.write('\nfi\n\n')

def include_file(install_file, filename):
    """Embeds the file as is in the installation script."""
    with open(filename) as include_file:
        install_file.write(include_file.read())
        install_file.write('\n')

def main():
    """Build dotfiles into a shell script."""
    dotfiles = get_dotfiles()
    scripts = get_scripts()
    with open(INSTALL_SCRIPT, 'w') as install_file:
        include_file(install_file, LIBRARY_FILE)
        install_dotfiles(install_file, dotfiles)
        for script in scripts:
            include_file(install_file, script)

    # Make the script executable
    os.chmod(INSTALL_SCRIPT, 0755)

if __name__ == "__main__":
    main()
