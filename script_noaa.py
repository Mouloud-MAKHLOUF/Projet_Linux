import pygrib

dataPath = "NOAA.grib2"


grbs = pygrib.open('NOAA.grib2')
#Charger les données depuis le fichier grib2
grbT = pygrib.open(dataPath).select(name="Temperature")
grbP = pygrib.open(dataPath).select(name="Pressure")
grbH = pygrib.open(dataPath).select(name="Relative humidity")


for grb in grbs:
    print(grb)
