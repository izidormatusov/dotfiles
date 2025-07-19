import os
import plistlib
import shutil
import sys

from .diff import diff

class DotFile:

    MAC_PREFERENCES_SUFFIX = '.plist'

    def __init__(self, name, home_path, dotfile_path, config):
        self.name = name
        self.home_path = home_path
        self.dotfile_path = dotfile_path
        self.config = config

    @classmethod
    def discover(cls, config, name):
        """Find the matching dotfile."""
        home_path = os.path.join(config.home_dir, name)
        for dotfiles_dir in reversed(config.dotfiles):
            dotfile_path = os.path.join(dotfiles_dir, name)
            if os.path.exists(dotfile_path):
                return cls(name, home_path, dotfile_path, config)

        default_dotfile_path = os.path.join(config.dotfiles[0], name)
        return cls(name, home_path, default_dotfile_path, config)

    def __repr__(self):
        return f'<{self.__class__.__name__}({self.name})>'

    def __eq__(self, other):
        return (isinstance(other, self.__class__) and
                self.name == other.name and
                self.home_path == other.home_path and
                self.dotfile_path == other.dotfile_path)

    def __hash__(self):
        return hash((self.name, self.home_path, self.dotfile_path))

    @property
    def is_macos_only(self):
        return self.name.startswith('Library/')

    @property
    def is_plist(self):
        return self.is_macos_only and self.name.endswith(
                self.MAC_PREFERENCES_SUFFIX)

    @classmethod
    def _create_folders(cls, path):
        os.makedirs(os.path.dirname(path), exist_ok=True)

    def _filtered_source_plist(self):
        """Filter out settings that we don't care about."""
        if not os.path.exists(self.home_path):
            return ''

        with open(self.home_path, 'rb') as f:
            settings = plistlib.load(f)

        app_name = os.path.basename(self.home_path)
        assert app_name.endswith(self.MAC_PREFERENCES_SUFFIX), (
                'Invalid app name: %s' % app_name)
        app_name = app_name[:-len(self.MAC_PREFERENCES_SUFFIX)]

        for key in list(settings.keys()):
            if self.config.is_plist_excluded(app_name, key):
                del settings[key]

        return plistlib.dumps(settings, fmt=plistlib.FMT_XML).decode()

    def is_modified(self):
        """Returns True if the file is not logically same."""
        if (not os.path.exists(self.home_path) or
            not os.path.exists(self.dotfile_path)):
            return True

        is_home_link = os.path.islink(self.home_path)
        is_dotfile_link = os.path.islink(self.dotfile_path)
        if is_home_link or is_dotfile_link:
            # One of them is not a link
            if not is_home_link or not is_dotfile_link:
                return True

            home_link = os.readlink(self.home_path)
            dotfile_link = os.readlink(self.dotfile_path)
            return home_link != dotfile_link
        elif self.is_plist:
            with open(self.dotfile_path) as f:
                dotfile_content = f.read()
            return self._filtered_source_plist() != dotfile_content
        else:
            # TODO: check permissions
            with open(self.home_path, 'rb') as f:
                home_content = f.read()
            with open(self.dotfile_path, 'rb') as f:
                dotfile_content = f.read()
            return home_content != dotfile_content

    def diff(self, direction):
        """Return diff of the contents."""

        home_content, dotfile_content = None, None

        home_exists = os.path.exists(self.home_path)
        dotfile_exists = os.path.exists(self.dotfile_path)
        # TODO: deal with permissions

        if self.is_plist:
            home_content = self._filtered_source_plist()

        if direction == 'dotfiles':
            return diff(
                    source_path=self.home_path,
                    source_content=home_content,
                    destination_path=self.dotfile_path,
                    destination_content=dotfile_content)
        elif direction == 'home':
            return diff(
                    source_path=self.dotfile_path,
                    source_content=dotfile_content,
                    destination_path=self.home_path,
                    destination_content=home_content)
        else:
            raise Exception(f'Unknown diff direction {direction}')

    def move(self, direction):
        if direction == 'dotfiles':
            source, destination = self.home_path, self.dotfile_path
        elif direction == 'home':
            source, destination = self.dotfile_path, self.home_path
        else:
            raise Exception(f'Unknown diff direction {direction}')

        if not os.path.exists(source):
            os.unlink(destination)
            return

        if os.path.islink(source):
            content = os.readlink(source)
            if os.path.exists(destination):
                if (not os.path.islink(destination) or
                    content != os.readlink(destination)):
                    os.unlink(destination)
                    os.symlink(content, destination)
            else:
                self._create_folders(destination)
                os.symlink(content, destination)

            source_stat = os.lstat(source)
            destination_stat = os.lstat(destination)
            if source_stat.st_mode != destination_stat.st_mode:
                os.chmod(destination, source_stat.st_mode)
        elif self.is_plist:
            if direction == 'dotfiles':
                content = self._filtered_source_plist()
                self._create_folders(destination)
                with open(destination, 'w') as f:
                    f.write(content)
            elif direction == 'home':
                with open(source, 'rb') as f:
                    settings = plistlib.load(f)
                os.makedirs(os.path.dirname(destination), exist_ok=True)
                with open(destination, 'wb') as f:
                    plistlib.dump(settings, f, fmt=plistlib.FMT_BINARY)
        else:
            self._create_folders(destination)
            shutil.copy2(source, destination, follow_symlinks=False)


