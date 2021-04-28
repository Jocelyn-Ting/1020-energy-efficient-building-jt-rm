classdef Outside < handle
    %Outside Simple class to store outside temperatures and other data
    %   Reads data from cambridge_weather.csv to when initialized. Like the
    %   other classes, it stores an internal time step (t), and updates
    %   by dt whenever Outside.update(dt) is called. 
    %   Outside.T gives the air temperature at the current time stamp,
    %   Outside.T_sky gives sky temperature at current time stamp
    %   Outside.S gives solar radiation levels at current time stamp
    
    properties
        T;
        T_sky;
        S;
    end
    
    methods
        function outside = Outside()
            % Constructor initializes the "outside" object with data
            weather_data = csvread('cambridge_weather.csv',1);
            outside.S = @(t) interp1(weather_data(:,1),weather_data(:,2),t);
            outside.T = @(t) interp1(weather_data(:,1),CtoK(weather_data(:,3)),t);
            outside.T_sky = @(t) interp1(weather_data(:,1),CtoK(weather_data(:,4)),t);
        end
    end
    
end

