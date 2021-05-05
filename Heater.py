import numpy as np
from scipy.optimize import linprog

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
        TH = max(self.Trange) #Replace w/ your control logic for setting TH
        #fH = [0,0,0,0,0,0,0]
        fH = self.optHeatingFlows(t,T,.1) # Replace w/ your control logic for setting flows
        #print(fH)
        assert TH <= max(self.Trange) and TH >= min(self.Trange),\
            'Temperature set point must fall within THrange' #checks that TH is in the proper range

        assert len(fH) == 7, 'flows must be equal to number of rooms (7)' #checks that fH is the right size
        
        assert sum(fH) < self.fmax, 'sum of flows exceeds maximum flow rate' #checks that flows are within max rate

        return [TH,fH]
    
    def power(self,t,TH,fH):
        # Amount of power required to heat up air from external temp
        # (assume constant volume process, and 100# heating efficiency)
        T_out = self.outside.T(t)
        p = self.rho_air* self.cv_air * sum(fH) * (TH - T_out)
        return p
    # def extDT(self,t,T,roomidx,dt):
    #     room = self.building.rooms[roomidx]
    #     dQdt_cc = room.getCC(t,T) # Gets conductive/convective heat transfer amt
    #     dQdt_LW_rad = room.getLWRadiation(t,T) # gets LW radiative heat transfer amount
    #     dQdt_SW_rad = room.getSWRadiation(t) # gets SW radiative heat transfer amount
    #     dQdt_internal = room.getInternal(t) # gets internal heat generation rate
    #     dTdt = (24*3600/(room.rho_air*room.cv_air*room.V))*(dQdt_cc + dQdt_LW_rad + dQdt_SW_rad + dQdt_internal)
    #     return dTdt*dt
        
    def simpleHeatingFlows(self,T):
        rooms=self.building.rooms
        TNeeded = np.array([(room.T_range[0]+room.T_range[1])/2 for room in rooms])-np.array(T)
        for i in range(0,len(TNeeded)):
            if TNeeded[i] <0:
                TNeeded[i]=0
        flows = self.fmax*TNeeded/sum(TNeeded)*.999
        print(flows)
        return flows

    def extDT(self,t,T,roomidx,dt):
        room = self.building.rooms[roomidx]
        dQdt_cc = room.getCC(t,T) # Gets conductive/convective heat transfer amt
        dQdt_LW_rad = room.getLWRadiation(t,T) # gets LW radiative heat transfer amount
        dQdt_SW_rad = room.getSWRadiation(t) # gets SW radiative heat transfer amount
        dQdt_internal = room.getInternal(t) # gets internal heat generation rate
        dTdt = (24*3600/(room.rho_air*room.cv_air*room.V))*(dQdt_cc + dQdt_LW_rad + dQdt_SW_rad + dQdt_internal)
        return dTdt*dt
    def optHeatingFlows(self,t,T,dt):
                #issue: don't actually know what dt is for the numerical solver. i guessed .01?
        rooms=self.building.rooms
        TH = max(self.Trange)
        c=[1,1,1,1,1,1,1] #fH sum is to be minimized
        dT = lambda i : 3600*24*dt*self.cp_air*(TH-T[i])/(self.cv_air*rooms[i].V)
        dTs = np.identity(7)*[dT(i) for i in range(7)]
        dTs_doubled = [[dT, -dT] for dT in dTs]
        dTs_doubled_flattened = [item for sublist in dTs_doubled for item in sublist]
        A=np.concatenate(([[1,1,1,1,1,1,1]],dTs_doubled_flattened))
        Tranges = np.array([room.T_range for room in rooms])
        ineqs = [[max(Tranges[i])-(T[i]+self.extDT(t,T,i,dt)), (T[i]+self.extDT(t,T,i,dt)) - min(Tranges[i])] for i in range(len(Tranges))]
        flat_ineqs = [item for sublist in ineqs for item in sublist]
        b=[self.fmax]
        b.extend(flat_ineqs)
        res = linprog(c, A_ub=A, b_ub=b)
        #print(res.x)
        return res.x

    def power(self,t,TH,fH):
        # Amount of power required to heat up air from external temp
        # (assume constant volume process, and 100# heating efficiency)
        T_out = self.outside.T(t)
        p = self.rho_air* self.cv_air * sum(fH) * (TH - T_out)
        return p