def discover_home_dotfiles(config):
    """Discover all dotfiles in home directory."""
    dotfiles = dict()
    home_dir = config.home_dir
    default_dotfiles_dir = config.dotfiles[0]

    # Files that exist in the repo but might not be considered regular dotfile.
    for dotfiles_dir in config.dotfiles:
        for dirpath, dirnames, filenames in os.walk(dotfiles_dir):
            for filename in filenames + dirnames:
                dotfile_path = os.path.join(dirpath, filename)

                if os.path.isfile(dotfile_path) or os.path.islink(dotfile_path):
                    name = os.path.relpath(dotfile_path, dotfiles_dir)
                    home_path = os.path.join(home_dir, name)
                    if os.path.exists(home_path):
                        dotfiles[name] = DotFile(
                                name, home_path, dotfile_path, config)

    # Explicitly included configs
    for extra_folder in config.get_inclusions():
        extra_folder = os.path.join(home_dir, extra_folder)
        for dirpath, _, filenames in os.walk(extra_folder):
            for filename in filenames:
                home_path = os.path.join(dirpath, filename)
                name = os.path.relpath(home_path, home_dir)
                dotfile_path = os.path.join(default_dotfiles_dir, name)
                if config.is_excluded(name):
                    continue

                if name not in dotfiles:
                    dotfiles[name] = DotFile(
                            name, home_path, dotfile_path, config)

    for dirpath, dirnames, filenames in os.walk(home_dir, topdown=True):
        is_home_folder = os.path.samefile(home_dir, dirpath)

        # Limit which directories os.walk() should go into. This speeds up the
        # process drastically as we don't have to process potentially large
        # non-dotfiles directories
        dirnames[:] = [name for name in dirnames if
                       # Ignore non dotfiles directories, e.g. ~/Downloads/ but
                       # go through ~/.config/myapp
                       (name.startswith('.') or not is_home_folder) and
                       # Ignore .git modules files
                       name != '.git' and
                       # Exclude path prefixes as soon as possible
                       not config.is_excluded(
                           os.path.relpath(
                               os.path.join(dirpath, name), home_dir) + '/')]

        for dirname in dirnames:
            home_path = os.path.join(dirpath, dirname)
            name = os.path.relpath(home_path, home_dir)
            dotfile_path = os.path.join(default_dotfiles_dir, name)

            if config.is_excluded(name):
                continue

            if os.path.islink(home_path) and name not in dotfiles:
                dotfiles[name] = DotFile(
                        name, home_path, dotfile_path, config)

        for filename in filenames:
            home_path = os.path.join(dirpath, filename)
            name = os.path.relpath(home_path, home_dir)
            dotfile_path = os.path.join(default_dotfiles_dir, name)
            if config.is_excluded(name):
                continue
            if is_home_folder and not filename.startswith('.'):
                continue
            if name not in dotfiles:
                dotfiles[name] = DotFile(
                        name, home_path, dotfile_path, config)

    return dotfiles.values()


def discover_dotfiles(config):
    """Discover already existing dotfiles."""
    dotfiles = dict()
    home_dir = config.home_dir
    default_dotfiles_dir = config.dotfiles[0]

    # Files that exist in the repo but might not be considered regular dotfile.
    for dotfiles_dir in config.dotfiles:
        for dirpath, dirnames, filenames in os.walk(dotfiles_dir):
            for filename in filenames + dirnames:
                dotfile_path = os.path.join(dirpath, filename)

                if os.path.isfile(dotfile_path) or os.path.islink(dotfile_path):
                    name = os.path.relpath(dotfile_path, dotfiles_dir)
                    home_path = os.path.join(home_dir, name)

                    dotfile = DotFile(name, home_path, dotfile_path, config)
                    if dotfile.is_macos_only and sys.platform != 'darwin':
                        print(f'Skipping {dotfile_path}')
                        continue

                    dotfiles[name] = dotfile

    return dotfiles.values()
