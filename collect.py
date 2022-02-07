#!/usr/bin/env python3
"""Collects all the dotfiles configs from current home folder to git repo."""

from pathlib import Path
from enum import Enum, auto

import argparse
import difflib
import os
import plistlib
import shutil
import stat
import sys

import yaml


BASE_FOLDER = Path(sys.argv[0]).parent.resolve()
DOTFILES_DIR = BASE_FOLDER / 'dotfiles'
CONFIG_FILE = BASE_FOLDER / 'config.yaml'

MAC_PREFERENCES_DIR = Path.home() / 'Library/Preferences/'
MAC_PREFERENCES_SUFFIX = '.plist'


class Config(object):
    """Configuration for the configuration"""

    def __init__(self, config_path):
        with config_path.open() as config_file:
            self._config = yaml.load(config_file, Loader=yaml.FullLoader)

        self._config['plist_exclusions'] = {
                key: set(values)
                for key, values in self._config.get('plist_exclusions', {}).items()}

    def is_excluded(self, path):
        """Returns True if the path should be excluded.

        Allow text prefix exclusion, i.e. .config/foo- should match
        .config/foo-A and .config/foo-B
        """
        path = str(path.relative_to(Path.home()))
        for exclusion in self._config.get('exclusions', []):
            if path.startswith(exclusion):
                return True
        return False

    def is_plist_excluded(self, app_name, key):
        """Returns True if the app excludes the given setting."""
        return key in self._config['plist_exclusions'].get(app_name, set())


def get_dotfiles(dotfile_path, config):
    """Yields all dotfiles to be processed."""
    dotfiles = set()

    for dirpath, dirnames, filenames in os.walk(dotfile_path, topdown=True):
        dirpath = Path(dirpath)
        for filename in filenames + dirnames:
            path = dirpath / filename
            if path.is_file() or path.is_symlink():
                path = Path.home() / path.relative_to(DOTFILES_DIR)
                if path.exists():
                    dotfiles.add(path)

    for dirpath, dirnames, filenames in os.walk(Path.home(), topdown=True):
        dirpath = Path(dirpath)

        # Ignore non-dotfiles dirnames by overriding them. os.walk picks that
        # up and skips these directories.
        if dirpath.samefile(Path.home()):
            dirnames[:] = [name for name in dirnames if name.startswith('.')]

        # Exclude path prefixes as soon as possible
        dirnames[:] = [
            name for name in dirnames if not config.is_excluded(dirpath / name)]

        # Exclude .git folders
        dirnames[:] = [name for name in dirnames if name != '.git']

        for filename in filenames:
            path = dirpath / filename
            if config.is_excluded(path):
                continue
            if not str(path.relative_to(Path.home())).startswith('.'):
                continue
            dotfiles.add(path)

    return dotfiles


class FileState:
    def __init__(self, state, path, diff=None):
        self.state = state
        self.path = path
        self.diff = diff

    @classmethod
    def _make_diff(cls, source_value, destination_value, source, destination):
        """Generate nice looking diff."""
        lines = []
        source_value = [line + '\n' for line in source_value.splitlines()]
        destination_value = [
                line + '\n' for line in destination_value.splitlines()]

        for line in difflib.unified_diff(
                destination_value, source_value,
                fromfile=str(destination), tofile=str(source)):
            if line.startswith('+'):
                line = f'\033[38;5;64m{line}\033[0m'
            elif line.startswith('-'):
                line = f'\033[38;5;124m{line}\033[0m'
            elif line.startswith('@@ '):
                line = f'\033[38;5;33m{line}\033[0m'
            lines.append(line)

        return ''.join(lines)

    @classmethod
    def new(cls, source, destination, source_value):
        diff = cls._make_diff(
                source_value, '', source, destination)
        return cls('NEW', source, diff)

    @classmethod
    def updated(cls, source, destination, source_value, destination_value):
        diff = cls._make_diff(
                source_value, destination_value, source, destination)
        return cls('UPDATED', source, diff)

    @classmethod
    def missing(cls, destination):
        return cls('MISSING', destination.relative_to(DOTFILES_DIR))

    @classmethod
    def same(cls, source):
        return cls('SAME', source)


    def color(self):
        if self.state == 'NEW':
            return '\033[32m'
        elif self.state == 'UPDATED':
            return '\033[33m'
        elif self.state == 'MISSING':
            return '\033[31m'
        elif self.state == 'SAME':
            return '\033[0m'
        else:
            raise ValueError(f'Unknown state {self}')

    def mini_display(self):
        print(f'{self.color()}{self.path}\033[0m')

    def changed(self):
        return self.state != 'SAME'

    def full_display(self):
        if self.changed():
            print(f'\n{self.state.title()} {self.color()}{self.path}\033[0m')
            print(self.diff)


