from geopy.geocoders import Nominatim
from geopy.geocoders import GoogleV3
from geopy.distance import vincenty
from geopy.distance import great_circle

from network import *

import sys

def main():

    net = Network([0, 0, 0]) # Will be updated on load from memory
    net.read_from_memory("../data/nodes.p", "../data/distance.p", "../data/link.p", "../data/radii.p")

    print(net.nodes)
    print(net.distances)
    print(net.links)

    print("Average Degree of Nodes: %s" % net.average_degree())

    print("Initial Growth Metric: %s" % net.total_growth_metric())

    net.simulate(9999999999)

    print("Final Growth Metric: %s" % net.total_growth_metric())

def save():

    net = Network([100, 75, 50])
    net.load_from_file("../data/AllInitConditions.csv")

    print(net.nodes)
    print(net.distances)
    print(net.links)

    net.write_to_memory("../data/nodes.p", "../data/distance.p", "../data/link.p", "../data/radii.p")

if __name__ == "__main__":

    sys.setrecursionlimit(1000000)
    if (sys.argv[1] == "--run"):
        main()
    if (sys.argv[1] == "--save"):
        save()