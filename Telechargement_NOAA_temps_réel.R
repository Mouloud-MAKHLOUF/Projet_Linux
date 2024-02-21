list.of.packages <- c("httr","glue","rNOMADS")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)


library(httr)
library(glue)
library(rNOMADS)


"""
Télécharger les données depuis le NOAA

@param   date            date des données au format YYYY-MM-dd
@param   time            heure des données parmi 0, 6, 12, 18
@param   beginForecast   heure de début des prévisions parmi 0, 13, 25, 37, 49, 61, 73, 85, 97
"""



url = "https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=gfs.t"+str(time)+"z.pgrb2.0p25.f0"+str(beginForecast)+"&lev_1000_mb=on&lev_700_mb=on&lev_750_mb=on&lev_800_mb=on&lev_850_mb=on&lev_900_mb=on&lev_925_mb=on&lev_950_mb=on&lev_975_mb=on&var_HGT=on&var_PRES=on&var_RH=on&var_TMP=on&subregion=&leftlon="+str(leftlon)+"&rightlon="+str(rightlon)+"&toplat="+str(toplat)+"&bottomlat="+str(bottomlat)+"&dir=%2Fgfs.20230713%2F"+str(time)+"%2Fatmos"

URL <- "https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?dir=%2Fgfs.20240218%2F06%2Fatmos&file=gfs.t06z.pgrb2.0p25.f000&all_var=on&all_lev=on"







current_datetime <- Sys.time()

# Extract the date part
date_only <- as.Date(current_datetime)
# Extract the hours portion
heure <- format(current_datetime, "%H")
heure <- as.numeric(heure)

#-- Nous avons 4 prévision fournit par jour (nommées réseaux dans la documentation officiel) 
#-- Nous choississon à chaque fois la dernière disponible




#-- L"API fournit plusieurs paquets groupé en trois catégories differentes 
#-- Champs surface, Champs isobares, Champs hauteurs
#-- Champs surface : SP1, SP2
#-- Champs isobares : IP1, IP2, IP3, IP4
#-- Champs hauteurs : HP1, HP2

#-- Nous choisisons HP1 car il s'interesse à plusieurs variables sur differentes hauteurs de 20m à 3000m
#-- Voir la doc pour plus de details

nom_paquet <- "HP1"

#-- echeance : 102 écheances répartit en 9 groupes 00-12 , 13-24, 25-36, 37-48,
#-- 49-60, 61-72, 73-94, 95-96, 97-102
#-- Nous prendrons l'écheance 00-12

echeance <- "000H012H"


#-- La connexion necessite un API KEY qu'on genere à partir du site ortail-api.meteofrance.fr/
#-- La clef est valable 3 ans 

