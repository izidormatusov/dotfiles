class TrieNode:

    def __init__(self, prefix=None):
        self.prefix = prefix if prefix is not None else ""
        self.is_final = False
        self.children = dict()

    def __repr__(self):
        param = self.prefix if self.prefix else '{root}'
        return f'{self.__class__.__name__}({param})'

    def print(self, indent=0):
        print('%s%s%s' % (
            ' ' * indent,
            self.prefix if self.prefix else '(root)',
            '*' if self.is_final else ''
            ))
        for key in sorted(self.children.keys()):
            self.children[key].print(indent=indent+1)

    def query(self, s):
        if not s:
            return False

        if s[0] not in self.children:
            return False

        node = self
        for c in s:
            if node.is_final:
                return True

            if c not in node.children:
                return False
            node = node.children[c]
        return node.is_final

    def insert(self, s):
        node = self
        for c in s:
            if node.is_final:
                return

            if c in node.children:
                node = node.children[c]
            else:
                new_node = TrieNode(c)
                node.children[c] = new_node
                node = new_node

        node.is_final = True
