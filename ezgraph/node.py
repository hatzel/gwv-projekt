class Node():
    """Nodes should only be instansiated by the Graph."""
    def __init__(self, identifier, graph):
        self.graph = graph
        self.state = identifier
        self.children = {}

    def __repr__(self):
        return "Node({})".format(self.state)

    def add_child(self, child, weight):
        self.children[child] = weight

    def get_child_weight(self, child):
        return self.children[child]

    def remove_child(self, child):
        del self.children[child]

    def __eq__(self, other):
        return self.state == other.state

    def __lt__(self, other):
        return self.state < other.state

    def __hash__(self):
        return self.state.__hash__()

    def get_children(self):
        return [k for k,v in self.children.items() if v is not None]

    def get_children_weights(self):
        return [(k,v) for k,v in self.children.items() if v is not None]
