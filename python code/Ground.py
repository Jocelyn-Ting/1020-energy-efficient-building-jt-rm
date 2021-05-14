import pandas as pd
import numpy as np
from CtoK import CtoK
class Ground:
    #GROUND Simple class to store the ground temperature
    #   Reads data from cambridge_weather.csv to when initialized. Like the
    #   other classes, it stores an internal time step (t), and updates
    #   by dt whenever Ground.update(dt) is called. It has a property T
    #   which depends on the current time of the Ground object.   
    def __init__(self):
        self.weather_data = pd.read_csv('cambridge_weather.csv')

    def T(self,t):
        T=np.interp(t,self.weather_data.iloc[:,0],CtoK(self.weather_data.iloc[:,4]))
        return T
