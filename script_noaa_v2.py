import pygrib
import os
from math import exp, ceil
import urllib
import urllib.request
from urllib3.util import parse_url, Url
from urllib.parse import quote
import sys
import datetime as dt
import numpy as np
import mysql.connector as sql
import shutil
import time
from time import sleep
from params import *


start = time.time()






### Fonctions
"""
Ajouter les identifiants de connexion à l'URL du proxy

@param   url        URL du proxy
@param   username   nom d'utilisateur du proxy
@param   password   mot de passe du proxy
"""
def addCredsToUrl(url, username, password):
    url_dict = parse_url(url)._asdict()
    url_dict['auth'] = username + ':' + quote(password, '')
    return Url(**url_dict).url


"""
Télécharger les données depuis le NOAA

@param   date            date des données au format YYYY-MM-dd
@param   time            heure des données parmi 0, 6, 12, 18
@param   beginForecast   heure de début des prévisions parmi 0, 13, 25, 37, 49, 61, 73, 85, 97
"""
def getData(date, time, beginForecast):
    if len(str(time)) <= 1:
        time = "0"+str(time)
    if len(str(beginForecast)) <= 1:
        beginForecast = "0"+str(beginForecast)
    #Gestion des coordonnées
    leftlon = int(lonData1)
    rightlon = int(ceil(lonData2))
    bottomlat = int(latData1)
    toplat = int(ceil(latData2))
    #Gestion de la date
    date = date.replace("-", "")

    print("Téléchargement...")

    url = "https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=gfs.t"+str(time)+"z.pgrb2.0p25.f0"+str(beginForecast)+"&lev_1000_mb=on&lev_700_mb=on&lev_750_mb=on&lev_800_mb=on&lev_850_mb=on&lev_900_mb=on&lev_925_mb=on&lev_950_mb=on&lev_975_mb=on&var_HGT=on&var_PRES=on&var_RH=on&var_TMP=on&subregion=&leftlon="+str(leftlon)+"&rightlon="+str(rightlon)+"&toplat="+str(toplat)+"&bottomlat="+str(bottomlat)+"&dir=%2Fgfs.20230713%2F"+str(time)+"%2Fatmos"

    #Gestion du proxy
    proxyUrlWithCreds = addCredsToUrl(proxyURL, proxyUser, proxyPasswd)+":"+str(proxyPort)
    proxies = {'http':  proxyUrlWithCreds, 'https':  proxyUrlWithCreds}
    proxy = urllib.request.ProxyHandler(proxies)
    opener = urllib.request.build_opener(proxy)
    urllib.request.install_opener(opener)
    urllib.request.urlretrieve(url, dataPath)
    print("Téléchargé dans "+dataPath)
    return


"""
Calcul du coïndice de réfraction N

@param   T   Température en Kelvin
@param   P   Pression en Pascal
@param   H   Humidité en %
"""
def N(T, P, H):
    P2 = P/100 #Conversion pression de Pa vers hPa
    return 77.6*(P2/T) + 22813.8*(H/T**2)*exp( ((3833.65-T)*(T-273.15))/((T-16.01)*234.5) )


"""
Formatage de la date

@param   fcstHour   nombre d'heures séparant la date des données de la date des prévisions
@param   format     format de la date à afficher
"""
def extractDate(fcstHour, format='en'):
    if len(sys.argv[2]) <= 1:
        dateStr = sys.argv[1]+"_0"+sys.argv[2]+":00:00"
    else:
        dateStr = sys.argv[1]+"_"+sys.argv[2]+":00:00"

    date = dt.datetime.strptime(dateStr, '%Y-%m-%d_%H:%M:%S')
    delta = dt.timedelta(hours=fcstHour)

    fcstDate = date + delta
    if format == 'en':
        return fcstDate.strftime('%Y-%m-%d %H:%M:%S')
    elif format == 'fr':
        return fcstDate.strftime('%d/%m/%Y à %H:%M:%S')
    elif format == 'file':
        return fcstDate.strftime('%Y-%m-%d_%H_%M_%S')


"""
Récupérer les infos relatives aux données

@param   data   étiquette de l'échantillon de données issue du fichier grib2
"""
def getInfos(data):
    infos = data.split(":")
    param = infos[5].split(" ")[1]
    fcst_time = infos[6].split(" ")[2]
    return int(param), int(fcst_time)


"""
Calcul de l'altitude (en m) en fonction de la pression (en Pa)
parmi une liste de pressions connues

@param   P   pression atmosphérique en Pa
"""
def getAltitude(P):
    listP = [70000, 75000, 80000, 85000, 90000, 92500, 95000, 97500, 100000]
    listAlt = [3010.9, 2465.2, 1949, 1456.7, 988.5, 762, 540.3, 323.5, 110.9]
    assert P in listP
    for i in range(len(listP)):
        if listP[i] == P:
            return listAlt[i]




### Script
if len(sys.argv) < 4 or len(sys.argv) > 4:
    print("Usage : "+sys.argv[0]+" date time beginForecast")
    print(" - date          --> date des données au format YYYY-MM-dd")
    print(" - time          --> heure des données parmi 0, 6, 12, 18")
    print(" - beginForecast --> heure de début des prévisions parmi 0, 13, 25, 37, 49, 61, 73, 85, 97")
    sys.exit(0)


