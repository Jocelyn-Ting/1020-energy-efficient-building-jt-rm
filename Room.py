class Room:
    #ROOM class for thermodynamic simulation

    def __init__(ID,T_range,L,W,building):
        #defining constants
        self.rho_air = 1.23 #kg m^-3
        self.cp_air = 1004 #J kg^-1 K^-1 
        self.cv_air = 717 #J kg^-1 K^-1
        self.a = 0.9 #absorptivity of room
        self.e = 0.9 #emissivity of room 
        self.sb = 5.67 * 10^-8 #stefan boltzmann constant

        self.ID = ID
        self.T_range = T_range
        self.L = L
        self.W = W
        self.building = building
        self.heater = building.heater
        self.cooler = building.cooler

#how to fit in these as well? do you have to say = undefined?
        self.T # Current temperature
        self.H=3 # Height (m)
        self.walls = [] # List of structs: [otherside, area, R_eff]
        self.floor # struct: [ground, area, R]
        self.roof # struct: [outside, area, R]

    @property
    def V(self):
        # Computes volume of the room
        V = self.L*self.W*self.H
    @property
    def SA(self):
        # Computes surface area of the room
        SA = sum([self.walls.area]) + self.floor.area + self.roof.area
        
    def dTdt(self,t,T): # Computers overall dTdt for the room
        dQdt_cc = self.getCC(t,T) # Gets conductive/convective heat transfer amt
        dQdt_LW_rad = self.getLWRadiation(t,T) # gets LW radiative heat transfer amount
        dQdt_SW_rad = self.getSWRadiation(t) # gets SW radiative heat transfer amount
        dQdt_internal = self.getInternal(t) # gets internal heat generation rate
        dQdt_heater = self.getHeating(t,T) #gets the heating amount for this room
        dQdt_cooler = self.getCooling(t,T) #gets the cooling amount for this room
        dTdt = (24*3600/(self.rho_air * self.cv_air * self.V)) * \
            (dQdt_cc + dQdt_LW_rad + dQdt_SW_rad + dQdt_internal \
            + dQdt_heater + dQdt_cooler)
        return dTdt

    def getCC(self,t,T):
        dQdt_cc = 0 
        roomTemp = T(self.ID)
        for wallidx in range(0,length(self.walls)):
            wall = self.walls(wallidx)
            if isinstance(wall.otherside,'Outside'): #need to replace isinstance function with pythonic fxn
                outsideT = wall.otherside.T(t)
                dQdt_cc = dQdt_cc + (wall.area * (outsideT - roomTemp)/wall.R)
            elif isinstance(wall.otherside,'Room'):
                otherRoomT = T(wall.otherside.ID)
                dQdt_cc = dQdt_cc + (wall.area * (otherRoomT - roomTemp)/wall.R)
            
        
        dQdt_cc = dQdt_cc + self.roof.area*(self.roof.outside.T(t) - roomTemp)/self.roof.R
        dQdt_cc = dQdt_cc + self.floor.area*(self.floor.ground.T(t) - roomTemp)/self.floor.R
        return dQdt_cc

    def getInternal(self,t):
        if self.ID == 7:
            dQdt_internal = 5000
        elif self.ID == 3 and isWorkHours(t):
            dQdt_internal = 2000
        else:
            dQdt_internal = 0
        return dQdt_internal
        
    
    def getLWRadiation(self,t,T):
        dQdt_LW_rad = 0
        roomTemp = T(self.ID)
        for wallidx in range(0,length(self.walls)):
            wall = self.walls(wallidx)
            if isinstance(wall.otherside,'Outside'):
                outside = wall.otherside
                dQdt_LW_rad = dQdt_LW_rad + wall.area*self.sb*(-self.e*(roomTemp**4) \
                    + self.a*(outside.T_sky(t)**4))
            elif isinstance(wall.otherside,'Room'):
                otherRoom = wall.otherside
                otherRoomT = T(otherRoom.ID)
                dQdt_LW_rad = dQdt_LW_rad + wall.area*self.sb*(-self.e*(roomTemp**4) \
                    + self.a*(otherRoomT**4))
        
        dQdt_LW_rad = dQdt_LW_rad +self.roof.area*self.sb*(-self.e*(roomTemp**4)\
            + self.a*(self.roof.outside.T_sky(t)**4))
        dQdt_LW_rad = dQdt_LW_rad +self.floor.area*self.sb*(-self.e*(roomTemp**4)\
            + self.a*(self.floor.ground.T(t)**4))
        return dQdt_LW_rad
    
    def getSWRadiation(self,t):
        dQdt_SW_rad = self.roof.area*self.a*self.roof.outside.S(t)
        return dQdt_SW_rad
    
    def addWall(self,otherside,A_wall,R_eff):
        newWall = {'otherside': otherside,'area':A_wall,'R':R_eff}
        self.walls = self.walls.append(newWall)
    
    def addFloor(self,ground,A_floor,R_eff):
        self.floor = {'ground':ground,'area':A_floor,'R':R_eff}
    
    def addRoof(self,outside,A_roof,R_eff):
        self.roof = {'outside':outside,'area':A_roof,'R':R_eff}
    
    def getHeating(self,t,T):
        # Gets the heater's output for time t, converts it
        # into units of energy/time
        roomTemp = T(self.ID)
        [TH,fH] = self.heater.getHeating(t,T)
        deltaT = TH - roomTemp
        roomFlow = fH(self.ID)
        dQdt_heater = self.cp_air * self.rho_air * roomFlow * deltaT
        return dQdt_heater
    
    def getCooling(self,t,T):
        roomTemp = T(self.ID)
        [TC,fC] = self.cooler.getCooling(t,T)
        deltaT = TC - roomTemp
        roomFlow = fC(self.ID)
        dQdt_cooler = self.cp_air * self.rho_air * roomFlow * deltaT
        return dQdt_cooler
    

    
    


