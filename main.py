import numpy as np
import scipy
from Building import *

#Main function for Project 3
#Some constants for your convenience
# Properties of air
rho_air = 1.23 #kg m^-3
cp_air = 1004 #kJ kg^-1 K^-1 
cv_air = 717 #kJ kg^-1 K^-1
# Stefan Boltzmann Const
sb = 5.67 * 10**-8 # W m^-2 K^-4
# Material properties (variable thickness)
RSI_brick = 1.5 #R value in SI units: [m K W^-1] (need to multiply by thickness to get total R)
RSI_concrete = 7.1
RSI_drywall = 6.02 
RSI_plywood = 8.75
RSI_foam = 27
RSI_fiberglass = 20

# Material properties (constant thickness)
RSI_asphalt_roof = 3.6 #R_eff value in SI units: [m^2 K W^-1]
RSI_wood_roof = 7.0
RSI_hardwood_floor = 4
RSI_carpet_floor = 15
RSI_tile_floor = 2.5
RSI_1p_glass = 6.5 # single-paned glass
RSI_2p_glass = 14
RSI_wood_door = 14
RSI_glass_door = 4.5
RSI_steel_door = 35

# Building Materials (Mark's addition)
RSI_interior_wall = .1*RSI_drywall+.2*RSI_fiberglass
RSI_exterior_wall = .05*RSI_drywall+.3*RSI_fiberglass+.15*RSI_concrete
RSI_roofing = 0.05*RSI_drywall+0.3*RSI_fiberglass+RSI_wood_roof

# inline function for parallel Reff
r_par = lambda A,R: 1/(sum(np.divide(np.array(A),np.array(R)))/sum(np.array(A))) #note: A and R must be np arrays
## Creating the building
L = 17 #length of building, replace w/ your own value
W = 13 #width of building
Tmin=[294,294,294,294,294,291,290]
Tmax=[300,300,300,300,300,305,295]
building = Building(L,W)
TH_range = [300,320]
fH_max = 4
building.addHeater(TH_range,fH_max,building)
TC_range = [285,295]
fC_max = 2
building.addCooler(TC_range,fC_max,building)


## Add rooms
# use building.addRoom(roomID,TRange,roomL,roomW)
building.addRoom(0,[294,300],6,5)
building.addRoom(1,[294,300],5,7)
building.addRoom(2,[294,300],8,8)
building.addRoom(3,[294,300],5,6)
building.addRoom(4,[294,300],6,5)
building.addRoom(5,[291,305],4,4)
building.addRoom(6,[290,295],4,4)

## Add walls, roof, floor
#Add interior walls (between 2 rooms) using: building.addInteriorWall(Room1ID,Room2ID,area,R_eff)
building.addInteriorWall(0,2,18,r_par([2,16],[RSI_wood_door,RSI_interior_wall]))
building.addInteriorWall(1,2,6,r_par([2,4],[RSI_wood_door,RSI_interior_wall]))
building.addInteriorWall(3,2,18,r_par([2,16],[RSI_glass_door,RSI_interior_wall]))
building.addInteriorWall(4,2,6,r_par([2,4],[RSI_wood_door,RSI_interior_wall]))
building.addInteriorWall(5,2,12,r_par([2,10],[RSI_wood_door,RSI_interior_wall]))
building.addInteriorWall(6,2,12,r_par([2,10],[RSI_wood_door,RSI_interior_wall]))
building.addInteriorWall(1,3,15,RSI_interior_wall)
building.addInteriorWall(1,0,15,RSI_interior_wall)
building.addInteriorWall(0,4,15,RSI_interior_wall)
building.addInteriorWall(4,5,12,RSI_interior_wall)
building.addInteriorWall(5,6,12,RSI_interior_wall)

#Add exterior walls (between room and outside) using: building.addExteriorWall(RoomID,area,R_eff)
building.addExteriorWall(0,18,r_par([2,4,12],[RSI_glass_door, RSI_2p_glass, RSI_exterior_wall]))
building.addExteriorWall(1,15,r_par([2,13],[RSI_2p_glass,RSI_exterior_wall]))
building.addExteriorWall(1,21,r_par([2,19],[RSI_2p_glass,RSI_exterior_wall]))
building.addExteriorWall(2,24,r_par([4,2,18],[RSI_2p_glass,RSI_glass_door,RSI_exterior_wall]))
building.addExteriorWall(3,18,r_par([2,16],[RSI_2p_glass,RSI_exterior_wall]))
building.addExteriorWall(3,15,r_par([2,13],[RSI_2p_glass,RSI_exterior_wall]))
building.addExteriorWall(4,18,RSI_exterior_wall)
building.addExteriorWall(4,15,RSI_exterior_wall)
building.addExteriorWall(5,12,r_par([2,10],[RSI_glass_door,RSI_exterior_wall]))
building.addExteriorWall(6,12,RSI_exterior_wall)
building.addExteriorWall(6,12,RSI_exterior_wall)

#add floor with: building.addFloor(RoomID,area,R_eff)
building.addFloor(0,30,RSI_carpet_floor)
building.addFloor(1,35,RSI_carpet_floor)
building.addFloor(2,64,RSI_carpet_floor)
building.addFloor(3,30,RSI_carpet_floor)
building.addFloor(4,30,RSI_carpet_floor)
building.addFloor(5,16,RSI_carpet_floor)
building.addFloor(6,16,RSI_carpet_floor)

