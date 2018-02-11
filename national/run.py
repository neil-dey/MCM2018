from geopy.geocoders import Nominatim
from geopy.geocoders import GoogleV3
from geopy.distance import vincenty
from geopy.distance import great_circle

from network import *

def main():

    net = Network([800, 800, 800])
    net.load_from_file("../data/TestFile.csv")

    print(net.nodes)
    print(net.distances)
    print(net.links)

    net.simulate(100)

    print("Growth Rate: %s" % net.total_growth_metric())

if __name__ == "__main__":

    main()