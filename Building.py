import numpy as np
class Building:
    #BUILDING Models the thermodynamics of a building
    #   Includes a list of Room objects, Heater, and Cooler
    
    def __init__(self,L,W):
        self.rooms=[] # List of room objects
        self.heater=None # Heater object
        self.cooler=None # Cooler object
        self.L =L
        self.W=W
        self.t =1 #Current time stamp (days)
        self.outside = Outside()
        self.ground = Ground()
        #self.T # vector of temperature of each room at current time step

    @property
    def T(self):
        return [self.rooms.T]
        #^i bet this is where a bug will happen. not sure if will work
    
    def dTdt(self,t,T):
        dTdt = np.zeros(7,0)
        for roomidx in range(0,length(self.rooms)):
            room = self.rooms[roomidx]
            dTdt[roomidx] = room.dTdt(self.t,self.T)
        return dTdt

    def addRoom(self,ID,TRange,L,W):
        newRoom = Room(ID,TRange,L,W,obj)
        self.rooms = np.concatenate((self.rooms,newRoom), axis=0)
    
    def addHeater(self,Trange,fMax,building):
        self.heater = Heater(Trange,fMax,building)
    
    def addCooler(self,Trange,fMax,building):
        self.cooler = Cooler(Trange,fMax,building)
    
    def addInteriorWall(self,room1ID,room2ID,A_w,R_eff):
        #Adds a wall between two rooms, with surface area of the wall
        #equal to A_w, and the effective resistance of the wall as
        #R_eff
        room1 = self.rooms([self.rooms.ID] == room1ID)
        room2 = self.rooms([self.rooms.ID] == room2ID)
        room1.addWall(room2,A_w,R_eff)
        room2.addWall(room1,A_w,R_eff)
    
    def addExteriorWall(self,roomID,A_w,R_eff):
        #Adds a wall separating outside from inside
        room = self.rooms([self.rooms.ID]==roomID)
        room.addWall(self.outside,A_w,R_eff)
    
    def addRoof(self,roomID,A_r,R_eff):
        room = self.rooms([self.rooms.ID]==roomID)
        room.addRoof(self.outside,A_r,R_eff)
    
    def addFloor(self,roomID,A_f,R_eff):
        room = self.rooms([self.rooms.ID]==roomID)
        room.addFloor(self.ground,A_f,R_eff)
    

    
    