#add roof with: building.addRoof(roomID,area,R_eff)
building.addRoof(0,30,RSI_roofing)
building.addRoof(1,35,RSI_roofing)
building.addRoof(2,64,RSI_roofing)
building.addRoof(3,30,RSI_roofing)
building.addRoof(4,30,RSI_roofing)
building.addRoof(5,16,RSI_roofing)
building.addRoof(6,16,RSI_roofing)

## Running simulation
import time
tic = time.time()
f = lambda t,T: building.dTdt(t,T)
T0 = [295,295,295,295,295,295,295]
# ODEOPTS = odeset('MaxStep',0.1)
# [tRange,T] = ode15s(f,[1 10],T0,ODEOPTS)
# ^def the hardest part to convert to python. 
# vode, method =bdf, order=15 was suggested here: https://stackoverflow.com/questions/2088473/integrate-stiff-odes-with-python
ode15s = scipy.integrate.ode(f)
ode15s.set_integrator('vode',method = "bdf", max_step=0.1,order=15)
ode15s.set_initial_value(T0,1) #sets initial T value and starts at time=1
tRange=[1]
T=[T0]

# from documentation here: https://docs.scipy.org/doc/scipy/reference/generated/scipy.integrate.ode.html
while ode15s.successful() and ode15s.t<=5:
    T.append(ode15s.integrate(ode15s.t+.1))
    tRange.append(ode15s.t+.1)
    print(ode15s.t)

print(tRange)

# trying this https://stackoverflow.com/questions/8741003/how-to-solve-a-stiff-ode-with-python
# solution = scipy.integrate.solve_ivp(f, [1, 2],T0, method='BDF', first_step =0.1, max_step=.1, dense_output=True)
# tRange = solution.t.tolist()
# T=solution.y.tolist()

toc = time.time()-tic
print("simulation finished in " +str(toc)+ "seconds")

## Plotting
#plotting inspo : https://matplotlib.org/devdocs/gallery/lines_bars_and_markers/cohere.html#sphx-glr-gallery-lines-bars-and-markers-cohere-py
import matplotlib.pyplot as plt

plot0 = plt.figure(0)

fig1,ax1=plt.subplots(3)
# ax1[0].plot(tRange,T)
for i in range(len(T)):
    ax1[0].plot(tRange,T[i])
ax1[0].set_ylabel('T (K)')
ax1[0].legend(['Room 1','Room 2','Room 3','Room 4','Room 5','Room 6','Room 7'])
ax1[1].plot(tRange,building.outside.T(tRange))
ax1[1].plot(tRange,building.outside.T_sky(tRange))
ax1[1].plot(tRange,building.ground.T(tRange))
ax1[1].legend(['T_air','T_sky','T_ground'])
ax1[1].set_ylabel('T (K)')
ax1[2].set_xlabel('time (days)')
ax1[2].plot(tRange,building.outside.S(tRange))
ax1[2].set_ylabel('Solar Radiance (W/m^2)')
# ax1[3].plot(tRange,building.heater.power_used)
# ax1[3].set_xlabel('time (days)')
# ax1[3].set_ylabel('Energy usage rate (kW)')

plot1 = plt.figure(1)
fig2,ax2=plt.subplots(7)

for ii in range(0,7):
    # ax2[ii].plot(tRange,[temps[ii] for temps in T])
    ax2[ii].plot(tRange,T[ii])
    ax2[ii].plot(tRange,Tmin[ii]*np.ones(len(tRange)))
    ax2[ii].plot(tRange,Tmax[ii]*np.ones(len(tRange)))
    ax2[ii].legend(['Temp room '+str(ii), 'min', 'max'])

plt.show()

# use r_par function to calculate Reff for walls
# reff13 = r_par([2,16],[RSI_wood_door,RSI_interior_wall])
# reff23 = r_par([2,4],[RSI_wood_door,RSI_interior_wall])
# reff43 = r_par([2,16],[RSI_glass_door,RSI_interior_wall])
# reff53 = r_par([2,4],[RSI_wood_door,RSI_interior_wall])
# reff63 = r_par([2,10],[RSI_wood_door,RSI_interior_wall])
# reff73 = r_par([2,10],[RSI_wood_door,RSI_interior_wall])
# 
# reff1E = r_par([2,4,12],[RSI_glass_door, RSI_2p_glass, RSI_exterior_wall])
# reff2Ea = r_par([2,13],[RSI_2p_glass,RSI_exterior_wall])
# reff2Eb = r_par([2,19],[RSI_2p_glass,RSI_exterior_wall])
# reff3E = r_par([4,2,18],[RSI_2p_glass,RSI_glass_door,RSI_exterior_wall])
# reff4Ea = r_par([2,16],[RSI_2p_glass,RSI_exterior_wall])
# reff4Eb = r_par([2,13],[RSI_2p_glass,RSI_exterior_wall])
# reff6E = r_par([2,10],[RSI_glass_door,RSI_exterior_wall])
