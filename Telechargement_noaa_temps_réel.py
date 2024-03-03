import requests
from datetime import datetime
import pandas as pd

# Download data from NOAA
def download_noaa_data(date, heure_prevision,nom_fichier):
    url =  "https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p50.pl?file=gfs.t"+heure_prevision+"z.pgrb2full.0p50.f000&all_lev=on&all_var=on&leftlon=0&rightlon=360&toplat=90&bottomlat=-90&dir=%2Fgfs."+date+"%2F"+heure_prevision+"%2Fatmos"
    response = requests.get(url)
    if response.status_code == 200:
        with open(nom_fichier, "wb") as file:
            file.write(response.content)
        print("GRIB file saved successfully.")
    else:
        print("Failed to fetch data.", response.status_code)



# Extrait la date d'aujourd'hui sous format yyyymmdd
date = datetime.now().strftime("%Y%m%d")



heure=datetime.now().hour

if heure <= 12:
    heure_prevision = "00"
else:
    heure_prevision = "12"


#heure_prevision = "00"
nom_fichier = "donnees_NOAA/"+date + ".grib"
download_noaa_data(date, heure_prevision,nom_fichier)
