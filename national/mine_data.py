from geopy.geocoders import Nominatim
from geopy.geocoders import GoogleV3
from geopy.distance import vincenty
from geopy.distance import great_circle
import time

def main():
    geolocator = Nominatim()
    locations = read_csv("C:/Users/neild/git/MCM2018/data/KoreaTemp.csv")
    with open("C:/Users/neild/git/MCM2018/data/Korea_Coords.csv", "w", encoding="utf8") as file:
        for k in range(len(locations)):
            #print(locations[k])
            try:
                time.sleep(0.5)
                location = geolocator.geocode(locations[k])
                coordinates = (location.latitude, location.longitude)
                file.write("\"%s\",\"%s\",\"%s\"\n" % (locations[k], coordinates[0], coordinates[1]))
            except KeyboardInterrupt:
                exit()
            except Exception as e:
                # print("Location %s not found" % locations[k])
                # print("Error: %s" % e)
                file.write("\"%s\",,\n" % locations[k])

def read_csv(fileName):
    locations = []
    with open(fileName, "r", encoding="utf8") as file:
        for line in file:
            locations.append(line.replace("\n", ""))
    return locations

if __name__ == "__main__":
    main()
