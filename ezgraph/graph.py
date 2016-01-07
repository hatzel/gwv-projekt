from queue import Queue, LifoQueue, PriorityQueue
from functools import reduce

class Graph():
    """Basic, undirected, weighted Graph."""
    def __init__(self):
        self.nodes = {}

    def add_node(self, identifier):
        """State identifier needs to be hashable, users of the graph should just identify
        states by their identifier and keep track of them this way. The identifier should represent the whole state.
        """
        self.nodes[identifier] = _Node(identifier, self)

    def remove_node(self, identifier):
        del self.nodes[identifier]
        for node in self.nodes.values():
            node.remove_child(identifier)

    def add_edge(self, first_identifier, second_identifier, weight=1):
        self.nodes[first_identifier].add_child(self.nodes[second_identifier], weight)
        self.nodes[second_identifier].add_child(self.nodes[first_identifier], weight)

    def get_edge_weight(self, first_id, second_id):
        return self.nodes[first_id].get_child_weight(self.nodes[second_id])

    def get_path_length(self, path):
        def create_pair_list(list_):
            """Create List of pairs in the path to iterate over to caclulate total costs"""
            return [(list_[x], list_[x+1]) for x in range(0, len(list_)-1)]
        """Diese Liste enthält immer ein Paar von Knoten, wobei der letzte und der erste vom nächsten
        immer übereinstimmen. Die Kosten des Pfades werden dann über die Kanten der Knoten im Paar
        berechnet"""
        pair_list = create_pair_list(path)
        distance_to_best = reduce(lambda akku, nodes: akku + self.get_edge_weight(nodes[0], nodes[1]), pair_list, 0)
        return distance_to_best

    def remove_edge(self, first_identifier, second_identifier):
        self.nodes[first_identifier].remove_child(self.nodes[second_identifier])
        self.nodes[second_identifier].remove_child(self.nodes[first_identifier])

    def get_node(self, identifier):
        return self.nodes[identifier]

    def __getitem__(self, item):
        return list(self.nodes.keys())[item]

    def bfs(self, startstates, endstates,
        endstate_condition=lambda x: False, _data_structure=Queue, heuristic=None, print_path=lambda x: False, test = True):
        """Breadth first search algorithm on the graph.
        The endstate condition can be given to enable checking against very large sets of endstates.
        Start and endstates have to be iterables of the hashable states nodes were created with.
        """
        zaehler = 0
        # For conveience we set an astar variable based on wether or not a heuristic is supplied
        astar = False
        if heuristic:
            astar = True
        startstates = [self.nodes[state] for state in startstates]
        endstates = [self.nodes[state] for state in endstates]
        visited = []
        queue = _data_structure()
        # Each startstate is put into our starting set
        for s in startstates:
            # in case of astar we need to save a priority based on our heuristic
            if astar:
                t = (heuristic(s.state, map(lambda n: n.state, endstates)), [s])
                queue.put(t)
            else:
                queue.put([s])

        while queue.qsize() > 0:
            zaehler = zaehler +1
            # Schrittzahl soll nicht beim Durchlauf für die Portalheuristikangezeigt werden.
            if test:
                print ("Steps needed: ", str(zaehler))
            if astar:
                out = queue.get()
                path = out[1]
            else:
                path = queue.get()
            node = path[-1]
            if node not in visited:
                if node in endstates or endstate_condition(node):
                    return [e.state for e in path]
                visited.append(node)
                print_path(path)

                for c in node.get_children():
                    if astar:
                        # calculating cost of path
                        path_cost = self.get_path_length([e.state for e in path + [c]])
                        # Die Kosten werden als Priorität im Tupel gespeichert, wobei der gesamte Pfad abgespeichert wird
                        t = (heuristic(c.state, map(lambda n: n.state, endstates)) + path_cost, path + [c])
                        queue.put(t)
                    else:
                        queue.put(path + [c])

    def dfs(self, startstates, endstates, endstate_condition=lambda x: False, print_path=lambda x: False):
        """Depth first search on the Graph."""
        return self.bfs(startstates, endstates,
            endstate_condition=endstate_condition, _data_structure=LifoQueue, print_path=print_path)

    def astar(self, startstates, endstates, print_path=lambda x: False, heuristic=lambda x, y: 0,test = True):
        return self.bfs(startstates, endstates, heuristic=heuristic,
            _data_structure=PriorityQueue, print_path=print_path,test = test)

class _Node():
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
