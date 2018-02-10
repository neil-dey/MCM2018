from geopy.geocoders import Nominatim
from geopy.geocoders import GoogleV3
from geopy.distance import vincenty
from geopy.distance import great_circle

def main():
    geolocator = Nominatim()
    googleAPI = GoogleV3(api_key="AIzaSyAQAiLktW0gJ9COS2stDmxuc_dZRCzcf-k")
    locations = read_csv("../data/TeslaCarLocations.csv")
    with open("../data/TeslaCarLocations_Coords.csv", "w") as file:
        for k in range(len(locations)):
            print(locations[k])
            try:
                location = geolocator.geocode(locations[k])
                coordinates = (location.latitude, location.longitude)
                print("%s, %s" % (location, geolocator.reverse(coordinates)))
                file.write("\"%s\",\"%s\",\"%s\"\n" % (locations[k], coordinates[0], coordinates[1]))
            except KeyboardInterrupt:
                exit()
            except Exception as e:
                print("Location %s not found" % locations[k])
                print("Error: %s" % e)
                file.write("\"%s\",,\n" % locations[k])

def read_csv(fileName):
    locations = []
    with open(fileName, "r") as file:
        for line in file:
            locations.append(line.replace("\n", ""))
    return locations

if __name__ == "__main__":
    main()