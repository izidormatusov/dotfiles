#!/usr/bin/env python3
"""Build an install script installing dotfiles and executing scripts."""

from pathlib import Path
import base64
import stat
import os
import sys

from jinja2 import Template

INSTALL_SCRIPT = 'install'
current_folder = Path(sys.argv[0]).parent
DOTFILES_FOLDER = current_folder / 'dotfiles'
SCRIPTS_FOLDER = current_folder / 'scripts'
TEMPLATE_FILE = current_folder / 'template.sh.j2'


class Dotfile:
    MINIMAL_CONFIGS = ['.tmux', '.bash', '.vim']

    def __init__(self, path):
        self.path = path
        self._content = None
        self._encoded = None

    @property
    def home_path(self):
        return Path('$HOME').joinpath(self.path.relative_to(DOTFILES_FOLDER))

    @property
    def is_minimal(self):
        """Is this config a important and should be installed?"""
        path = str(self.path.relative_to(DOTFILES_FOLDER))
        for prefix in self.MINIMAL_CONFIGS:
            if path.startswith(prefix):
                return True
        return False

    @property
    def mode(self):
        chmod_mode = stat.S_IMODE(os.lstat(str(self.path)).st_mode)
        return oct(chmod_mode)[2:]

    def _read_content(self):
        with self.path.open('rb') as dotfile:
            content = dotfile.read()
        try:
            self._content = content.decode('utf-8')
            self._encoded = False
        except UnicodeDecodeError:
            self._content = base64.b64encode(content).decode('utf-8')
            self._encoded = True

    @property
    def content(self):
        if self._content is None:
            self._read_content()
        return self._content

    @property
    def is_encoded(self):
        if self._encoded is None:
            self._read_content()
        return self._encoded


class Script:
    def __init__(self, path):
        self.path = path

    @property
    def content(self):
        with self.path.open() as scriptfile:
            return scriptfile.read()


def get_dotfiles():
    """Returns a mapping of dotfile type => list of dotfiles."""
    dotfiles = []
    for dirpath, _, filenames in os.walk(DOTFILES_FOLDER):
        for filename in filenames:
            dotfiles.append(Dotfile(Path(dirpath) / filename))
    dotfiles.sort(key=lambda d: (d.is_minimal, d.home_path))
    return dotfiles


def get_scripts():
   """Returns an ordered list of scripts to install."""
   scripts = [Script(SCRIPTS_FOLDER / script)
           for script in os.listdir(SCRIPTS_FOLDER)]
   scripts.sort(key=lambda script: script.path)
   return scripts


def main():
    """Build dotfiles into a shell script."""
    dotfiles = get_dotfiles()
    scripts = get_scripts()

    with open(TEMPLATE_FILE) as template_file:
        template = Template(template_file.read())

    with open(INSTALL_SCRIPT, 'w') as install_file:
        install_file.write(template.render(
            dotfiles=dotfiles, scripts=scripts))
    # Make the script executable
    os.chmod(INSTALL_SCRIPT, 0o755)

if __name__ == "__main__":
    main()
