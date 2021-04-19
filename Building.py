class Building
    #BUILDING Models the thermodynamics of a building
    #   Includes a list of Room objects, Heater, and Cooler
    
    def _init_(self,L,W):
        self.rooms=[] # List of room objects
        self.heater # Heater object
        self.cooler # Cooler object
        self.L =L
        self.W=W
        self.t =1 #Current time stamp (days)
        self.outside = Outside()
        self.ground = Ground()
        self.T # vector of temperature of each room at current time step

    def dTdt(self,obj,t,T):
        dTdt = zeros(7,1)
        for roomidx in range(1:length(obj.rooms))
            room = obj.rooms(roomidx)
            dTdt(roomidx) = room.dTdt(self.t,self.T)

    def addRoom(obj,ID,TRange,L,W):
        newRoom = Room(ID,TRange,L,W,obj)
        obj.rooms = cat(1,obj.rooms,newRoom)
        #^will need to change cat to python. maybe np.concatenate?
    
    def addHeater(obj,Trange,fMax,building):
        obj.heater = Heater(Trange,fMax,building)
    
    def addCooler(obj,Trange,fMax,building):
        obj.cooler = Cooler(Trange,fMax,building)
    
    def addInteriorWall(obj,room1ID,room2ID,A_w,R_eff):
        #Adds a wall between two rooms, with surface area of the wall
        #equal to A_w, and the effective resistance of the wall as
        #R_eff
        room1 = obj.rooms([obj.rooms.ID] == room1ID)
        room2 = obj.rooms([obj.rooms.ID] == room2ID)
        room1.addWall(room2,A_w,R_eff)
        room2.addWall(room1,A_w,R_eff)
    
    def addExteriorWall(obj,roomID,A_w,R_eff):
        #Adds a wall separating outside from inside
        room = obj.rooms([obj.rooms.ID]==roomID)
        room.addWall(obj.outside,A_w,R_eff)
    
    def addRoof(obj,roomID,A_r,R_eff):
        room = obj.rooms([obj.rooms.ID]==roomID)
        room.addRoof(obj.outside,A_r,R_eff)
    
    def addFloor(obj,roomID,A_f,R_eff):
        room = obj.rooms([obj.rooms.ID]==roomID)
        room.addFloor(obj.ground,A_f,R_eff)
    
    def T = get.T(obj)
        T = [obj.rooms.T]
        #^need to convert this to python
    
    
    


