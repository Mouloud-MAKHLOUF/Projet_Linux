import requests
from datetime import datetime
import rasterio
import pandas as pd

# Download data from NOAA
def download_noaa_data(date, heure_prevision,nom_paquet):
    url = f"https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?dir=%2Fgfs.{date}%2F{heure_prevision}%2Fatmos&file=gfs.t06z.pgrb2.0p25.f000&all_var=on&all_lev=on"
    response = requests.get(url)
    if response.status_code == 200:
        with open(f"DONNEES_NOAA/donnees_noaa_{nom_paquet}_{date}T_{heure_prevision}t_echeance_000", "wb") as file:
            file.write(response.content)
        print("GRIB file saved successfully.")
    else:
        print("Failed to fetch data.", response.status_code)

# Example usage
date = datetime.now().strftime("%Y%m%d")
#date = "20240221"
#time = "06"  # Example time, can be 0, 6, 12, 18
nom_paquet="HP1"
heure=datetime.now().hour
if heure <= 6:
    heure_prevision = "00"
elif heure <= 12:
    heure_prevision = "06"
elif heure <= 18:
    heure_prevision = "12"
else:
    heure_prevision = "12"

download_noaa_data(date, heure_prevision, nom_paquet)