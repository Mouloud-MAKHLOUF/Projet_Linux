import os
import pygrib
import numpy as np
           
def reshape_MF(arr):
    
    n1 = arr.shape[0]
    n2 = arr.shape[1]
    dim1 = arr.shape[0] // 2  # Integer division to get the floor of n
    dim2 = arr.shape[1] // 2  # Integer division to get the floor of n
    new_array =  np.zeros((dim1, dim2))
    n=0
    m=0    
    for i in range(0, n1, 2):
        for j in range(0,n2,2):
            mean = (arr[i][j]+arr[i+1][j]+arr[i][j+1]+arr[i+1][j+1])/4
            new_array[i//2][j//2] = mean

        
        

    return new_array           
            
# Specify the directory path
directory = "donnees_meteo_france"
for filename in os.listdir(directory):
    # Check if the item is a file
    if os.path.isfile(os.path.join(directory, filename)):
        # Open the file
        grbs = pygrib.open(os.path.join(directory, filename))
        grbT = grbs.select(name='Temperature', level = 1000)[0]
        grbH = grbs.select(name="Relative humidity", level = 1000 )[0]
        grbVRD = grbs.select(name="V component of wind",level = 1000)[0]
            
    
#On delimite une zone geographique pour extraite les prévision
        
dataT, latsT, lonsT = grbT.data(lat1=36,lat2=36.75,lon1=2,lon2=4.25)
#dataT.shape, latsT.min(), latsT.max(), lonsT.min(), lonsT.max()

dataH, latsH, lonsH = grbH.data(lat1=36,lat2=36.75,lon1=2,lon2=4.25)
#dataH.shape, latsH.min(), latsH.max(), lonsH.min(), lonsH.max()

dataVRD, latsVRD, lonsVRD = grbVRD.data(lat1=36,lat2=36.75,lon1=2,lon2= 4.25)
#dataP.shape, latsP.min(), latsP.max(), lonsP.min(), lonsP.max()


dataT = reshape_MF(dataT)
dataH = reshape_MF(dataH)
dataVRD = reshape_MF(dataVRD)

#print(dataT.shape)

TensorMF = np.array([dataT, dataH, dataVRD])

date = filename.split(".")[0]

# Define the file path
file_path = "france/"+date+".npy"
        
# Save the array to .npy file
np.save(file_path, TensorMF)