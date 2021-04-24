import numpy as np
class Cooler:
    #Cooler class models an AC with temperature set-pt and flows

    def __init__(self,Trange,fmax,building):
        # Creates the cooler object, initializes everything
        self.Trange = Trange #operating temperature range (K)
        self.fmax = fmax # maximum total flow rate (m^3/sec)
        self.building = building # the building that the cooler belongs to
        self.outside = building.outside # outside object
        self.ground = building.ground # ground object
        self.rho_air = 1.23 #kg m^-3
        self.cp_air = 1004 #kJ kg^-1 K^-1 
        self.cv_air = 717 #kJ kg^-1 K^-1
        
    def getCooling(self,t,T):
        # Input is a given timestamp t, and vector of room temperatures T
        # Output should be TC, the temperature setpoint for the cooler,
        # and fC, a vector of flows to each room. The sum of flows fC
        # should be less than self.fmax, and TC should fall within
        # Trange
        # To access the temperature of:
        #  - a given room: T(roomID)
        #  - outside air: self.outside.T(t)
        #  - sky: self.outside.T_sky(t)
        #  - ground: self.ground.T(t)
        TC = 5 # 5 is random. Replace w/ your control logic for setting TC
        fC = [0,0,0,0,0,0,0] # Replace w/ your control logic for setting flows
        assert TC <= max(self.Trange) and TC>=min(self.Trange,\
            'Temperature set point must fall within THrange') #checks that TC is in the proper range

        assert len(fC) == 7, 'flows must be equal to number of rooms (7)' #checks that fC is the right size
        
        assert sum(fC) < self.fmax, 'sum of flows exceeds maximum flow rate' #checks that flows are within max rate

        return [TC,fC]
    
    def power(self,t,T):
        [TC,fC] = self.getCooling(t,T)
        T_out = self.outside.T(t)
        efficiency = (TC/(T_out - TC))
        p = self.rho_air* self.cv_air * sum(fC) * (T_out - TC)/efficiency
        return p
    
