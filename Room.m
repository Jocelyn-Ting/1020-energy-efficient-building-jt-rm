classdef Room < handle
    %ROOM class for thermodynamic simulation
    properties
        ID; % Numeric ID of the room
        T; % Current temperature
        T_range; % 'Acceptable' temperature range
        L; % Length (m)
        W; % Width (m)
        H=3; % Height (m)
        building; % the building object that this room belongs to
        walls; % List of structs: [otherside, area, R_eff]
        floor; % struct: [ground, area, R]
        roof; % struct: [outside, area, R]
        heater; % the heater object for the building
        cooler; % the AC object for the building
    end
    properties (Dependent)
        V; % Volume of the room
        SA; % Surface area of the room
    end
    properties (Constant)
        rho_air = 1.23; %kg m^-3
        cp_air = 1004; %J kg^-1 K^-1 
        cv_air = 717; %J kg^-1 K^-1
        a = 0.9; %absorptivity of room
        e = 0.9; %emissivity of room 
        sb = 5.67 * 10^-8; %stefan boltzmann constant
    end
    methods
        function r = Room(ID,T_range,L,W,building)
            r.ID = ID;
            r.T_range = T_range;
            r.L = L;
            r.W = W;
            r.building = building;
            r.heater = building.heater;
            r.cooler = building.cooler;
        end
        function dTdt = dTdt(obj,t,T) % Computers overall dTdt for the room
            dQdt_cc = obj.getCC(t,T); % Gets conductive/convective heat transfer amt
            dQdt_LW_rad = obj.getLWRadiation(t,T); % gets LW radiative heat transfer amount
            dQdt_SW_rad = obj.getSWRadiation(t); % gets SW radiative heat transfer amount
            dQdt_internal = obj.getInternal(t); % gets internal heat generation rate
            dQdt_heater = obj.getHeating(t,T); %gets the heating amount for this room
            dQdt_cooler = obj.getCooling(t,T); %gets the cooling amount for this room
            dTdt = (24*3600/(obj.rho_air * obj.cv_air * obj.V)) * ...
                (dQdt_cc + dQdt_LW_rad + dQdt_SW_rad + dQdt_internal ...
                + dQdt_heater + dQdt_cooler);
        end
        function dQdt_cc = getCC(obj,t,T)
            dQdt_cc = 0; 
            roomTemp = T(obj.ID);
            for wallidx = 1:length(obj.walls)
                wall = obj.walls(wallidx);
                if isa(wall.otherside,'Outside')
                    outsideT = wall.otherside.T(t);
                    dQdt_cc = dQdt_cc + (wall.area * (outsideT - roomTemp)/wall.R);
                elseif isa(wall.otherside,'Room')
                    otherRoomT = T(wall.otherside.ID);
                    dQdt_cc = dQdt_cc + (wall.area * (otherRoomT - roomTemp)/wall.R);
                end
            end
            dQdt_cc = dQdt_cc + obj.roof.area*(obj.roof.outside.T(t) - roomTemp)/obj.roof.R;
            dQdt_cc = dQdt_cc + obj.floor.area*(obj.floor.ground.T(t) - roomTemp)/obj.floor.R;
        end
        function dQdt_internal = getInternal(obj,t)
            if obj.ID == 7
                dQdt_internal = 5000;
            elseif (obj.ID == 3) && isWorkHours(t)
                dQdt_internal = 2000;
            else
                dQdt_internal = 0;
            end
        end
        function dQdt_LW_rad = getLWRadiation(obj,t,T)
            dQdt_LW_rad = 0;
            roomTemp = T(obj.ID);
            for wallidx = 1:length(obj.walls)
                wall = obj.walls(wallidx);
                if isa(wall.otherside,'Outside')
                    outside = wall.otherside;
                    dQdt_LW_rad = dQdt_LW_rad + wall.area*obj.sb*(-obj.e*(roomTemp^4) ...
                        + obj.a*(outside.T_sky(t)^4));
                elseif isa(wall.otherside,'Room')
                    otherRoom = wall.otherside;
                    otherRoomT = T(otherRoom.ID);
                    dQdt_LW_rad = dQdt_LW_rad + wall.area*obj.sb*(-obj.e*(roomTemp^4) ...
                        + obj.a*(otherRoomT^4));
                end
            end
            dQdt_LW_rad = dQdt_LW_rad +obj.roof.area*obj.sb*(-obj.e*(roomTemp^4)...
                + obj.a*(obj.roof.outside.T_sky(t)^4));
            dQdt_LW_rad = dQdt_LW_rad +obj.floor.area*obj.sb*(-obj.e*(roomTemp^4)...
                + obj.a*(obj.floor.ground.T(t)^4));
        end
        function dQdt_SW_rad = getSWRadiation(obj,t)
            dQdt_SW_rad = obj.roof.area*obj.a*obj.roof.outside.S(t);
        end
        function addWall(obj,otherside,A_wall,R_eff)
            newWall = struct('otherside',otherside,'area',A_wall,'R',R_eff);
            obj.walls = cat(1,obj.walls,newWall);
        end
        function addFloor(obj,ground,A_floor,R_eff)
            obj.floor = struct('ground',ground,'area',A_floor,'R',R_eff);
        end
        function addRoof(obj,outside,A_roof,R_eff)
            obj.roof = struct('outside',outside,'area',A_roof,'R',R_eff);
        end
        function dQdt_heater = getHeating(obj,t,T)
            % Gets the heater's output for time t, converts it
            % into units of energy/time
            roomTemp = T(obj.ID);
            [TH,fH] = obj.heater.getHeating(t,T);
            deltaT = TH - roomTemp;
            roomFlow = fH(obj.ID);
            dQdt_heater = obj.cp_air * obj.rho_air * roomFlow * deltaT;
        end
        function dQdt_cooler = getCooling(obj,t,T)
            roomTemp = T(obj.ID);
            [TC,fC] = obj.cooler.getCooling(t,T);
            deltaT = TC - roomTemp;
            roomFlow = fC(obj.ID);
            dQdt_cooler = obj.cp_air * obj.rho_air * roomFlow * deltaT;
        end
        function V = get.V(obj)
            % Computes volume of the room
            V = obj.L*obj.W*obj.H;
        end
        function SA = get.SA(obj)
            % Computes surface area of the room
            SA = sum([obj.walls.area]) + obj.floor.area + obj.roof.area;
        end
        
    end
    
end

