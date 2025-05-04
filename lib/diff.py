import difflib
import os
import stat


def _read_content(path):
    if os.path.exists(path):
        mode = os.lstat(path).st_mode
        if stat.S_ISDIR(mode):
            return '(directory)'
        elif stat.S_ISCHR(mode):
            return '(character device)'
        elif stat.S_ISBLK(mode):
            return '(block device)'
        elif stat.S_ISFIFO(mode):
            return '(FIFO - named pipe)'
        elif stat.S_ISSOCK(mode):
            return '(socket)'
        elif stat.S_ISLNK(mode):
            return os.readlink(path)
        elif stat.S_ISREG(mode):
            with open(path, 'rb') as f:
                return f.read()
        else:
            return '(unknown type of special file)'
    else:
        return ''


def diff(source_path, destination_path,
         source_content=None, destination_content=None):

    if source_content is None:
        source_content = _read_content(source_path)

    if destination_content is None:
        destination_content = _read_content(destination_path)

    # If possible, convert files into strings
    try:
      if isinstance(source_content, bytes):
        source_content = source_content.decode()
      if isinstance(destination_content, bytes):
        destination_content = destination_content.decode()
    except UnicodeDecodeError:
      return 'Binary files'

    lines = []
    source_content = [line + '\n' for line in source_content.splitlines()]
    destination_content = [
            line + '\n' for line in destination_content.splitlines()]

    for line in difflib.unified_diff(
            destination_content, source_content,
            fromfile=source_path, tofile=destination_path):
        if line.startswith('+'):
            line = f'\033[38;5;64m{line}\033[0m'
        elif line.startswith('-'):
            line = f'\033[38;5;124m{line}\033[0m'
        elif line.startswith('@@ '):
            line = f'\033[38;5;33m{line}\033[0m'
        lines.append(line)

    return ''.join(lines)