def create_folders(path):
    path.parent.mkdir(parents=True, exist_ok=True)


def is_macos_plist(path):
    """Heuristic to detect MacOS plists."""
    return (path.is_relative_to(MAC_PREFERENCES_DIR) and
            path.suffix == MAC_PREFERENCES_SUFFIX)


def copy_plist(source, destination, config, dry_run):
    """Copy the MacOS preferences.

    - Convert the binary format into easy-to-read XML
    - Drop undesired preferences
    """
    with source.open('rb') as source_file:
        settings = plistlib.load(source_file)

    app_name = source.name
    assert app_name.endswith(MAC_PREFERENCES_SUFFIX), (
            'Invalid app name: %s' % app_name)
    app_name = app_name[:-len(MAC_PREFERENCES_SUFFIX)]

    for key in list(settings.keys()):
        if config.is_plist_excluded(app_name, key):
            del settings[key]

    source_value = plistlib.dumps(settings, fmt=plistlib.FMT_XML).decode()

    if destination.exists():
        with destination.open('r') as destination_file:
            destination_value = destination_file.read()

        if source_value == destination_value:
            return FileState.same(source)

        state = FileState.updated(
                source, destination, source_value, destination_value)
    else:
        state = FileState.new(source, destination, source_value)

    if dry_run:
        return state

    create_folders(destination)
    with destination.open('w') as destination_file:
        destination_file.write(source_value)

    chmod_mode = stat.S_IMODE(source.lstat().st_mode)
    os.chmod(destination, chmod_mode)

    return state


def copy_link(source, destination, dry_run):
    """Copy symlink."""
    source_value = source.readlink()
    destination_value = destination.readlink() if destination.exists() else ''

    if source_value == destination_value:
        return FileState.same(source)

    if destination.exists():
        state = FileState.updated(
                source, destination, source_value, destination_value)
    else:
        state = FileState.new(source, destination, source_value)

    if dry_run:
        return state

    create_folders(destination)
    if os.path.lexists(destination):
        os.unlink(destination)
    os.symlink(os.readlink(source), destination)
    return state


def copy_file(source, destination, dry_run):
    """Copy a file."""
    with source.open('r') as f:
        source_value = f.read()
    if destination.exists():
        with destination.open('r') as f:
            destination_value = f.read()
        if source_value == destination_value:
            return FileState.same(source)
        state = FileState.updated(
                source, destination, source_value, destination_value)
    else:
        state = FileState.new(source, destination, source_value)

    if dry_run:
        return state

    create_folders(destination)
    shutil.copy2(source, destination, follow_symlinks=False)
    return state


def copy(source, destination, config, dry_run=False):
    """Copy source to destination."""
    if not source.exists():
        return FileState.missing(destination)

    if os.path.islink(source):
        return copy_link(source, destination, dry_run)
    elif is_macos_plist(source):
        return copy_plist(source, destination, config, dry_run)
    else:
        return copy_file(source, destination, dry_run)


def main(dry_run, diff):
    """Copy the files over."""
    if dry_run:
        print('\033[95;1mShowing preview in dry-run mode\033[0m\n')
    config = Config(CONFIG_FILE)
    changed = False
    for dotfile in sorted(get_dotfiles(DOTFILES_DIR, config)):
        source = dotfile
        destination = DOTFILES_DIR / dotfile.relative_to(Path.home())
        state = copy(source, destination, config, dry_run)
        if diff:
            state.full_display()
        else:
            state.mini_display()
        if state.changed():
            changed = True
    if changed:
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Collect files')
    parser.add_argument(
            '--dry_run', action=argparse.BooleanOptionalAction, default=True,
            help='just display the changes')
    parser.add_argument(
            '--diff', action=argparse.BooleanOptionalAction, default=False,
            help='show the difference between files')
    args = parser.parse_args()

    main(args.dry_run, args.diff)
