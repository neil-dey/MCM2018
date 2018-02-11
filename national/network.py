from node import NodeType, Node

class Network:

    def __init__(self, radii):
        self.nodes = []
        self.distances = []
        self.links = []
        self.radii = radii

    def load_from_file(self, fileName):

        # Format of line will be latitude,longitude,density\n
        print("Reading file into memory")
        with open(fileName, "r") as file:
            for line in file:
                cells = line.replace("\n", "").split(",")
                lat = float(cells[0])
                lon = float(cells[1])
                density = float(cells[2])
                # TODO: include number of chargers
                self.nodes.append(Node((lat, lon), density, 0))
                print("Read %s lines" % len(self.nodes))

        # Predetermine distances between all nodes
        print("Calculating all distances")
        for i in range(len(self.nodes)):
            self.distances.append([0] * len(self.nodes))
            for j in range(len(self.nodes)):
                self.distances[i][j] = self.nodes[i].get_distance(self.nodes[j])
                print("Calculated %s of %s distances" % (i * len(self.nodes) + j, len(self.nodes) ** 2))

        # Predetermine neighbors for nodes
        print("Calculating all neighbors")
        for i in range(len(self.nodes)):
            self.links.append([0] * len(self.nodes))
            for j in range(len(self.nodes)):
                if (i == j):
                    continue
                node = self.nodes[i]
                other_node = self.nodes[j]
                if (self.distances[i][j] <= self.radii[node.type]):
                    self.links[i][j] = 1
                    node.neighbors[str(other_node)] = (other_node, self.distances[i][j])
                    other_node.neighbors[str(node)] = (node, self.distances[i][j])
                print("Calculated %s of %s neighbors" % (i * len(self.nodes) + j, len(self.nodes) ** 2))

    def simulate(self, total_time):

        time = 0

        while (time <= total_time):

            # Update every node
            for node in self.nodes:
                node.tick(time)

            # Try adding new charging station to each node
            node_index = 0
            growth_max = 0
            for k in range(len(self.nodes)):
                mod_network = Network(self.radii)
                mod_network.nodes = self.nodes
                mod_network.distances = self.distances
                mod_network.links = self.links
                mod_network.nodes[k].num_chargers += 1
                growth = mod_network.total_growth_metric()
                if (growth > growth_max):
                    growth_max = growth
                    node_index = k

            # Add station to network
            self.nodes[node_index].num_chargers += 1

    def add_node(self, node):

        # Add to overall nodes
        self.nodes.append(node)

        # Recalculate all distances between new nodes
        self.distances.append([0] * (len(self.nodes) - 1))
        for i in range(len(self.nodes)):
            self.distances[i].append(self.nodes[i].get_distance(node))
        for j in range(len(self.nodes)):
            self.distances[len(self.nodes) - 1][j] = self.distances[j][len(self.nodes) - 1]

        # Determine neighbors for node
        self.links.append([0] * len(self.nodes))
        for i in range(len(self.nodes) - 1):
            other_node = self.nodes[i]
            if (self.distances[i][len(self.nodes) - 1] <= self.radii[node.type]):
                self.links[i].append(1)
                node.neighbors[str(other_node)] = (other_node, self.distances[i][len(self.nodes) - 1])
                other_node.neighbors[str(node)] = (node, self.distances[i][len(self.nodes) - 1])
            else:
                self.links[i].append(0)
        for j in range(len(self.nodes)):
            self.links[len(self.nodes) - 1][j] = self.links[j][len(self.nodes) - 1]

    def total_growth_metric(self):

        growth_metric = 0
        for node in self.nodes:
            growth_metric += node.growth_metric
        return growth_metric
