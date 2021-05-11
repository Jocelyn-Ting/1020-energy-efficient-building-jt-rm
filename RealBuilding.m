classdef RealBuilding < handle
    %realBuilding stores real occupancy data
    %occupancy will be applied to cubicles (room 3)
    properties
        occupancy; %either 0 or greater than 0
    end
    
    methods
        function realBuilding = RealBuilding()
            % Constructor initializes the "realBuilding" object with data
            load('first_year_LANGEVIN_DATA.mat','first_year_building_data');
            %raw building data starts on jul30 - rearrange to start on jan 1
            building_data = cat(1,first_year_building_data(14881:end,:),first_year_building_data(1:14880,:));
            realBuilding.occupancy = building_data(:,3);
        end
        function occupied = getOccupancy(obj,t)
            occupied = 1==obj.occupancy(floor((t-1)*96)+1);
        end
    end
    
end