import pandas as pd
import numpy as np
from CtoK import CtoK

class Outside:
    #Outside Simple class to store outside temperatures and other data
    #   Reads data from cambridge_weather.csv to when initialized. Like the
    #   other classes, it stores an internal time step (t), and updates
    #   by dt whenever Outside.update(dt) is called. 
    #   Outside.T gives the air temperature at the current time stamp,
    #   Outside.T_sky gives sky temperature at current time stamp
    #   Outside.S gives solar radiation levels at current time stamp  
    def __init__(self):
        self.weather_data = pd.read_csv('cambridge_weather.csv')
         
    def S(self,t):
        return np.interp(t, self.weather_data.iloc[:,0],self.weather_data.iloc[:,1])
    def T(self,t):
        return np.interp(t, self.weather_data.iloc[:,0],CtoK(self.weather_data.iloc[:,2]))
    def T_sky(self,t):   
        return np.interp(t, self.weather_data.iloc[:,0],CtoK(self.weather_data.iloc[:,3]))


