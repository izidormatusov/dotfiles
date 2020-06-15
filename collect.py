#!/usr/bin/env python3
"""Collects all the dotfiles configs from current home folder to git repo."""

import os
import plistlib
import shutil
import stat
import sys

import yaml


def relative_path(path):
    """Return relative path to this script."""
    script_path = os.path.dirname(sys.argv[0])
    return os.path.abspath(os.path.relpath(path, script_path))


DOTFILES_DIR = relative_path('dotfiles')
CONFIG_FILE = relative_path('config.yaml')
HOME_DIR = os.path.expanduser('~')

MAC_PREFERENCES_DIR = 'Library/Preferences/'
MAC_PREFERENCES_SUFFIX = '.plist'


class Config(object):
    """Configuration for the configuration"""

    def __init__(self, config_path):
        with open(config_path) as config_file:
            self._config = yaml.load(config_file, Loader=yaml.FullLoader)

        self._config['plist_exclusions'] = {
                key: set(values)
                for key, values in self._config.get('plist_exclusions', {}).items()}

    def is_excluded(self, path):
        """Returns True if the path should be excluded."""
        home_path = os.path.relpath(path, HOME_DIR)
        for exclusion in self._config.get('exclusions', []):
            if home_path.startswith(exclusion):
                return True
        return False

    def is_plist_excluded(self, app_name, key):
        """Returns True if the app excludes the given setting."""
        return key in self._config['plist_exclusions'].get(app_name, set())


def get_dotfiles(dotfile_path, config):
    """Yields all dotfiles to be processed."""
    existing_dotfiles = set([])
    for dirpath, dirnames, filenames in os.walk(dotfile_path, topdown=True):
        for filename in filenames + dirnames:
            path = os.path.join(dirpath, filename)
            if os.path.isfile(path) or os.path.islink(path):
                path = os.path.join(HOME_DIR, os.path.relpath(path, DOTFILES_DIR))
                if os.path.exists(path):
                  existing_dotfiles.add(path)

    for dirpath, dirnames, filenames in os.walk(HOME_DIR, topdown=True):
        # Ignore non-dotfiles dirnames by overriding them. os.walk picks that
        # up and skips these directories.
        if os.path.samefile(dirpath, HOME_DIR):
            dirnames[:] = [name for name in dirnames if name.startswith('.')]

        # Exclude path prefixes as soon as possible
        dirnames[:] = [
            name for name in dirnames
            if not config.is_excluded(os.path.join(dirpath, name))]

        for filename in filenames:
            path = os.path.join(dirpath, filename)
            if config.is_excluded(path):
                continue
            if not os.path.relpath(path, HOME_DIR).startswith('.'):
                continue
            yield path
            if path in existing_dotfiles:
                existing_dotfiles.remove(path)

    # Iterate over the existing dotfiles for updates
    for path in sorted(existing_dotfiles):
        yield path


def is_macos_plist(filename):
    """Heuristic to detect MacOS plists."""
    relpath = os.path.relpath(filename, HOME_DIR)
    return (
            relpath.startswith(MAC_PREFERENCES_DIR) and
            relpath.endswith(MAC_PREFERENCES_SUFFIX))


def copy_plist(source, destination, config):
    """Copy the MacOS preferences.

    - Convert the binary format into easy-to-read XML
    - Drop undesired preferences
    """
    with open(source, 'rb') as source_file:
        settings = plistlib.load(source_file)

    app_name = os.path.basename(source)
    assert app_name.endswith(MAC_PREFERENCES_SUFFIX), (
            'Invalid app name: %s' % app_name)
    app_name = app_name[:-len(MAC_PREFERENCES_SUFFIX)]

    for key in list(settings.keys()):
        if config.is_plist_excluded(app_name, key):
            del settings[key]

    with open(destination, 'wb') as destination_file:
        plistlib.dump(settings, destination_file, fmt=plistlib.FMT_XML)

    chmod_mode = stat.S_IMODE(os.lstat(source).st_mode)
    os.chmod(destination, chmod_mode)


def copy(source, destination, config):
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
    elif is_macos_plist(source):
        copy_plist(source, destination, config)
    else:
        shutil.copy2(source, destination, follow_symlinks=False)


def main():
    """Copy the files over."""
    config = Config(CONFIG_FILE)
    for dotfile in get_dotfiles(DOTFILES_DIR, config):
        source = dotfile
        destination = os.path.join(
                DOTFILES_DIR, os.path.relpath(dotfile, HOME_DIR))
        copy(source, destination, config)

if __name__ == "__main__":
    main()
