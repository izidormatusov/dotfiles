#!/usr/bin/env python3

import unittest

from trie import TrieNode


class TrieNodeTest(unittest.TestCase):

    def test_empty(self):
        root = TrieNode()
        self.assertFalse(root.query('.config'))

    def test_prefix(self):
        root = TrieNode()
        root.insert('.config')

        self.assertTrue(root.query('.config'))
        self.assertTrue(root.query('.configuration'))

    def test_one_element(self):
        root = TrieNode()
        root.insert('.config/')

        self.assertTrue(root.query('.config/tmux'))
        self.assertFalse(root.query('.tmux'))

    def test_splitting(self):
        root = TrieNode()
        root.insert('.config/alacritty')
        root.insert('.config/broot')

        self.assertTrue(root.query('.config/alacritty'))
        self.assertFalse(root.query('.config/ala'))
        self.assertTrue(root.query('.config/broot'))

    def test_shorter_path(self):
        root = TrieNode()
        root.insert('.config/alacritty')
        root.insert('.config/')

        self.assertTrue(root.query('.config/alacritty'))
        self.assertTrue(root.query('.config/'))
        self.assertTrue(root.query('.config/broot'))

    def test_ignore_duplicate_paths(self):
        root = TrieNode()
        root.insert('.config/')
        root.insert('.config/alacritty')
        root.insert('.config/broot')

        self.assertTrue(root.query('.config/'))
        self.assertTrue(root.query('.config/alacritty'))
        self.assertTrue(root.query('.config/broot'))

    def test_multiple_paths(self):
        root = TrieNode()
        root.insert('.config/htop.conf')
        root.insert('.config/broot/config')
        root.insert('.config/broot/alt-config')

        self.assertTrue(root.query('.config/htop.conf'))
        self.assertTrue(root.query('.config/broot/config'))
        self.assertTrue(root.query('.config/broot/alt-config'))
        self.assertFalse(root.query('.config/broot'))


if __name__ == '__main__':
    unittest.main()
