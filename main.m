clear all;
close all;

%% Main function for Project 3
% Some constants for your convenience
% Properties of air
rho_air = 1.23; %kg m^-3
cp_air = 1004; %kJ kg^-1 K^-1 
cv_air = 717; %kJ kg^-1 K^-1
% Stefan Boltzmann Const
sb = 5.67 * 10^-8; % W m^-2 K^-4
% Material properties (variable thickness)
RSI_brick = 1.5; %R value in SI units: [m K W^-1] (need to multiply by thickness to get total R)
RSI_concrete = 7.1;
RSI_drywall = 6.02; 
RSI_plywood = 8.75;
RSI_foam = 27;
RSI_fiberglass = 20;

% Material properties (constant thickness)
RSI_asphalt_roof = 3.6; %R_eff value in SI units: [m^2 K W^-1]
RSI_wood_roof = 7.0;
RSI_hardwood_floor = 4;
RSI_carpet_floor = 15;
RSI_tile_floor = 2.5;
RSI_1p_glass = 6.5; % single-paned glass
RSI_2p_glass = 14;
RSI_wood_door = 14;
RSI_glass_door = 4.5;
RSI_steel_door = 35;

% Building Materials (Mark's addition)
RSI_interior_wall = .1*RSI_drywall+.2*RSI_fiberglass;
RSI_exterior_wall = .05*RSI_drywall+.3*RSI_fiberglass+.15*RSI_concrete;
RSI_roofing = 0.05*RSI_drywall+0.3*RSI_fiberglass+RSI_wood_roof;

% inline function for parallel Reff
r_par = @(A,R) 1/(sum(A./R)/sum(A));
%% Creating the building
L = 17; %length of building, replace w/ your own value
W = 13; %width of building
Tmin=[294,294,294,294,294,291,290];
Tmax=[300,300,300,300,300,305,295];
building = Building(L,W);
TH_range = [300,320];
fH_max = 4;
building.addHeater(TH_range,fH_max,building)
TC_range = [285,295];
fC_max = 2;
building.addCooler(TC_range,fC_max,building)


%% Add rooms
% use building.addRoom(roomID,TRange,roomL,roomW)
building.addRoom(1,[294,300],6,5)
building.addRoom(2,[294,300],5,7)
building.addRoom(3,[294,300],8,8)
building.addRoom(4,[294,300],5,6)
building.addRoom(5,[294,300],6,5)
building.addRoom(6,[291,305],4,4)
building.addRoom(7,[290,295],4,4)

%% Add walls, roof, floor
%Add interior walls (between 2 rooms) using: building.addInteriorWall(Room1ID,Room2ID,area,R_eff)
building.addInteriorWall(1,3,18,r_par([2,16],[RSI_wood_door,RSI_interior_wall]));
building.addInteriorWall(2,3,6,r_par([2,4],[RSI_wood_door,RSI_interior_wall]));
building.addInteriorWall(4,3,18,r_par([2,16],[RSI_glass_door,RSI_interior_wall]));
building.addInteriorWall(5,3,6,r_par([2,4],[RSI_wood_door,RSI_interior_wall]));
building.addInteriorWall(6,3,12,r_par([2,10],[RSI_wood_door,RSI_interior_wall]));
building.addInteriorWall(7,3,12,r_par([2,10],[RSI_wood_door,RSI_interior_wall]));
building.addInteriorWall(2,4,15,RSI_interior_wall);
building.addInteriorWall(2,1,15,RSI_interior_wall);
building.addInteriorWall(1,5,15,RSI_interior_wall);
building.addInteriorWall(5,6,12,RSI_interior_wall);
building.addInteriorWall(6,7,12,RSI_interior_wall);

%Add exterior walls (between room and outside) using: building.addExteriorWall(RoomID,area,R_eff)
building.addExteriorWall(1,18,r_par([2,4,12],[RSI_glass_door, RSI_2p_glass, RSI_exterior_wall]));
building.addExteriorWall(2,15,r_par([2,13],[RSI_2p_glass,RSI_exterior_wall]));
building.addExteriorWall(2,21,r_par([2,19],[RSI_2p_glass,RSI_exterior_wall]));
building.addExteriorWall(3,24,r_par([4,2,18],[RSI_2p_glass,RSI_glass_door,RSI_exterior_wall]));
building.addExteriorWall(4,18,r_par([2,16],[RSI_2p_glass,RSI_exterior_wall]));
building.addExteriorWall(4,15,r_par([2,13],[RSI_2p_glass,RSI_exterior_wall]));
building.addExteriorWall(5,18,RSI_exterior_wall);
building.addExteriorWall(5,15,RSI_exterior_wall);
building.addExteriorWall(6,12,r_par([2,10],[RSI_glass_door,RSI_exterior_wall]));
building.addExteriorWall(7,12,RSI_exterior_wall);
building.addExteriorWall(7,12,RSI_exterior_wall);

%add floor with: building.addFloor(RoomID,area,R_eff)
building.addFloor(1,30,RSI_carpet_floor)
building.addFloor(2,35,RSI_carpet_floor)
building.addFloor(3,64,RSI_carpet_floor)
building.addFloor(4,30,RSI_carpet_floor)
building.addFloor(5,30,RSI_carpet_floor)
building.addFloor(6,16,RSI_carpet_floor)
building.addFloor(7,16,RSI_carpet_floor)

%add roof with: building.addRoof(roomID,area,R_eff)
building.addRoof(1,30,RSI_roofing);
building.addRoof(2,35,RSI_roofing);
building.addRoof(3,64,RSI_roofing);
building.addRoof(4,30,RSI_roofing);
building.addRoof(5,30,RSI_roofing);
building.addRoof(6,16,RSI_roofing);
building.addRoof(7,16,RSI_roofing);

%% Running simulation
tic
f = @(t,T) building.dTdt(t,T);
T0 = [295;295;295;295;295;295;295];
ODEOPTS = odeset('MaxStep',0.1);
[tRange,T] = ode15s(f,[1 365],T0,ODEOPTS);
% If you are running into difficulties with ode15s getting stuck, try
% using, which uses a different solution algorithm, but it runs slower
%[tRange,T] = ode23s(f,[1 10],T0,ODEOPTS);
toc

%% Plotting
disp(tRange)
figure(1);
subplot(3,1,1)
plot(tRange,T)
ylabel('T (K)')
legend('Room 1','Room 2','Room 3','Room 4','Room 5','Room 6','Room 7')
subplot(3,1,2)
plot(tRange,building.outside.T(tRange))
hold on;
plot(tRange,building.outside.T_sky(tRange))
plot(tRange,building.ground.T(tRange))
legend('T_{air}','T_{sky}','T_{ground}')
ylabel('T (K)')
subplot(3,1,3)
xlabel('time (days)')
plot(tRange,building.outside.S(tRange))
ylabel('Solar Radiance (W/m^2)')

figure(2)

for ii = 1:7
    subplot(7,1,ii)
    plot(tRange,T(:,ii)')
    hold on;
    plot(tRange,Tmin(ii)*ones(size(tRange)))
    hold on;
    plot(tRange,Tmax(ii)*ones(size(tRange)))
    legend(strcat('Temp room ', num2str(ii)), 'min', 'max')
end

% use r_par function to calculate Reff for walls
% reff13 = r_par([2,16],[RSI_wood_door,RSI_interior_wall])
% reff23 = r_par([2,4],[RSI_wood_door,RSI_interior_wall])
% reff43 = r_par([2,16],[RSI_glass_door,RSI_interior_wall])
% reff53 = r_par([2,4],[RSI_wood_door,RSI_interior_wall])
% reff63 = r_par([2,10],[RSI_wood_door,RSI_interior_wall])
% reff73 = r_par([2,10],[RSI_wood_door,RSI_interior_wall])
% 
% reff1E = r_par([2,4,12],[RSI_glass_door, RSI_2p_glass, RSI_exterior_wall])
% reff2Ea = r_par([2,13],[RSI_2p_glass,RSI_exterior_wall])
% reff2Eb = r_par([2,19],[RSI_2p_glass,RSI_exterior_wall])
% reff3E = r_par([4,2,18],[RSI_2p_glass,RSI_glass_door,RSI_exterior_wall])
% reff4Ea = r_par([2,16],[RSI_2p_glass,RSI_exterior_wall])
% reff4Eb = r_par([2,13],[RSI_2p_glass,RSI_exterior_wall])
% reff6E = r_par([2,10],[RSI_glass_door,RSI_exterior_wall])
