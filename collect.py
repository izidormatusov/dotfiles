#!/usr/bin/env python3
"""Collects all the dotfiles configs from current home folder to git repo."""

import os
import sys
import shutil


def relative_path(path):
    """Return relative path to this script."""
    script_path = os.path.dirname(sys.argv[0])
    return os.path.abspath(os.path.relpath(path, script_path))


DOTFILES_DIR = relative_path('dotfiles')
HOME_DIR = os.path.expanduser('~')


class DotfilesExclusion(object):
    """Exclude known dotfiles"""

    def __init__(self):
        with open(relative_path('exclusions.txt')) as exclusions_file:
            self._exclusions = [
                line for line in exclusions_file.read().splitlines()
                if line and not line.startswith('#')]

    def is_excluded(self, path):
        """Returns True if the path should be excluded."""
        home_path = os.path.relpath(path, HOME_DIR)
        for exclusion in self._exclusions:
            if home_path.startswith(exclusion):
                return True
        return False


def get_dotfiles(dotfile_path):
    """Yields all dotfiles to be processed."""
    existing_dotfiles = set([])
    for dirpath, dirnames, filenames in os.walk(dotfile_path, topdown=True):
        for filename in filenames + dirnames:
            path = os.path.join(dirpath, filename)
            if os.path.isfile(path) or os.path.islink(path):
                path = os.path.join(HOME_DIR, os.path.relpath(path, DOTFILES_DIR))
                existing_dotfiles.add(path)

    exclusion = DotfilesExclusion()
    for dirpath, dirnames, filenames in os.walk(HOME_DIR, topdown=True):
        # Ignore non-dotfiles dirnames by overriding them. os.walk picks that
        # up and skips these directories.
        if os.path.samefile(dirpath, HOME_DIR):
            dirnames[:] = [name for name in dirnames if name.startswith('.')]

        # Exclude path prefixes as soon as possible
        dirnames[:] = [
            name for name in dirnames
            if not exclusion.is_excluded(os.path.join(dirpath, name))]

        for filename in filenames:
            path = os.path.join(dirpath, filename)
            if exclusion.is_excluded(path):
                continue
            if not os.path.relpath(path, HOME_DIR).startswith('.'):
                continue
            yield path
            if path in existing_dotfiles:
                existing_dotfiles.remove(path)

    # Iterate over the existing dotfiles for updates
    for path in sorted(existing_dotfiles):
        yield path


def copy(source, destination):
    """Copy source to destination.

    If source is a link, copy the link.
    """
    print(os.path.relpath(source, HOME_DIR))

    destination_folder = os.path.dirname(destination)
    if not os.path.exists(destination_folder):
        os.makedirs(destination_folder)

    if os.path.islink(source):
        if os.path.lexists(destination):
            os.unlink(destination)
        os.symlink(os.readlink(source), destination)
    else:
        shutil.copy2(source, destination, follow_symlinks=False)


def main():
    """Copy the files over."""
    for dotfile in get_dotfiles(DOTFILES_DIR):
        source = dotfile
        destination = os.path.join(
                DOTFILES_DIR, os.path.relpath(dotfile, HOME_DIR))
        copy(source, destination)

if __name__ == "__main__":
    main()
