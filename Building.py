import numpy as np
from scipy import integrate
from Outside import Outside
from Ground import Ground
from Room import Room
from Heater import Heater
from Cooler import Cooler
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
        return [room.T for room in self.rooms]
        #^i bet this is where a bug will happen. not sure if will work
    
    def dTdt(self,t,T):
        dTdt = []
        #print(t)
        for roomidx in range(0,len(self.rooms)):
            room = self.rooms[roomidx]
            roomdTdt = room.dTdt(t,T)
            dTdt.append(roomdTdt)
        return dTdt

    def addRoom(self,ID,TRange,L,W):
        newRoom = Room(ID,TRange,L,W,self)
        self.rooms.append(newRoom)
    
    def addHeater(self,Trange,fMax,building):
        self.heater = Heater(Trange,fMax,building)
    
    def addCooler(self,Trange,fMax,building):
        self.cooler = Cooler(Trange,fMax,building)
    
    def addInteriorWall(self,room1ID,room2ID,A_w,R_eff):
        #Adds a wall between two rooms, with surface area of the wall
        #equal to A_w, and the effective resistance of the wall as
        #R_eff
        room1 = next((room for room in self.rooms if room.ID == room1ID),None)
        room2 = next((room for room in self.rooms if room.ID == room2ID),None)
        room1.addWall(room2,A_w,R_eff)
        room2.addWall(room1,A_w,R_eff)
    
    def addExteriorWall(self,roomID,A_w,R_eff):
        #Adds a wall separating outside from inside
        room = next((room for room in self.rooms if room.ID == roomID),None)
        room.addWall(self.outside,A_w,R_eff)
    
    def addRoof(self,roomID,A_r,R_eff):
        room = next((room for room in self.rooms if room.ID == roomID),None)
        room.addRoof(self.outside,A_r,R_eff)
    
    def addFloor(self,roomID,A_f,R_eff):
        room = next((room for room in self.rooms if room.ID == roomID),None)
        room.addFloor(self.ground,A_f,R_eff)
    

    
    


