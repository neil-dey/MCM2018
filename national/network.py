from geopy.geocoders import Nominatim
from node import NodeType, Node
import math
import pickle

class Network:

    GEOLOCATOR = Nominatim()

    def __init__(self, radii):
        self.nodes = []
        self.distances = []
        self.links = []
        self.radii = radii

    def write_to_memory(self, nodeFile, distanceFile, linkFile, radiiFile):

        pickle.dump(self.nodes, open(nodeFile, "wb"))
        pickle.dump(self.distances, open(distanceFile, "wb"))
        pickle.dump(self.links, open(linkFile, "wb"))
        pickle.dump(self.radii, open(radiiFile, "wb"))

    def read_from_memory(self, nodeFile, distanceFile, linkFile, radiiFile):

        self.nodes = pickle.load(open(nodeFile, "rb"))
        self.distances = pickle.load(open(distanceFile, "rb"))
        self.links = pickle.load(open(linkFile, "rb"))
        self.radii = pickle.load(open(radiiFile, "rb"))

    def load_from_file(self, fileName):

        # Format of line will be latitude,longitude,density\n
        print("Reading file into memory")
        with open(fileName, "r") as file:
            for line in file:
                cells = line.replace("\n", "").split(",")
                lat = float(cells[0])
                lon = float(cells[1])
                density = float(cells[2])
                chargers = float(cells[3])
                self.nodes.append(Node((lat, lon), density, chargers))
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

        with open("output.txt", "w") as file:
            while (time <= total_time):

                # Update every node
                for node in self.nodes:
                    node.tick(time)

                # Try adding new charging station to each node
                identified = False
                node_index = 0
                growth_max = 0
                for k in range(len(self.nodes)):
                    mod_network = Network(self.radii)
                    mod_network.nodes = self.nodes
                    mod_network.distances = self.distances
                    mod_network.links = self.links
                    mod_network.nodes[k].num_chargers += 1
                    growth = mod_network.total_growth_metric()
                    if (growth > growth_max and mod_network.nodes[k].prop_electric >= 0.2 and mod_network.nodes[k].prop_electric <= 0.5):
                        growth_max = growth
                        node_index = k
                        identified = True
                    mod_network.nodes[k].num_chargers -= 1

                # Add station to network
                output = ""
                if (identified):
                    self.nodes[node_index].num_chargers += 1
                    output = "Time: %s | Identified: %s" % (time, self.nodes[node_index].get_location())
                else:
                    output = "Time: %s" % time
                print(output)
                file.write(output + "\n")

                # Update time
                time += 1

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

    def average_degree(self):

        total_degree = 0
        for node in self.nodes:
            total_degree += len(node.neighbors)
        return total_degree / len(self.nodes)

    def south_korea_metric(self):
        metric = 0
        for i in range(len(self.nodes)):
            if self.nodes[i].num_chargers != 0:
                numberChargers = 0
                for j in range(len(self.nodes)):
                    if self.distances[i][j] <= 5:
                        numberChargers += self.nodes[j].num_chargers
                metric += (self.nodes[i].density * 31.5 / numberChargers)**2
        metric = math.sqrt(metric / len(self.nodes))
        for i in range(len(self.nodes)):
            if self.nodes[i].num_chargers == 0:
                min = 1000000
                minCity = i
                for j in range(len(self.nodes)):
                    if i != j and self.distances[i][j] < min and self.nodes[j].num_chargers != 0:
                        min = self.distances[i][j]
                        minCity = j
                if minCity == i:
                    metric += 1000
                else:
                    metric += self.distances[i][minCity] * 25
        return metric

    def SK_simulate(self, total_time):

        time = 0

        with open("SKoutput.txt", "w", encoding="utf8") as file:
            while (time <= total_time):

                # Update every node
                for node in self.nodes:
                    node.tick(time)

                # Try adding new charging station to each node
                identified = False
                node_index = 0
                min_metric = 1000000000000000
                for k in range(len(self.nodes)):
                    mod_network = Network(self.radii)
                    mod_network.nodes = self.nodes
                    mod_network.distances = self.distances
                    mod_network.links = self.links
                    mod_network.nodes[k].num_chargers += 1
                    nodeMetric = mod_network.south_korea_metric()
                    if nodeMetric < min_metric:
                        min_metric = nodeMetric
                        node_index = k
                        identified = True
                    mod_network.nodes[k].num_chargers -= 1

                # Add station to network
                output = ""
                if (identified):
                    self.nodes[node_index].num_chargers += 1
                    output = "%s" % (self.nodes[node_index].coordinate,)
                else:
                    output = "Time: %s" % time
                print(output)
                file.write(output + "\n")

                # Update time
                time += 1
