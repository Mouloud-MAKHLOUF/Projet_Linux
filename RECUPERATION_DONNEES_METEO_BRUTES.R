# Autheur : Zineddine TIGHIDET.
# Utilité : Télécharger l'ensemble des épisodes spécifiés dans `dates` en séparant
# en Avant, Pendant et Après dans des dossiers différents.
# ------------------------------------------------------------------------------
# Dependences : fichier levels.csv
# ------------------------------------------------------------------------------
library(xml2)
library(rNOMADS)
library(rvest)
library(csv)
library(sf)
library(tidyverse)
library(tmap)
library(lubridate)
library(glue)
library(chron)
library(RCurl)
# ------------------------------------------------------------------------------
# charger les dates de début et de fin des épisodes de PE
dates <- data.frame(
  NUMERO = seq(1, 1),
  DEBUT = dmy(c('01-02-2022')),
  FIN = dmy(c('02-02-2022'))
)
# write_csv(dates, "LISTES_EPISODES/LISTE1/dates_liste2.csv")

# le numéro de liste à attribuer aux épisodes
NUM_LISTE <- 2

#dates <- read_csv(glue("LISTES_EPISODES/LISTE{NUM_LISTE}/dates.csv"))

# dates <- data.frame(
#   NUMERO = seq(1, 3),
#   DEBUT = ymd(c("2022/09/01", "2022/06/01", "2022/07/20")),
#   FIN = ymd(c("2022/09/03", "2022/06/03", "2022/07/26"))
# )

# on prend tous les niveaux
# levels <- c('0.01 mb',
#             '0-0.1 m below ground',
#             '0.02 mb',
#             '0.04 mb',
#             '0.07 mb',
#             '0.1-0.4 m below ground',
#             '0.1 mb',
#             '0.2 mb',
#             '0.33-1 sigma layer',
#             '0.4-1 m below ground',
#             '0.44-0.72 sigma layer',
#             '0.44-1 sigma layer',
#             '0.4 mb',
#             '0.72-0.94 sigma layer',
#             '0.7 mb',
#             '0.995 sigma level',
#             '0C isotherm',
#             '1000 m above ground',
#             '1000 mb',
#             '100 m above ground',
#             '100 mb',
#             '10 m above ground',
#             '10 m above mean sea level',
#             '10 mb',
#             '120-90 mb above ground',
#             '125 mb',
#             '1-2 m below ground',
#             '150-120 mb above ground',
#             '150 mb',
#             '15 mb',
#             '175 mb',
#             '180-0 mb above ground',
#             '180-150 mb above ground',
#             '1829 m above mean sea level',
#             '1 hybrid level',
#             '1 mb',
#             '200 mb',
#             '20 m above ground',
#             '20 mb',
#             '225 mb',
#             '250 mb',
#             '255-0 mb above ground',
#             '2743 m above mean sea level',
#             '275 mb',
#             '2 hybrid level',
#             '2 m above ground',
#             '2 mb',
#             '3000-0 m above ground',
#             '300 mb',
#             '30-0 mb above ground',
#             '305 m above mean sea level',
#             '30 m above ground',
#             '30 mb',
#             '325 mb',
#             '350 mb',
#             '3658 m above mean sea level',
#             '375 mb',
#             '3 mb',
#             '4000 m above ground',
#             '400 mb',
#             '40 m above ground',
#             '40 mb',
#             '425 mb',
#             '450 mb',
#             '4572 m above mean sea level',
#             '457 m above mean sea level',
#             '475 mb',
#             '500 mb',
#             '50 m above ground',
#             '50 mb',
#             '525 mb',
#             '550 mb',
#             '575 mb',
#             '5 mb',
#             '6000-0 m above ground',
#             '600 mb',
#             '60-30 mb above ground',
#             '610 m above mean sea level',
#             '625 mb',
#             '650 mb',
#             '675 mb',
#             '700 mb',
#             '70 mb',
#             '725 mb',
#             '750 mb',
#             '775 mb',
#             '7 mb',
#             '800 mb',
#             '80 m above ground',
#             '825 mb',
#             '850 mb',
#             '875 mb',
#             '900 mb',
#             '90-0 mb above ground',
#             '90-60 mb above ground',
#             '914 m above mean sea level',
#             '925 mb',
#             '950 mb',
#             '975 mb',
#             'boundary layer cloud layer',
#             'cloud ceiling',
#             'convective cloud bottom level',
#             'convective cloud layer',
#             'convective cloud top level',
#             'entire atmosphere',
#             'entire atmosphere (considered as a single layer)',
#             'high cloud bottom level',
#             'high cloud layer',
#             'high cloud top level',
#             'highest tropospheric freezing level',
#             'low cloud bottom level',
#             'low cloud layer',
#             'low cloud top level',
#             'max wind',
#             'mean sea level',
#             'middle cloud bottom level',
#             'middle cloud layer',
#             'middle cloud top level',
#             'planetary boundary layer',
#             'PV=-1.5e-06 (Km^2/kg/s) surface',
#             'PV=1.5e-06 (Km^2/kg/s) surface',
#             'PV=-1e-06 (Km^2/kg/s) surface',
#             'PV=1e-06 (Km^2/kg/s) surface',
#             'PV=-2e-06 (Km^2/kg/s) surface',
#             'PV=2e-06 (Km^2/kg/s) surface',
#             'PV=-5e-07 (Km^2/kg/s) surface',
#             'PV=5e-07 (Km^2/kg/s) surface',
#             'surface',
#             'top of atmosphere',
#             'tropopause')

