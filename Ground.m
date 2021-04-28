classdef Ground < handle
    %GROUND Simple class to store the ground temperature
    %   Reads data from cambridge_weather.csv to when initialized. Like the
    %   other classes, it stores an internal time step (t), and updates
    %   by dt whenever Ground.update(dt) is called. It has a property T
    %   which depends on the current time of the Ground object.
    properties 
        T
    end
    methods
        function g = Ground()
            weather_data = csvread('cambridge_weather.csv',1);
            g.T = @(t) interp1(weather_data(:,1),CtoK(weather_data(:,5)),t);
        end
    end 
end

