#!/usr/bin/env python
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

HOMEDIR = os.path.expanduser('~')
INSTALL_FILE = os.path.join(os.path.dirname(__file__), '.install.list')

def read_install_files():
    """ Return list of install files """
    return [line.strip().lstrip('.')
            for line in open(INSTALL_FILE).read().splitlines() if line.strip()]

def write_install_files(install_files):
    """ Save sorted install files list """
    with open(INSTALL_FILE, 'w') as f:
        f.write('\n'.join(sorted(install_files)))
        # Trailing newline
        f.write('\n')

def clean_filename(orig_filename):
    abs_filename = os.path.abspath(orig_filename)
    if not abs_filename.startswith(HOMEDIR):
        raise ValueError("'%s' is outside of the home folder" % orig_filename)
    filename = abs_filename[len(HOMEDIR):].lstrip(os.path.sep)
    filename = filename.lstrip('.')
    return filename


if __name__ == "__main__":
    # Operate inside script's folder
    os.chdir(os.path.dirname(__file__))
    INSTALL_FILES = read_install_files()
    if len(sys.argv) <= 1:
        print("Usage: %s <install|add> [files]" % sys.argv[0])
        sys.exit(1)

    action = sys.argv[1]
    if action == 'add':
        for orig_filename in sys.argv[2:]:
            filename = clean_filename(orig_filename)
            for existing_filename in INSTALL_FILES:
                if filename.startswith(existing_filename):
                    print("'%s' is already included" % orig_filename)
                    break
            else:
                folder = os.path.dirname(filename)
                if not os.path.exists(folder):
                    os.path.makedirs(folder)
                abs_path = os.path.abspath(orig_filename)
                shutil.move(abs_path, folder)
                os.symlink(os.path.abspath(filename), abs_filename)
                INSTALL_FILES.append(filename)
    elif action in ['rm', 'delete', 'remove']:
        for orig_filename in sys.argv[2:]:
            filename = clean_filename(orig_filename)
            for existing_filename in INSTALL_FILES:
                if filename == existing_filename:
                    if os.path.isdir(filename):
                        shutil.rmtree(filename)
                        shutil.rmtree(os.path.abspath(orig_filename))
                    else:
                        os.unlink(filename)
                        os.unlink(os.path.abspath(orig_filename))
                    break
            else:
                print("'%s' is not registered dotfile" % orig_filename)
                os.symlink(os.path.abspath(filename), abs_filename)
                INSTALL_FILES.append(filename)
    elif action == 'install':
        for filename in INSTALL_FILES:
            abs_path = os.path.abspath(os.path.join(HOMEDIR, '.' + filename))
            if os.path.exists(abs_path):
                if not os.path.islink(abs_path):
                    print("File '%s' already exists" % abs_path)
                # Ignore existing files
                continue

            # Create folder structure
            dirname = os.path.dirname(abs_path)
            if dirname and not os.path.exists(dirname):
                os.makedirs(dirname)

            print("ln -s %s %s" % (os.path.abspath(filename), abs_path))
            os.symlink(os.path.abspath(filename), abs_path)
    else:
        print("Unrecognized action '%s'" % action)

    write_install_files(INSTALL_FILES)

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
