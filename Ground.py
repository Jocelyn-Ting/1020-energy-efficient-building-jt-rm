import csv

class Ground:
    #GROUND Simple class to store the ground temperature
    #   Reads data from cambridge_weather.csv to when initialized. Like the
    #   other classes, it stores an internal time step (t), and updates
    #   by dt whenever Ground.update(dt) is called. It has a property T
    #   which depends on the current time of the Ground object.   
    def __init__(self,T):
        self.T = T
        
    def Ground(self,t,T):
        with open('cambridge_weather.csv', newline='') as csvfile:
            weather_data = list(csv.reader(csvfile))
        g.T = lambda t: interp1(weather_data[:,1],CtoK(weather_data[:,5]),t)

