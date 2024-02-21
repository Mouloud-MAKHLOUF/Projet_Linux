import requests
from datetime import datetime
import rasterio
import pandas as pd

# Download data from NOAA
def download_noaa_data(date, time,nom_paquet):
    url = f"https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?dir=%2Fgfs.{date}%2F{time}%2Fatmos&file=gfs.t06z.pgrb2.0p25.f000&all_var=on&all_lev=on"
    print(url)
    response = requests.get(url)
    if response.status_code == 200:
        with open(f"DONNEES_NOAA/donnees_noaa_{nom_paquet}_{date}T_{time}t_echeance_000", "wb") as file:
            file.write(response.content)
        print("GRIB file saved successfully.")
    else:
        print("Failed to fetch data.", response.status_code)

# Example usage
#date = datetime.now().strftime("%Y%m%d")
date = "20240221"

time = "06"  # Example time, can be 0, 6, 12, 18
nom_paquet="HP1"

download_noaa_data(date, time, nom_paquet)