import os
import pygrib
import numpy as np
           
            
            
# Specify the directory path
directory = "donnees_canadienne"
for filename in os.listdir(directory):
    # Check if the item is a file
    if os.path.isfile(os.path.join(directory, filename)):
        # Open the file
        grbs = pygrib.open(os.path.join(directory, filename))
        nom_var = filename.split("_")[1].split(".")[0]
        if nom_var =="RH" :
            date = filename.split(".")[0].split("_")[0]
            grbH = grbs.select(name="Relative humidity", level = 1000 )[0]
            #print(grbH)
        elif nom_var =="TMP" :
            grbT = grbs.select(name='Temperature', level = 1000)[0]
        elif nom_var =="VGRD" :
            grbVRD = grbs.select(name="V component of wind",level = 1000)[0]
            
    
#On delimite une zone geographique pour extraite les prévision
        
dataT, latsT, lonsT = grbT.data(lat1=36,lat2=36.75,lon1=2,lon2=4)
#dataT.shape, latsT.min(), latsT.max(), lonsT.min(), lonsT.max()

dataH, latsH, lonsH = grbH.data(lat1=36,lat2=36.75,lon1=2,lon2=4)
#dataH.shape, latsH.min(), latsH.max(), lonsH.min(), lonsH.max()

dataVRD, latsVRD, lonsVRD = grbVRD.data(lat1=36,lat2=36.75,lon1=2,lon2=4)
#dataP.shape, latsP.min(), latsP.max(), lonsP.min(), lonsP.max()

TensorSGPD_canada = np.array([dataT, dataH, dataVRD])

# Define the file path
file_path = "canada/"+date+".npy"
        
# Save the array to .npy file
np.save(file_path, TensorSGPD_canada)