# charger les niveaux qui nous interessent (i.e 1600 m max)
levels <- read.csv(file = "levels.csv")
levels <- levels$levels

# l'ensemble des variables disponibles (peut y avoir des manques selon la période)
# voir le document partagé pour plus d'information sur la signification de chaque variable
# variables <- c('no4LFTX', 'no5WAVH', 'ABSV', 'CAPE', 'CAPE180_0mb', 'CIN', 'CIN180_0mb', 'oCWORKclm', 'oDLWRFsfc', 'oDSWRFsfc', 'GFLUX', 'HGTsfc', 'HGT', 'HGTmwl', 'HGTtrp', 'HPBL', 'ICEC', 'LAND', 'LFTX', 'oLHTFL', 'O3MR_100mb', 'O3MR_70mb', 'O3MR_50mb', 'O3MR_30mb', 'O3MR_20mb', 'O3MR_10mb', 'POTsig995', 'PRESsfc', 'PRESlcb', 'PRESlct', 'PRESmcb', 'PRESmct', 'PREShcb', 'PREShct', 'CLWMR', 'PREScvb', 'PREScvt', 'PRESmwl', 'PREStrp', 'PRMSL', 'PWATclm', 'RH', 'RH2m', 'RHsig995', 'RH30_0mb', 'RHclm', 'oSHTFL', 'SOILWSoilT', 'SOILWSoilM', 'SPFH2m', 'SPFH30_0mb', 'oTCDCclm', 'oTCDCbcl', 'oTCDClcl', 'oTCDCmcl', 'oTCDChcl', 'oTCDCcvl', 'TMAX2m', 'TMIN2m', 'TMPsfc', 'TMP', 'TMP1829m', 'TMP2743m', 'TMP3658m', 'TMP2m', 'TMPsig995', 'TMPSoilT', 'TMPSoilM', 'TMP30_0mb', 'oTMPlct', 'oTMPmct', 'oTMPhct', 'TMPmwl', 'TMPtrp', 'TOZNEclm', 'UGWD', 'oUFLX', 'UGRD', 'UGRD1829m', 'UGRD2743m', 'UGRD3658m', 'UGRD10m', 'UGRDsig995', 'UGRD30_0mb', 'UGRDmwl', 'UGRDtrp', 'oULWRFsfc', 'oULWRFtoa', 'oUSWRFsfc', 'oUSWRFtoa', 'VGWD', 'oVFLX', 'VGRD', 'VGRD1829m', 'VGRD2743m', 'VGRD3658m', 'VGRD10m', 'VGRDsig995', 'VGRD30_0mb', 'VGRDmwl', 'VGRDtrp', 'VVEL', 'VVELsig995', 'VWSHtrp', 'oWATR', 'WEASD', 'RHsig1', 'RHsig2', 'RHsig3', 'RHsig4', 'CWATATM', 'HGT0DEG', 'RH0DEG', 'HGTHTFL', 'RHHTFL', 'HGTANOM', 'WAVA5', 'ALBDO', 'SOILW10', 'SOILW40', 'SOILW100', 'TMPsoil10', 'TMPsoil40', 'TMPsoil100', 'HGTPV34768', 'HGTPV2', 'TMPPV34768', 'TMPPV2', 'PSPV34768', 'PSPV2', 'VSHPV34768', 'VWSHPV2', 'UPV34768', 'UPV2', 'VPV34768', 'VPV2')