#Création de la base de donénes
conn = sql.connect(host=mysqlHost, user=mysqlUser, password=mysqlPasswd, database=mysqlDb)
db = conn.cursor()
db.execute("CREATE TABLE IF NOT EXISTS noaa ("
    + "forecast_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, "
    + "lon FLOAT, "
    + "lat FLOAT, "
    + "pressure_Pa BIGINT, "
    + "gradient_N DOUBLE, "
    + "CONSTRAINT PK_noaa PRIMARY KEY (forecast_date, lon, lat, pressure_Pa))")

#Suppression des anciennes données
db.execute("DELETE FROM noaa WHERE forecast_date <= NOW() - INTERVAL "+str(dataConservation)+" DAY")
conn.commit()


for j in range(12):
    dataPath = path+"data_"+dt.datetime.now().strftime('%Y-%m-%d_%H_%M_%S')+".grib2"
    getData(sys.argv[1], int(sys.argv[2]), int(sys.argv[3])+j)

    grbT = pygrib.open(dataPath).select(name="Temperature")
    grbHGT = pygrib.open(dataPath).select(name="Geopotential Height")
    grbH = pygrib.open(dataPath).select(name="Relative humidity")

    n = len(grbT)

    for i in range(1, n):

        #Données sur la 1ère couche d'altitude
        selectedT1 = grbT[i-1]
        actualDataT1, lats, lons = selectedT1.data(lat1=latData1,lat2=latData2+0.1,lon1=lonData1,lon2=lonData2+0.1)

        selectedHGT1 = grbHGT[i-1]
        actualDataHGT1 = selectedHGT1.data(lat1=latData1,lat2=latData2+0.1,lon1=lonData1,lon2=lonData2+0.1)[0]

        selectedH1 = grbH[i-1]
        actualDataH1 = selectedH1.data(lat1=latData1,lat2=latData2+0.1,lon1=lonData1,lon2=lonData2+0.1)[0]

        P1, fcstHour = getInfos(str(selectedT1))

        #Données sur la 2ème couche d'altitude
        selectedT2 = grbT[i]
        actualDataT2 = selectedT2.data(lat1=latData1,lat2=latData2+0.1,lon1=lonData1,lon2=lonData2+0.1)[0]

        selectedHGT2 = grbHGT[i]
        actualDataHGT2 = selectedHGT2.data(lat1=latData1,lat2=latData2+0.1,lon1=lonData1,lon2=lonData2+0.1)[0]

        selectedH2 = grbH[i]
        actualDataH2 = selectedH2.data(lat1=latData1,lat2=latData2+0.1,lon1=lonData1,lon2=lonData2+0.1)[0]

        P2, fcstHour = getInfos(str(selectedT2))

        print("   Calculs et ajout dans la base de données...")
        for l in range(len(actualDataT1)):

            #Conception de la requête SQL
            query = 'INSERT INTO noaa VALUES '

            for k in range(len(actualDataT1[l])):

                #Récupération des données brutes
                T1 = actualDataT1[l][k]
                HGT1 = actualDataHGT1[l][k]
                H1 = actualDataH1[l][k]
                T2 = actualDataT2[l][k]
                HGT2 = actualDataHGT2[l][k]
                H2 = actualDataH2[l][k]

                #Calcul du gradient dN/dz, en N/km
                grad = (N(T2, P2, H2)-N(T1, P1, H1))/(getAltitude(P2)/1000-getAltitude(P1)/1000)

                query += '("'+extractDate(fcstHour)+'",'+str(round(lons[l][k], 2))+','+str(round(lats[l][k], 2))+','+str(P1)+','+str(grad)+'), '


            #Insertion des données dans la base de données
            query = query[:-2] + ' ON DUPLICATE KEY UPDATE gradient_N = VALUES(gradient_N)'
            db.execute(query)

        conn.commit()

        #Création du répertoire de la prévision si besoin
        if not os.path.exists(path+"maps"):
            os.mkdir(path+"maps")
        if not os.path.exists(path+"maps/noaa"):
            os.mkdir(path+"maps/noaa")
        if not os.path.exists(path+"maps/noaa/"+extractDate(fcstHour, 'file')):
            os.mkdir(path+"maps/noaa/"+extractDate(fcstHour, 'file'))

        #Génération de la carte via un processus en parallèle
        os.system("python3 "+path+"draw_img.py "+sys.argv[1]+" "+sys.argv[2]+" "+str(fcstHour)+" "+str(P1)+" noaa > /dev/null")

    #Suppression du fichier de données grib2
    os.remove(dataPath)



#On ferme la connexion à MySQL
conn.close()


#Suppression des anciennes cartes
curDate = dt.datetime.now()
delta = dt.timedelta(days=dataConservation)
dataConservationDate = curDate - delta
for dir in os.listdir(path+"maps/noaa"):
    date = dt.datetime.strptime(dir, '%Y-%m-%d_%H_%M_%S')
    if date <= dataConservationDate:
        shutil.rmtree(path+"maps/noaa/"+dir)


duration = time.time() - start
print("Fin : exécuté en "+str(int(duration//60))+":"+str(int(round(duration%60, 0))))
