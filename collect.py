#!/usr/bin/env python3
"""Collects all the dotfiles configs from current home folder to git repo."""

import os
import sys
import shutil

DOTFILES_DIR = 'dotfiles'

def relative_path(path):
    """Return relative path to this script."""
    script_path = os.path.dirname(sys.argv[0])
    return os.path.abspath(os.path.relpath(path, script_path))


class DotfilesExclusion(object):
    """Exclude known dotfiles"""

    def __init__(self):
        with open(relative_path('exclusions.txt')) as exclusions_file:
            self._exclusions = [
                line for line in exclusions_file.read().splitlines()
                if line and not line.startswith('#')]

    def is_excluded(self, path):
        """Returns True if the path should be excluded."""
        home_path = os.path.relpath(path, os.path.expanduser('~'))
        for exclusion in self._exclusions:
            if home_path.startswith(exclusion):
                return True
        return False


def get_dotfiles():
    """Yields all dotfiles to be processed."""
    exclusion = DotfilesExclusion()
    home_folder = os.path.expanduser('~')
    for dirpath, dirnames, filenames in os.walk(home_folder, topdown=True):
        # Ignore non-dotfiles dirnames by overriding them. os.walk picks that
        # up and skips these directories.
        if os.path.samefile(dirpath, home_folder):
            dirnames[:] = [name for name in dirnames if name.startswith('.')]

        # Exclude path prefixes as soon as possible
        dirnames[:] = [
            name for name in dirnames
            if not exclusion.is_excluded(os.path.join(dirpath, name))]

        for filename in filenames:
            path = os.path.join(dirpath, filename)
            if exclusion.is_excluded(path):
                continue
            if not os.path.relpath(path, home_folder).startswith('.'):
                continue
            yield path


def main():
    """Copy the files over."""
    dotfile_path = relative_path(DOTFILES_DIR)
    home_folder = os.path.expanduser('~')
    for dotfile in get_dotfiles():
        source = dotfile
        destination = os.path.join(
                dotfile_path, os.path.relpath(dotfile, home_folder))
        destination_folder = os.path.dirname(destination)
        if not os.path.exists(destination_folder):
            os.makedirs(destination_folder)
        print(dotfile)
        shutil.copy2(source, destination, follow_symlinks=False)

if __name__ == "__main__":
    main()
