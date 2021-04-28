classdef Building < handle
    %BUILDING Models the thermodynamics of a building
    %   Includes a list of Room objects, Heater, and Cooler
    
    properties
        rooms; % List of room objects
        heater; % Heater object
        cooler; % Cooler object
        L;
        W;
        t; %Current time stamp (days)
        outside;
        ground;
    end
    properties (Dependent)
        T; % vector of temperature of each room at current time step
    end
    
    methods
        function b = Building(L,W)
            b.L = L;
            b.W = W;
            b.t = 1;
            b.rooms = [];
            b.outside = Outside();
            b.ground = Ground();
        end
        function dTdt = dTdt(obj,t,T)
            dTdt = zeros(7,1);
            for roomidx = 1:length(obj.rooms)
                room = obj.rooms(roomidx);
                dTdt(roomidx) = room.dTdt(t,T);
            end
        end
        function addRoom(obj,ID,TRange,L,W)
            newRoom = Room(ID,TRange,L,W,obj);
            obj.rooms = cat(1,obj.rooms,newRoom);
        end
        function addHeater(obj,Trange,fMax,building)
            obj.heater = Heater(Trange,fMax,building);
        end
        function addCooler(obj,Trange,fMax,building)
            obj.cooler = Cooler(Trange,fMax,building);
        end
        function addInteriorWall(obj,room1ID,room2ID,A_w,R_eff)
            %Adds a wall between two rooms, with surface area of the wall
            %equal to A_w, and the effective resistance of the wall as
            %R_eff
            room1 = obj.rooms([obj.rooms.ID] == room1ID);
            room2 = obj.rooms([obj.rooms.ID] == room2ID);
            room1.addWall(room2,A_w,R_eff);
            room2.addWall(room1,A_w,R_eff);
        end
        function addExteriorWall(obj,roomID,A_w,R_eff)
            %Adds a wall separating outside from inside
            room = obj.rooms([obj.rooms.ID]==roomID);
            room.addWall(obj.outside,A_w,R_eff);
        end
        function addRoof(obj,roomID,A_r,R_eff)
            room = obj.rooms([obj.rooms.ID]==roomID);
            room.addRoof(obj.outside,A_r,R_eff);
        end
        function addFloor(obj,roomID,A_f,R_eff)
            room = obj.rooms([obj.rooms.ID]==roomID);
            room.addFloor(obj.ground,A_f,R_eff);
        end
        function T = get.T(obj)
            T = [obj.rooms.T];
        end
    end
    
end

