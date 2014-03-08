#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Copyright (c) 2013 Izidor Matušov
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

import os
import shutil
import sys

class Dotfiles(object):
    HOMEDIR = os.path.expanduser('~')

    def __init__(self, install_file):
        self._install_file = install_file
        self.load()

    def load(self):
        """ Load list of install files """
        self.install_files = [
            line.strip().lstrip('.')
            for line in open(self._install_file).read().splitlines()
            if line.strip()
        ]

    def save(self):
        """ Save sorted install files list """
        with open(self._install_file, 'w') as f:
            f.write('\n'.join(sorted(self.install_files)))
            # Trailing newline
            f.write('\n')

    def _clean(self, orig_filename):
        """ Return filepath relative to HOMEDIR without initial dot """
        abs_filename = os.path.abspath(orig_filename)
        if not abs_filename.startswith(self.HOMEDIR):
            raise ValueError(
                "'{}' is outside of the home folder".format(orig_filename))
        filename = abs_filename[len(self.HOMEDIR):].lstrip(os.path.sep)
        filename = filename.lstrip('.')
        return filename

    def contains(self, filename):
        for existing_filename in self.install_files:
            if filename.startswith(existing_filename):
                return True
        return False

    def add(self, orig_filename):
        """ Add file into install files """
        filename = self._clean(orig_filename)

        if self.contains(filename):
            raise ValueError("'%s' is already included" % orig_filename)

        folder = os.path.join('.', os.path.dirname(filename))
        if not os.path.exists(folder):
            os.makedirs(folder)
        abs_path = os.path.abspath(orig_filename)
        shutil.move(abs_path, folder)
        os.symlink(os.path.abspath(filename), abs_path)
        self.install_files.append(filename)

    def remove(self, orig_filename):
        """ Remove file from install files """
        filename = self._clean(orig_filename)

        if not self.contains(filename):
            raise ValueError("'%s' is not registered dotfile" % orig_filename)

        if os.path.isdir(filename):
            shutil.rmtree(filename)
        else:
            os.unlink(filename)

        os.unlink(os.path.abspath(orig_filename))

    def install(self, filename):
        """ Install symlink to file """
        abs_path = os.path.abspath(os.path.join(self.HOMEDIR, '.' + filename))
        if os.path.exists(abs_path):
            if os.path.islink(abs_path):
                # Ignore existing symlink
                return False
            else:
                raise ValueError("File '%s' already exists" % abs_path)

        # Create folder structure
        dirname = os.path.dirname(abs_path)
        if dirname and not os.path.exists(dirname):
            os.makedirs(dirname)

        os.symlink(os.path.abspath(filename), abs_path)
        return True


if __name__ == "__main__":
    # Operate inside script's folder
    os.chdir(os.path.dirname(__file__))

    install_file = os.path.join(os.path.dirname(__file__), '.install.list')
    dotfiles = Dotfiles(install_file)

    if len(sys.argv) <= 1:
        print("Usage: %s <install|add|rm> [files]" % sys.argv[0])
        sys.exit(1)

    action = sys.argv[1]
    if action == 'add':
        for filename in sys.argv[2:]:
            try:
                dotfiles.add(filename)
            except ValueError as e:
                print(e.msg)
    elif action in ['rm', 'delete', 'remove']:
        for filename in sys.argv[2:]:
            try:
                dotfiles.remove(filename)
            except ValueError as e:
                print(e.msg)
    elif action == 'install':
        for filename in dotfiles.install_files:
            try:
                if dotfiles.install(filename):
                    print("Installing {}".format(filename))
            except ValueError as e:
                print(e.msg)
    else:
        print("Unrecognized action '%s'" % action)

    dotfiles.save()
