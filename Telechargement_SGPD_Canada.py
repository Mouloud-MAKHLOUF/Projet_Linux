import requests
from requests.auth import HTTPBasicAuth
import requests
from datetime import datetime

# Current datetime
current_datetime = datetime.now()

# Extract the date part and hour
# date_only = current_datetime.date()

heure = current_datetime.hour

# Determine forecast time based on current hour
if heure <=  12:
    heure_prevision = "00"

else:
    heure_prevision = "00"

# Date for the forecast
date = datetime.now().strftime("%Y%m%d")


# URL de base pour télécharger les données du centre météorologique canadien
URL_base = "https://dd.meteo.gc.ca/ensemble/geps/grib2/raw/"
#-------------------------------------------------------------------------------------------------
#Telechargement de la variables RH
#URL pour telecharger l'humidité relative

URL_RH= "CMC_geps-raw_RH_ISBL_1000_latlon0p5x0p5_"+date+heure_prevision+"_P000_allmbrs.grib2"

# Composition de l'URL en entiereté 

URL = URL_base + heure_prevision + "/000/" +URL_RH


response = requests.get(URL)

nom_fichier ="donnees_canadienne/"+date+"_RH.grib"

if response.ok:
    # Save the content to a .grib2 file
    with open(nom_fichier, 'wb') as file:
        file.write(response.content)
    print("GRIB file saved successfully.")
else:
    print("Failed to fetch data.")
#---------------------------------------------------------------------------------------
#Telechargement de la variables TMP
#URL pour telecharger l'humidité relative
URL_TMP= "CMC_geps-raw_TMP_ISBL_1000_latlon0p5x0p5_"+date+heure_prevision+"_P000_allmbrs.grib2"

# Composition de l'URL en entiereté 

URL = URL_base + heure_prevision + "/000/" +URL_TMP


response = requests.get(URL)

nom_fichier ="donnees_canadienne/"+date+"_TMP.grib"

if response.ok:
    # Save the content to a .grib2 file
    with open(nom_fichier, 'wb') as file:
        file.write(response.content)
    print("GRIB file saved successfully.")
else:
    print("Failed to fetch data.")


#---------------------------------------------------------------------------------------
#Telechargement de la variables HGT
#URL pour telecharger l'humidité relative
URL_VGRD= "CMC_geps-raw_VGRD_ISBL_1000_latlon0p5x0p5_"+date+heure_prevision+"_P000_allmbrs.grib2"
# Composition de l'URL en entiereté 


URL = URL_base + heure_prevision + "/000/" +URL_VGRD

response = requests.get(URL)

nom_fichier ="donnees_canadienne/"+date+"_VGRD.grib"

if response.ok:
    # Save the content to a .grib2 file
    with open(nom_fichier, 'wb') as file:
        file.write(response.content)
    print("GRIB file saved successfully.")
else:
    print("Failed to fetch data.")