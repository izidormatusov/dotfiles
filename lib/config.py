import os
import sys
import yaml

from .trie import TrieNode


class Config:
    """Dotfiles configuration.

     - which file paths to exclude from search
     - what .plist keys should be excluded
     - which paths should be forced for the inclusion although they aren't a
       typical dotfile
    """

    def __init__(self):
        self._find_configs()

        self._inclusions = []
        self._exclusions = TrieNode()
        self._plist_exclusions = dict()
        for config in self._configs:
            for path in config.get('inclusions', []):
                if path not in self._inclusions:
                    self._inclusions.append(path)

            for path in config.get('exclusions', []):
                self._exclusions.insert(path)

            self._plist_exclusions.update({
                key: set(values)
                for key, values in config.get('plist_exclusions', {}).items()})

    def _find_configs(self):
        base_folder = self.base_dir

        # Order matters: later in the config, higher the priority
        folders = [base_folder]
        for subfolder in ['work', 'private']:
            subfolder = os.path.join(base_folder, subfolder)
            if os.path.isdir(subfolder):
                folders.append(subfolder)

        self.dotfiles = [os.path.join(folder, 'dotfiles')
                         for folder in folders if os.path.exists(folder)]
        self.scripts = [os.path.join(folder, 'scripts')
                         for folder in folders if os.path.exists(folder)]

        self.dotfiles = []
        self.scripts = []
        self._configs = []
        for folder in folders:
            dotfile_folder = os.path.join(folder, 'dotfiles')
            if os.path.exists(dotfile_folder):
                self.dotfiles.append(dotfile_folder)

            scripts_folder = os.path.join(folder, 'scripts')
            if os.path.exists(scripts_folder):
                self.scripts.append(scripts_folder)

            config_path = os.path.join(folder, 'config.yaml')
            if os.path.isfile(config_path):
                with open(config_path) as config_file:
                    config = yaml.load(config_file, Loader=yaml.FullLoader)
                    self._configs.append(config)

    @property
    def home_dir(self):
        return os.path.expanduser('~')

    @property
    def base_dir(self):
        return os.path.dirname(sys.argv[0])

    def is_excluded(self, path):
        """Returns True if the path should be excluded.

        Allow text prefix exclusion, i.e. .config/foo- should match
        .config/foo-A and .config/foo-B
        """
        return self._exclusions.query(path)

    def is_plist_excluded(self, app_name, key):
        """Returns True if the app excludes the given setting."""
        return key in self._plist_exclusions.get(app_name, set())

    def get_inclusions(self):
        """Returns the list of extra retained files"""
        return self._inclusions
