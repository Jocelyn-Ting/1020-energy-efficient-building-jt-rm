function building = addLayout(layoutNum)
    %%
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
    RSI_interior_wall = .2*RSI_concrete+.1*RSI_fiberglass;
    RSI_exterior_wall = .2*RSI_concrete+.3*RSI_fiberglass+.3*RSI_concrete;
    RSI_roofing = 0.1*RSI_concrete+0.3*RSI_fiberglass+RSI_asphalt_roof;

    % inline function for parallel Reff
    r_par = @(A,R) 1/(sum(A./R)/sum(A));
    %%
    %layout 1 - minimize cost. the insulation is so bad you need the max
    %flows from both the heater and cooler
    if layoutNum == 1
        L = 22; %length of building, replace w/ your own value
        W = 15; %width of building
        building = Building(L,W);
        TH_range = [300,320];
        fH_max = 4;
        building.addHeater(TH_range,fH_max,building)
        TC_range = [285,295];
        fC_max = 4;
        building.addCooler(TC_range,fC_max,building)
        %% Add rooms
        % use building.addRoom(roomID,TRange,roomL,roomW)
        building.addRoom(1,[294,300],8,5)
        building.addRoom(2,[294,300],8,5)
        building.addRoom(3,[294,300],12,10)
        building.addRoom(4,[294,300],6,10)
        building.addRoom(5,[294,300],6,5)
        building.addRoom(6,[291,305],4,4)
        building.addRoom(7,[290,295],4,6)

        %% Add walls, roof, floor
        %Add interior walls (between 2 rooms) using: building.addInteriorWall(Room1ID,Room2ID,area,R_eff)
        building.addInteriorWall(1,2,15,RSI_interior_wall);
        building.addInteriorWall(1,3,24,r_par([2,22],[RSI_wood_door,RSI_interior_wall]));
        building.addInteriorWall(2,3,6,r_par([2,4],[RSI_wood_door,RSI_interior_wall]));
        building.addInteriorWall(2,4,18,r_par([2,16],[RSI_wood_door,RSI_interior_wall]));
        building.addInteriorWall(4,3,30,r_par([4,26],[RSI_wood_door,RSI_interior_wall]));
        building.addInteriorWall(5,1,15,r_par([2,13],[RSI_wood_door,RSI_interior_wall]));
        building.addInteriorWall(5,3,6,r_par([2,4],[RSI_wood_door,RSI_interior_wall]));
        building.addInteriorWall(6,3,12,r_par([2,10],[RSI_wood_door,RSI_interior_wall]));
        building.addInteriorWall(7,3,18,r_par([2,16],[RSI_wood_door,RSI_interior_wall]));


        %Add exterior walls (between room and outside) using: building.addExteriorWall(RoomID,area,R_eff)
        building.addExteriorWall(1,24,r_par([4,8,12],[RSI_wood_door, RSI_1p_glass, RSI_exterior_wall]));
        building.addExteriorWall(2,39,r_par([12,27],[RSI_1p_glass,RSI_exterior_wall]));
        building.addExteriorWall(3,36,r_par([16,20],[RSI_1p_glass,RSI_exterior_wall]));
        building.addExteriorWall(4,48,r_par([2,14,32],[RSI_wood_door, RSI_1p_glass, RSI_exterior_wall]));
        building.addExteriorWall(5,33,RSI_exterior_wall);
        building.addExteriorWall(6,24,r_par([2,22],[RSI_wood_door,RSI_exterior_wall]));
        building.addExteriorWall(7,18,RSI_exterior_wall);


        %add floor with: building.addFloor(RoomID,area,R_eff)
        building.addFloor(1,40,RSI_tile_floor)
        building.addFloor(2,40,RSI_tile_floor)
        building.addFloor(3,120,RSI_tile_floor)
        building.addFloor(4,60,RSI_tile_floor)
        building.addFloor(5,30,RSI_tile_floor)
        building.addFloor(6,16,RSI_tile_floor)
        building.addFloor(7,24,RSI_tile_floor)

        %add roof with: building.addRoof(roomID,area,R_eff)
        building.addRoof(1,40,RSI_roofing);
        building.addRoof(2,40,RSI_roofing);
        building.addRoof(3,120,RSI_roofing);
        building.addRoof(4,60,RSI_roofing);
        building.addRoof(5,30,RSI_roofing);
        building.addRoof(6,16,RSI_roofing);
        building.addRoof(7,24,RSI_roofing);
    end
end