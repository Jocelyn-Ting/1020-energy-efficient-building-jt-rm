class Heater:
    # HEATER class models a heater with temperature set-pt and flows    
 
    def __init__(self, Trange,fmax,building):
        # Creates the cooler object, initializes everything
        self.Trange = Trange #operating temperature range (K)
        self.fmax = fmax # maximum total flow rate (m^3/sec)
        self.building = building # the building that the cooler belongs to
        self.outside = building.outside # outside object
        self.ground = building.ground # ground object
        self.rho_air = 1.23 #kg m^-3
        self.cp_air = 1004 #kJ kg^-1 K^-1 
        self.cv_air = 717 #kJ kg^-1 K^-1

    
    def getHeating(self,t,T):
        # Input is a given timestamp t, and vector of room temperatures T
        # Output should be TH, the temperature setpoint for the heater,
        # and fH, a vector of flows to each room. The sum of flows fH
        # should be less than self.fmax, and TH should fall within
        # Trange
        # To access the temperature of:
        #  - a given room: T(roomID)
        #  - outside air: self.outside.T(t)
        #  - sky: self.outside.T_sky(t)
        #  - ground: self.ground.T(t)
        TH = min(self.Trange) #Replace w/ your control logic for setting TH
        fH = [0,0,0,0,0,0,0] # Replace w/ your control logic for setting flows
        assert TH <= max(self.Trange) and TH >= min(self.Trange),\
            'Temperature set point must fall within THrange' #checks that TH is in the proper range

        assert len(fH) == 7, 'flows must be equal to number of rooms (7)' #checks that fH is the right size
        
        assert sum(fH) < self.fmax, 'sum of flows exceeds maximum flow rate' #checks that flows are within max rate

        return [TH,fH]
    
    def power(self,t,T):
        # Amount of power required to heat up air from external temp
        # (assume constant volume process, and 100# heating efficiency)
        [TH,fH] = self.getHeating(t,T)
        p = self.rho_air* self.cv_air * sum(fH) * (TH - T_out)
        return p