# on va se limiter aux variables qui nous interessent (déduite après l'analyse de données)
variables <- c("ABSV", "HGT", "RH", "TMP", "UGRD", "VGRD", "VVEL")

# les données qu'on récupère, utiliser NOMADSArchiveList() pour avoir la liste
# compléte de toutes les données disponibles.
# ici on utilise "gfslan" acronyme de Global Forecast System Analysis qui récupère
# les données météo du monde entier
abbrev <- "gfsanl"

historic_link <- "https://www.ncei.noaa.gov/data/global-forecast-system/access/historical/analysis"
#grid_003_1.0_degree_link <- "https://www.ncei.noaa.gov/data/global-forecast-system/access/grid-003-1.0-degree/analysis"
grid_004_0.5_degree_link <- "https://www.ncei.noaa.gov/data/global-forecast-system/access/grid-004-0.5-degree/analysis"

# fonction qui check si l'url existe bien pour ne pas planter le script avec une requete fausse
urlFileExist <- function(url){
  HTTP_STATUS_OK <- 200
  hd <- httr::HEAD(url)
  status <- hd$all_headers[[1]]$status
  list(exists = status == HTTP_STATUS_OK, status = status)
}

Sys.setlocale("LC_TIME", "French")
update <- FALSE # metre à jour les fichiers déjà téléchargés ?
for(i in 1:1){
  dir.create(glue("LISTES_EPISODES/LISTE{NUM_LISTE}/"))
  dir.create(glue("LISTES_EPISODES/LISTE{NUM_LISTE}/EP_{i}"))
  
  date_debut <- dates$DEBUT[i]
  date_fin <- dates$FIN[i]

  # 1) on commence par récupèrer les épisodes pré-propagations exceptionnelles :
  
  # Pour suivre la meme démarche que Rdiff, qui pour le coup nous ont fournit l'ensemble
  # des épisodes, on considère les données météo 4 jours avant la propa

  model.date_back <- date_debut # on prend 4 jours avant
  dir.create(glue("LISTES_EPISODES/LISTE{NUM_LISTE}/EP_{i}/AVANT/"))
  nb_days <- 4 # 4 jours avant
  k <- 1
  while(k <= nb_days){
    model.date_back <- model.date_back - 1
    # if(k > 3){ # après les 3 jours de marge on ne prend que les jours de semaine
    #   if(wday(model.date_back, label=T, abbr=F) == "dimanche"){
    #     nb_days <- nb_days + 2
    #   }else if(wday(model.date_back, label=T, abbr=F) == "samedi"){
    #     nb_days <- nb_days + 1
    #   }
    #  }

    
    model.date_back_chr <- paste(
      year(model.date_back),
      if(str_count(as.character(month(model.date_back))) == 1){ paste("0", month(model.date_back), sep="")  }else{ month(model.date_back) },
      if(str_count(as.character(day(model.date_back))) == 1){ paste("0", day(model.date_back), sep="")  }else{ day(model.date_back) },
      sep=""
    )
    
    model.date_back_chr.ym <- paste(
      year(model.date_back),
      if(str_count(as.character(month(model.date_back))) == 1){ paste("0", month(model.date_back), sep="")  }else{ month(model.date_back) },
      sep=""
    )
    
    for(model_run_hour in c("0000", "0600", "1200", "1800")){
      
      for(hours_after in c("000", "003")){
        
        file_exists <- urlFileExist(paste(paste(grid_004_0.5_degree_link, model.date_back_chr.ym, sep="/"),
                                          model.date_back_chr,
                                          glue("gfs_4_{model.date_back_chr}_{model_run_hour}_{hours_after}.grb2"),
                                          sep="/"))
        
        if(file_exists$exists){
          if(update | !file.exists(glue("LISTES_EPISODES/LISTE{NUM_LISTE}/EP_{i}/AVANT/gfs_4_{model.date_back_chr}_{model_run_hour}_{hours_after}.grb2"))){
            download.file(paste(paste(grid_004_0.5_degree_link, model.date_back_chr.ym, sep="/"),
                                model.date_back_chr,
                                glue("gfs_4_{model.date_back_chr}_{model_run_hour}_{hours_after}.grb2"),
                                sep="/"),
                          mode = "wb",
                          destfile = glue("LISTES_EPISODES/LISTE{NUM_LISTE}/EP_{i}/AVANT/gfs_4_{model.date_back_chr}_{model_run_hour}_{hours_after}.grb2")
            )
          }
        }else{
          if(update | !file.exists(glue("LISTES_EPISODES/LISTE{NUM_LISTE}/EP_{i}/AVANT/gfsanl_4_{model.date_back_chr}_{model_run_hour}_{hours_after}.grb2"))){
            download.file(paste(paste(historic_link, model.date_back_chr.ym, sep="/"),
                                model.date_back_chr,
                                glue("gfsanl_4_{model.date_back_chr}_{model_run_hour}_{hours_after}.grb2"),
                                sep="/"),
                          mode = "wb",
                          destfile = glue("LISTES_EPISODES/LISTE{NUM_LISTE}/EP_{i}/AVANT/gfsanl_4_{model.date_back_chr}_{model_run_hour}_{hours_after}.grb2")
            )
          }
        }
          
      }
      
    }
    k <- k + 1
  }
  
  # Après la probagation exceptionnelle

#   model.date_forward <- date_fin # on prend 3 jours de marge après (uniquement après l'analyse)
#   dir.create(glue("LISTES_EPISODES/LISTE{NUM_LISTE}/EP_{i}/APRES/"))
#   nb_days <- 8
#   k <- 1
#   while(k <= nb_days){
#     model.date_forward <- model.date_forward + 1
# 
#     if(k > 3){ # après les 3 jours de marge on ne prend que les jours de semaineW
#       if(wday(model.date_forward, label=T, abbr=F) == "dimanche"){
#         nb_days <- nb_days + 1
#       }else if(wday(model.date_forward, label=T, abbr=F) == "samedi"){
#         nb_days <- nb_days + 2
#       }
#     }
# 
#     model.date_forward_chr <- paste(
#       year(model.date_forward),
#       if(str_count(as.character(month(model.date_forward))) == 1){ paste("0", month(model.date_forward), sep="")  }else{ month(model.date_forward) },
#       if(str_count(as.character(day(model.date_forward))) == 1){ paste("0", day(model.date_forward), sep="")  }else{ day(model.date_forward) },
#       sep=""
#     )
# 
#     model.date_forward_chr.ym <- paste(
#       year(model.date_forward),
#       if(str_count(as.character(month(model.date_forward))) == 1){ paste("0", month(model.date_forward), sep="")  }else{ month(model.date_forward) },
#       sep=""
#     )
# 
#     urlFileExist <- function(url){
#       HTTP_STATUS_OK <- 200
#       hd <- httr::HEAD(url)
#       status <- hd$all_headers[[1]]$status
#       list(exists = status == HTTP_STATUS_OK, status = status)
#     }
# 
#     file_exists <- urlFileExist(paste(paste(grid_004_0.5_degree_link, model.date_forward_chr.ym, sep="/"),
#                                       model.date_forward_chr,
#                                       glue("gfs_4_{model.date_forward_chr}_0000_000.grb2"),
#                                       sep="/"))
# 
#     if(file_exists$exists){
#       download.file(paste(paste(grid_004_0.5_degree_link, model.date_forward_chr.ym, sep="/"),
#                           model.date_forward_chr,
#                           glue("gfs_4_{model.date_forward_chr}_0000_000.grb2"),
#                           sep="/"),
#                     mode = "wb",
#                     destfile = glue("LISTES_EPISODES/LISTE{NUM_LISTE}/EP_{i}/APRES/gfs_4_{model.date_forward_chr}_0000_000.grb2")
#       )
#     }else{
#       download.file(paste(paste(historic_link, model.date_forward_chr.ym, sep="/"),
#                           model.date_forward_chr,
#                           glue("gfsanl_4_{model.date_forward_chr}_0000_000.grb2"),
#                           sep="/"),
#                     mode = "wb",
#                     destfile = glue("LISTES_EPISODES/LISTE{NUM_LISTE}/EP_{i}/APRES/gfsanl_4_{model.date_forward_chr}_0000_000.grb2")
#       )
#     }
#   k <- k + 1
# }


  # Téléchargement de la période pendant la propagation exceptionnelle
  model.date_inward <- date_debut
  dir.create(glue("LISTES_EPISODES/LISTE{NUM_LISTE}/EP_{i}/PENDANT/"))
  while(model.date_inward <= date_fin){

    model.date_inward_chr <- paste(
      year(model.date_inward),
      if(str_count(as.character(month(model.date_inward))) == 1){ paste("0", month(model.date_inward), sep="")  }else{ month(model.date_inward) },
      if(str_count(as.character(day(model.date_inward))) == 1){ paste("0", day(model.date_inward), sep="")  }else{ day(model.date_inward) },
      sep=""
    )

    model.date_inward_chr.ym <- paste(
      year(model.date_inward),
      if(str_count(as.character(month(model.date_inward))) == 1){ paste("0", month(model.date_inward), sep="")  }else{ month(model.date_inward) },
      sep=""
    )
    
    for(model_run_hour in c("0000", "0600", "1200", "1800")){
      
      for(hours_after in c("000", "003")){
        
        
        file_exists <- urlFileExist(paste(paste(grid_004_0.5_degree_link, model.date_inward_chr.ym, sep="/"),
                                          model.date_inward_chr,
                                          glue("gfs_4_{model.date_inward_chr}_{model_run_hour}_{hours_after}.grb2"),
                                          sep="/"))
        
        if(file_exists$exists){
          if(update | !file.exists(glue("LISTES_EPISODES/LISTE{NUM_LISTE}/EP_{i}/PENDANT/gfs_4_{model.date_inward_chr}_{model_run_hour}_{hours_after}.grb2"))){
            download.file(paste(paste(grid_004_0.5_degree_link, model.date_inward_chr.ym, sep="/"),
                                model.date_inward_chr,
                                glue("gfs_4_{model.date_inward_chr}_{model_run_hour}_{hours_after}.grb2"),
                                sep="/"),
                          mode = "wb",
                          destfile = glue("LISTES_EPISODES/LISTE{NUM_LISTE}/EP_{i}/PENDANT/gfs_4_{model.date_inward_chr}_{model_run_hour}_{hours_after}.grb2")
            ) 
          }
        }else{
          if(update | !file.exists(glue("LISTES_EPISODES/LISTE{NUM_LISTE}/EP_{i}/PENDANT/gfsanl_4_{model.date_inward_chr}_{model_run_hour}_{hours_after}.grb2"))){
            download.file(paste(paste(historic_link, model.date_inward_chr.ym, sep="/"),
                                model.date_inward_chr,
                                glue("gfsanl_4_{model.date_inward_chr}_{model_run_hour}_{hours_after}.grb2"),
                                sep="/"),
                          mode = "wb",
                          destfile = glue("LISTES_EPISODES/LISTE{NUM_LISTE}/EP_{i}/PENDANT/gfsanl_4_{model.date_inward_chr}_{model_run_hour}_{hours_after}.grb2")
            )
          }
        }     
        
      }
      
    }
    model.date_inward <- model.date_inward + 1
  }
}


