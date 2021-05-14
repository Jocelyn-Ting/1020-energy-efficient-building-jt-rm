classdef Cooler < handle
    % Cooler class models an AC with temperature set-pt and flows
    properties 
        Trange %operating temperature range (K)
        fmax % maximum flow rate (m^3/sec)
        outside % outside object
        ground % ground object
        building % the building that the cooler belongs to
        tBack
        intBack
    end
    properties (Constant)
        % Properties of air
        rho_air = 1.23; %kg m^-3
        cp_air = 1004; %J kg^-1 K^-1 
        cv_air = 717; %J kg^-1 K^-1
    end
    
    methods
        function h = Cooler(Trange,fmax,building)
            % Creates the cooler object, initializes everything
            h.Trange = Trange;
            h.fmax = fmax;
            h.building = building;
            h.outside = building.outside;
            h.ground = building.ground;
            h.tBack=zeros(5,1);
            h.intBack=zeros(5,7);
        end
        function [TC,fC] = getCooling(obj,t,T)
            % Input is a given timestamp t, and vector of room temperatures T
            % Output should be TC, the temperature setpoint for the cooler,
            % and fC, a vector of flows to each room. The sum of flows fC
            % should be less than obj.fmax, and TC should fall within
            % Trange
            % To access the temperature of:
            %  - a given room: T(roomID)
            %  - outside air: obj.outside.T(t)
            %  - sky: obj.outside.T_sky(t)
            %  - ground: obj.ground.T(t)
            TC = min(obj.Trange); % Replace w/ your control logic for setting TC
%             fC = [0,0,0,0,0,0,0]; % Replace w/ your control logic for setting flows
            fC = obj.simpleCoolingFlows(T);
            %fC = obj.advancedCoolingFlows(t,T);
%             obj.power_array(end+1) = obj.power(TC,fC,t);
%             obj.time_array(end+1) = t;
            if ~(TC <= max(obj.Trange) && TC>=min(obj.Trange)) %checks that TC is in the proper range
                error('Temperature set point must fall within TCrange')
            end
            if numel(fC) ~= 7 %checks that fC is the right size
                error('flows must be equal to number of rooms (7)')
            end
            if sum(fC) > obj.fmax %checks that flows are within max rate
                error('sum of flows exceeds maximum flow rate')
            end
        end
        function simpleFlows = simpleCoolingFlows(obj,T)
            rooms=obj.building.rooms;
            TNeeded = mean(reshape([rooms.T_range],[2,7]))-T.';
            for i =1:7
                if TNeeded(i) >0
                    TNeeded(i)=0;
                end
            end
                if -sum(TNeeded)>=2
                    simpleFlows = obj.fmax*TNeeded/sum(TNeeded)*.999;
                else
                     simpleFlows = -obj.fmax*TNeeded/2;
                end
        end
        function advancedFlows = advancedCoolingFlows(obj,t,T)
            rooms=obj.building.rooms;
            TNeeded = T.'-mean(reshape([rooms.T_range],[2,7]))+2;
            if t>=obj.tBack(1)+.0005
                obj.tBack=circshift(obj.tBack,1);
                obj.tBack(1)=t;
                obj.intBack=circshift(obj.intBack,1,1);
                obj.intBack(1,:)=TNeeded;
            end
            for i =1:7
                integral = trapz(flip(obj.tBack),flip(obj.intBack(:,i)));
                lastTemp=obj.intBack(2);
                lastTime=obj.tBack(2);
                if(t-lastTime)<1e-5 ||(t-lastTime)<0
                    dTdt=0;
                else
                    dTdt=(T(i)-lastTemp)/(t-lastTime);
                end
                TNeeded(i)=1*TNeeded(i)+integral*4+dTdt/9e6;
                if TNeeded(i) <0
                    TNeeded(i)=0;
                end
            end
            if sum(TNeeded)>=3
                advancedFlows = obj.fmax*TNeeded/sum(TNeeded)*.999;
            else
                advancedFlows = obj.fmax*TNeeded/3;
            end    
        end
        function minFlows = minCoolingFlows(obj,T)
            rooms=obj.building.rooms;
            Tranges = reshape([rooms.T_range],[2,7]);
            TNeeded = Tranges(2,:)-T.'-1;
            for i =1:7
                if TNeeded(i) >0
                    TNeeded(i)=0;
                end
            end
                if -sum(TNeeded)>=3
                    minFlows = obj.fmax*TNeeded/sum(TNeeded)*.999;
                else
                     minFlows = -obj.fmax*TNeeded/3;
                end
        end
        function p = power(obj,t,T)
            [TC,fC] = obj.getCooling(t,T);
            T_out = obj.outside.T(t);
            efficiency = (TC/(T_out - TC));
            p = obj.rho_air * obj.cv_air * sum(fC) * (T_out-TC)/efficiency;
        end
        
    end
end