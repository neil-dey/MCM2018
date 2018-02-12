import math
import time

from geopy.distance import vincenty
from geopy.distance import great_circle

import network

class NodeType:

    URBAN = 0
    SUBURBAN = 1
    RURAL = 2

class Node:

    VINCENTY_ITERS = 100
    INIT_PROP_ELECTRIC = 0.01

    def __init__(self, coordinate, density, num_chargers):
        self.coordinate = coordinate
        self.growth_metric = 0
        self.density = density
        self.prop_electric = 0.0
        self.num_chargers = num_chargers
        self.neighbors = {}
        if (density > 0 and density < 1000):
            self.type = NodeType.RURAL
            self.t50 = 3954
        elif (density < 2500):
            self.type = NodeType.SUBURBAN
            self.t50 = 2833
        else:
            self.type = NodeType.URBAN
            self.t50 = 2304

    def tick(self, time):
        
        # TODO: Change prop_electric as node grows
        # TODO: Consider neighbors in calculating prop_electric

        # Reduce t50 based on chargers in node
        t50mod = self.t50 - self.num_chargers * 73.05 # Average dt50/dn of chargers
        
        # Reduce t50 based on chargers in surrounding nodes
        for key in self.neighbors:
            other_node = self.neighbors[key][0]
            other_node_distance = self.neighbors[key][1]
            if other_node_distance <= 50:
                t50mod += 16.2 * other_node_distance # Average dt50/ddistance
        
        if (t50mod < 0.000000000001):
            t50mod = 0.000000000001 # very, VERY close to zero
        self.prop_electric = self.logistic_curve(time, t50mod)
        self.growth_metric = self.prop_electric

    def get_distance(self, node):
        return vincenty(self.coordinate, node.coordinate, iterations=Node.VINCENTY_ITERS).miles

    def logistic_curve(self, time, t50):
        k = (1.0 / t50) * math.log((1.0 / Node.INIT_PROP_ELECTRIC) - 1)
        return 1.0 / (1.0 + math.exp(-k * (time - t50)))

    def get_location(self):
        time.sleep(0.1)
        try:
            location = network.Network.GEOLOCATOR.reverse(str(self.coordinate[0]) + "," + str(self.coordinate[1])).raw
            if "address" in location:
                if "county" in location["address"] and "state" in location["address"]:
                    return location["address"]["county"] + "," + location["address"]["state"] + "," + str(self.density) + "," + str(self.num_chargers)
                elif "state" in location["address"]:
                    return location["address"]["state"] + "," + str(self.coordinate[0]) + "," + str(self.coordinate[1]) + str(self.density) + "," + str(self.num_chargers)
            else:
                return self.__str__()
        except:
            return self.__str__()

    def __str__(self):
        return str(self.coordinate[0]) + "," + str(self.coordinate[1]) + "," + str(self.density) + "," + str(self.num_chargers)

    def __repr__(self):
        return self.__str__()