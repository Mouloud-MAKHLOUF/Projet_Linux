import os
import pygrib
from matplotlib import pyplot as plt
from matplotlib import colors
import numpy as np
from mpl_toolkits.basemap import Basemap, addcyclic           
            
            
# Specify the directory path
directory = 'donnees_NOAA'
for filename in os.listdir(directory):
    # Check if the item is a file
    if os.path.isfile(os.path.join(directory, filename)):
        # Open the file
        grbs = pygrib.open(os.path.join(directory, filename))
        grbT = grbs.select(name='Temperature', level = 1000)[0]
        grbH = grbs.select(name="Relative humidity", level = 1000 )[0]
        grbVRD = grbs.select(name="V component of wind",level = 1000)[0]
        
        #On delimite une zone geographique pour extraite les prévision
        
        dataT, latsT, lonsT = grbT.data(lat1=36,lat2=36.75,lon1=2,lon2=4)
        #dataT.shape, latsT.min(), latsT.max(), lonsT.min(), lonsT.max()

        dataH, latsH, lonsH = grbH.data(lat1=36,lat2=36.75,lon1=2,lon2=4)
        #dataH.shape, latsH.min(), latsH.max(), lonsH.min(), lonsH.max()

        dataVRD, latsVRD, lonsVRD = grbVRD.data(lat1=36,lat2=36.75,lon1=2,lon2=4)
        #dataP.shape, latsP.min(), latsP.max(), lonsP.min(), lonsP.max()
        
        TensorNOAA = np.array([dataT, dataH, dataVRD])
        
        date = filename.split(".")[0]
        # Define the file path
        file_path = "usa/"+date+".npy"
        
        # Save the array to .npy file
        np.save(file_path, TensorNOAA)