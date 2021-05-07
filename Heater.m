classdef Heater < handle
    % HEATER class models a heater with temperature set-pt and flows
    properties 
        Trange %operating temperature range (K)
        fmax % maximum total flow rate (m^3/sec)
        outside % outside object
        ground % ground object
        building % the building that the cooler belongs to
    end
    properties (Constant)
        rho_air = 1.23; %kg m^-3
        cp_air = 1004; %kJ kg^-1 K^-1 
        cv_air = 717; %kJ kg^-1 K^-1
    end
    
    methods
        function h = Heater(Trange,fmax,building)
            % Creates the cooler object, initializes everything
            h.Trange = Trange;
            h.fmax = fmax;
            h.building = building;
            h.outside = building.outside;
            h.ground = building.ground;
        end
        function [TH,fH] = getHeating(obj,t,T)
            % Input is a given timestamp t, and vector of room temperatures T
            % Output should be TH, the temperature setpoint for the cooler,
            % and fH, a vector of flows to each room. The sum of flows fH
            % should be less than obj.fmax, and TH should fall within
            % Trange
            % To access the temperature of:
            %  - a given room: T(roomID)
            %  - outside air: obj.outside.T(t)
            %  - sky: obj.outside.T_sky(t)
            %  - ground: obj.ground.T(t)
            TH = max(obj.Trange); % Replace w/ your control logic for setting TH
            fH = obj.simpleHeatingFlows(T); % Replace w/ your control logic for setting flow

            if ~(TH <= max(obj.Trange) && TH>=min(obj.Trange)) %checks that TH is in the proper range
                error('Temperature set point must fall within THrange')
            end
            if numel(fH) ~= 7 %checks that fH is the right size
                error('flows must be equal to number of rooms (7)')
            end
            if sum(fH) > obj.fmax %checks that flows are within max rate
                sum(fH)
                error('sum of flows exceeds maximum flow rate')
            end
        end
        function simpleFlows = simpleHeatingFlows(obj,T)
            rooms=obj.building.rooms;
            TNeeded = mean(reshape([rooms.T_range],[2,7]))-T.';
            for i =1:7
                if TNeeded(i) <0
                    TNeeded(i)=0;
                end
            end
%             if sum(TNeeded)<.00001
%                 simpleFlows=zeros(1, 7);
%             else
                %simpleFlows = (obj.last_fH*.2+obj.fmax*TNeeded/sum(TNeeded)*.5);
                %TNeeded/sum(TNeeded)
            if sum(TNeeded)>=1
                simpleFlows = obj.fmax*TNeeded/sum(TNeeded)*.999;
            else
                 simpleFlows = obj.fmax*TNeeded;
%                 end
            end
        end
        function p = power(obj,t,T)
            % Amount of power required to heat up air from external temp
            % (assume constant volume process, and 100% heating efficiency)
            T_out = obj.outside.T(t);
            [TH,fH] = obj.getHeating(t,T);
            p = obj.rho_air* obj.cv_air * sum(fH) * (TH - T_out);
        end
    end
end