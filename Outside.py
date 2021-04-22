import csv

class Outside:
    #Outside Simple class to store outside temperatures and other data
    #   Reads data from cambridge_weather.csv to when initialized. Like the
    #   other classes, it stores an internal time step (t), and updates
    #   by dt whenever Outside.update(dt) is called. 
    #   Outside.T gives the air temperature at the current time stamp,
    #   Outside.T_sky gives sky temperature at current time stamp
    #   Outside.S gives solar radiation levels at current time stamp  
    def __init__(self,T, T_sky, S):
        self.T = T
        self.T_sky = T_sky
        self.S = S
        
    def Outside(self,t,S, T, T_sky):
        with open('cambridge_weather.csv', newline='') as csvfile:
            weather_data = list(csv.reader(csvfile))
        outside.S = lambda t: interp1(weather_data[:,1],weather_data[:,2],t)
        outside.T = lambda t: interp1(weather_data[:,1],CtoK(weather_data[:,3]),t)
        outside.T_sky = lambda t: interp1(weather_data[:,1],CtoK(weather_data[:,4]),t)


