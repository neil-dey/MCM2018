from geopy.distance import vincenty

class NodeType:

    URBAN = 0
    SUBURBAN = 1
    RURAL = 2

class Node:

    VINCENTY_ITERS = 100

    def __init__(self, coordinate, density):
        self.coordinate = coordinate
        self.growth_metric = 0
        self.density = density
        self.prop_electric = 0.0
        self.num_chargers = 0
        self.neighbors = {}
        if (density > 0 and density < 1000):
            self.type = NodeType.RURAL
        elif (density < 2500):
            self.type = NodeType.SUBURBAN
        else:
            self.type = NodeType.URBAN

    def tick(self, time):
        
        # TODO: Change prop_electric as node grows
        # TODO: Consider neighbors in calculating prop_electric
        pass

    def get_distance(self, node):
        return vincenty(self.coordinate, node.coordinate, iterations=Node.VINCENTY_ITERS).miles

    def __str__(self):
        return "(" + str(self.coordinate[0]) + "," + str(self.coordinate[1]) + ")"

    def __repr__(self):
        return self.__str__()