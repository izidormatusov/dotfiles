#!/usr/bin/env python3
""" Tool for dotfiles management. """

import os
import subprocess
import sys

import lib


def usage(message=None):
    if message:
        print(message)
    print(f'''Usage: {sys.argv[0]} <command>
Command can be:
  collect      - move files from home into dotfiles repo (default)
  run [script] - run an installation script
  install      - interactively select files to be put into home
  help         - print this help
    ''')


def collect(config, just_list=False):
    dotfiles = lib.discover_home_dotfiles(config)

    file_list = '\n'.join(
            dotfile.name
            for dotfile in sorted(dotfiles, key=lambda d: d.name)
            if dotfile.is_modified())

    if just_list:
        print(file_list)
        return

    self_cmd = f'/usr/bin/env python3 {sys.argv[0]}'
    reload_cmd = f'{self_cmd} collect list {{}}'
    try:
        selected = subprocess.check_output([
            'fzf',
            '--multi',
            '--layout=reverse',
            '--border=top',
            '--border-label',
            'Collecting dotfiles',
            '--header',
            'CTRL+R to reload, CTRL+A to select all, CTRL+X to revert',
            f'--bind=ctrl-r:reload({reload_cmd})',
            '--bind=ctrl-a:toggle-all',
            f'--bind=ctrl-x:execute({self_cmd} move {{}} home)+reload({reload_cmd})',
            f'--preview={self_cmd} diff {{}} dotfiles',
            '--preview-label=Diff',
        ], input=file_list.encode(), stderr=sys.stderr)
    except subprocess.CalledProcessError as e:
        if e.returncode == 130:
            # 130 means no selection from the user
            return
        raise

    for line in selected.decode().splitlines():
        print(line)
        dotfile = lib.DotFile.discover(config, line)
        dotfile.move('dotfiles')


def install(config, just_list=False):
    dotfiles = lib.discover_dotfiles(config)

    file_list = '\n'.join(
            dotfile.name
            for dotfile in sorted(dotfiles, key=lambda d: d.name)
            if dotfile.is_modified())

    if not file_list:
        print('All OK')
        return

    if just_list:
        print(file_list)
        return

    self_cmd = f'/usr/bin/env python3 {sys.argv[0]}'
    reload_cmd = f'{self_cmd} install list {{}}'
    try:
        selected = subprocess.check_output([
            'fzf',
            '--multi',
            '--layout=reverse',
            '--border=top',
            '--border-label',
            'Installing dotfiles',
            '--header',
            'CTRL+R to reload, CTRL+A to select all, CTRL+X to revert',
            f'--bind=ctrl-r:reload({reload_cmd})',
            '--bind=ctrl-a:toggle-all',
            f'--bind=ctrl-x:execute({self_cmd} move {{}} home)+reload({reload_cmd})',
            f'--preview={self_cmd} diff {{}} home',
            '--preview-label=Diff',
        ], input=file_list.encode(), stderr=sys.stderr)
    except subprocess.CalledProcessError as e:
        if e.returncode == 130:
            # 130 means no selection from the user
            return
        raise

    for line in selected.decode().splitlines():
        print(line)
        dotfile = lib.DotFile.discover(config, line)
        dotfile.move('home')

def run_script(config, initial_query):
    scripts = []
    for script_folder in config.scripts:
        for dirpath, _, filenames in os.walk(script_folder):
            for filename in filenames:
                path = os.path.join(dirpath, filename)
                scripts.append(os.path.relpath(path, config.base_dir))
    scripts.sort()
    script_list = '\n'.join(scripts)

    try:
        selected = subprocess.check_output([
            'fzf',
            '--multi',
            '--layout=reverse',
            '--query',
            initial_query,
            '--select-1',
            '--border=top',
            '--border-label',
            'Running scripts',
            f'--preview=cat {{}}',
            '--preview-label=Content',
        ], input=script_list.encode())
    except subprocess.CalledProcessError as e:
        if e.returncode == 130:
            # 130 means no selection from the user
            return
        raise

    for script in selected.decode().splitlines():
        print(f'\033[33m=-= Executing \033[33;1m{script}\033[0m')
        if os.access(script, os.X_OK):
            return_code = subprocess.call(script, shell=True)
        else:
            return_code = subprocess.call(['bash', script])
        if return_code != 0:
            print(f'\033[91m{script} failed with return code \033[1m{return_code}\033[0m')
            sys.exit(return_code)


def show_status(config):
    root = os.path.abspath(config.base_dir)
    git_repos = []
    for path, folders, _ in os.walk(root):
        if path != root and '.git' in folders:
            git_repos.append(path)

    subprocess.check_call(['git', 'status', '-sb'])

    for repo in  git_repos:
        name = os.path.relpath(repo, root)
        print(f'\n== {name}')
        subprocess.check_call(['git', 'status', '-sb'], cwd=repo)


class Args:

    def __init__(self, args):
        self.args = list(args)

    def consume(self, default_value=None):
        if not self.args:
            return default_value
        value = self.args[0]
        self.args = self.args[1:]
        return value


def main():
    config = lib.Config()

    args = Args(sys.argv[1:])

    command = args.consume('collect')
    if command == 'collect':
        just_list = args.consume('') == 'list'
        collect(config, just_list)
    elif command == 'install':
        just_list = args.consume('') == 'list'
        install(config, just_list)
    elif command == 'diff':
        name = args.consume()
        direction = args.consume('dotfiles')
        if name is None:
            usage('Missing diff argument')
            return
        dotfile = lib.DotFile.discover(config, name)
        print(dotfile.diff(direction))
    elif command == 'move':
        path = args.consume()
        direction = args.consume('dotfiles')
        if path is None:
            usage('Missing path argument')
            return
        lib.DotFile.discover(config, path).move(direction)
    elif command == 'run':
        query = args.consume('')
        run_script(config, query)
    elif command == 'status':
        show_status(config)
    elif command == 'help':
        usage()
    else:
        usage(f'Unknown command {command}')


if __name__ == "__main__":
    main()