apikey <- "eyJ4NXQiOiJZV0kxTTJZNE1qWTNOemsyTkRZeU5XTTRPV014TXpjek1UVmhNbU14T1RSa09ETXlOVEE0Tnc9PSIsImtpZCI6ImdhdGV3YXlfY2VydGlmaWNhdGVfYWxpYXMiLCJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJNQUtITE9VRkBjYXJib24uc3VwZXIiLCJhcHBsaWNhdGlvbiI6eyJvd25lciI6Ik1BS0hMT1VGIiwidGllclF1b3RhVHlwZSI6bnVsbCwidGllciI6IjEwUGVyTWluIiwibmFtZSI6IlJlY3VwZXJhdGlvbl9kb25uZWVzX21ldGVvX2ZyYW5jZSIsImlkIjo5MzEzLCJ1dWlkIjoiMWZhY2E0NWYtYmU3ZS00NDA1LWE2MjUtOTJkNzI1MTkxMGQ2In0sImlzcyI6Imh0dHBzOlwvXC9wb3J0YWlsLWFwaS5tZXRlb2ZyYW5jZS5mcjo0NDNcL29hdXRoMlwvdG9rZW4iLCJ0aWVySW5mbyI6eyI1MFBlck1pbiI6eyJ0aWVyUXVvdGFUeXBlIjoicmVxdWVzdENvdW50IiwiZ3JhcGhRTE1heENvbXBsZXhpdHkiOjAsImdyYXBoUUxNYXhEZXB0aCI6MCwic3RvcE9uUXVvdGFSZWFjaCI6dHJ1ZSwic3Bpa2VBcnJlc3RMaW1pdCI6MCwic3Bpa2VBcnJlc3RVbml0Ijoic2VjIn0sIjM1MFJlcVBhck1pbiI6eyJ0aWVyUXVvdGFUeXBlIjoicmVxdWVzdENvdW50IiwiZ3JhcGhRTE1heENvbXBsZXhpdHkiOjAsImdyYXBoUUxNYXhEZXB0aCI6MCwic3RvcE9uUXVvdGFSZWFjaCI6dHJ1ZSwic3Bpa2VBcnJlc3RMaW1pdCI6MCwic3Bpa2VBcnJlc3RVbml0Ijoic2VjIn0sIlVubGltaXRlZCI6eyJ0aWVyUXVvdGFUeXBlIjoicmVxdWVzdENvdW50IiwiZ3JhcGhRTE1heENvbXBsZXhpdHkiOjAsImdyYXBoUUxNYXhEZXB0aCI6MCwic3RvcE9uUXVvdGFSZWFjaCI6dHJ1ZSwic3Bpa2VBcnJlc3RMaW1pdCI6MCwic3Bpa2VBcnJlc3RVbml0IjpudWxsfX0sImtleXR5cGUiOiJQUk9EVUNUSU9OIiwicGVybWl0dGVkUmVmZXJlciI6IiIsInN1YnNjcmliZWRBUElzIjpbeyJzdWJzY3JpYmVyVGVuYW50RG9tYWluIjoiY2FyYm9uLnN1cGVyIiwibmFtZSI6IkFST01FIiwiY29udGV4dCI6IlwvcHVibGljXC9hcm9tZVwvMS4wIiwicHVibGlzaGVyIjoiYWRtaW5fbWYiLCJ2ZXJzaW9uIjoiMS4wIiwic3Vic2NyaXB0aW9uVGllciI6IjUwUGVyTWluIn0seyJzdWJzY3JpYmVyVGVuYW50RG9tYWluIjoiY2FyYm9uLnN1cGVyIiwibmFtZSI6IkFSUEVHRSIsImNvbnRleHQiOiJcL3B1YmxpY1wvYXJwZWdlXC8xLjAiLCJwdWJsaXNoZXIiOiJhZG1pbl9tZiIsInZlcnNpb24iOiIxLjAiLCJzdWJzY3JpcHRpb25UaWVyIjoiNTBQZXJNaW4ifSx7InN1YnNjcmliZXJUZW5hbnREb21haW4iOiJjYXJib24uc3VwZXIiLCJuYW1lIjoiUGFxdWV0QVJQRUdFIiwiY29udGV4dCI6IlwvcHJldmludW1cL0RQUGFxdWV0QVJQRUdFXC92MSIsInB1Ymxpc2hlciI6ImZyaXNib3VyZyIsInZlcnNpb24iOiJ2MSIsInN1YnNjcmlwdGlvblRpZXIiOiJVbmxpbWl0ZWQifSx7InN1YnNjcmliZXJUZW5hbnREb21haW4iOiJjYXJib24uc3VwZXIiLCJuYW1lIjoiUGFxdWV0QVJPTUUtT00iLCJjb250ZXh0IjoiXC9wcmV2aW51bVwvRFBQYXF1ZXRBUk9NRS1PTVwvdjEiLCJwdWJsaXNoZXIiOiJmcmlzYm91cmciLCJ2ZXJzaW9uIjoidjEiLCJzdWJzY3JpcHRpb25UaWVyIjoiMzUwUmVxUGFyTWluIn0seyJzdWJzY3JpYmVyVGVuYW50RG9tYWluIjoiY2FyYm9uLnN1cGVyIiwibmFtZSI6IlBhcXVldEFST01FIiwiY29udGV4dCI6IlwvcHJldmludW1cL0RQUGFxdWV0QVJPTUVcL3YxIiwicHVibGlzaGVyIjoiZnJpc2JvdXJnIiwidmVyc2lvbiI6InYxIiwic3Vic2NyaXB0aW9uVGllciI6IjUwUGVyTWluIn1dLCJ0b2tlbl90eXBlIjoiYXBpS2V5IiwicGVybWl0dGVkSVAiOiIiLCJpYXQiOjE3MDgxODcxMDAsImp0aSI6IjNjODBhNTQ2LTdhYjItNDAxYy1hZmY1LWMwZjdlNWVmNDk3YiJ9.ByvNcLX8LOf-nPXcgjba-nw0XgukTv2jP1uL2JkIb7xiIfZEwWPQzfI2SM6ACaGIxg7dZQPth4Dp9Mt7ePdxEmQnqPsuY4PMafoDOy9t7llHHr5jAMNGqDlW5OeBvpVsgrhGm_4zxSLqgxLbK64rjSDQeJ7KfpQe0Sd9dBvoOoUBXB4Pt4wFVpIi43Y6y75J-IGlWzgllOBzaMvquNIKj3Aqi2v7atXRnvobvGUZ8BS-vSzAen8p0rbyQQR5wGJZuu63OYk84ju_da1bDE_lxJJcBtUXEpWFHMG9bA1yg9fAangeI0169NiSOF3lpk9Ujt3euzu9aeU0-S67hTh37w=="


#-- Date de la prevision 
date_string <- format(date_only, "%Y-%m-%d")

#-- URL pour telecharger les données de prévision méteo france
response <- GET(URL)

#-- Chemin pour sauvegarder le fichier telechargé
nom_fichier <- glue("donnees_meteo_france/donnees_meteo_france_{nom_paquet}_{date_string}T_{heure_prevision}t_echeance_{echeance}")


if (http_status(response)$category == "Success") {
  # Extract content from response
  grib_content <- content(response, "raw")
  
  # Write content to a .grb file
  writeBin(grib_content, "NOAA")
  print("GRIB file saved successfully.")
} else {
  print("Failed to fetch data.")
}


raster_data <- raster("NOAA.grib2")

variables <- names(raster_data)

raster_df <- as.data.frame(raster_data, xy = TRUE)

variables[3]


