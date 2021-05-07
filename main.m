clear all;
close all;

%% Main function for Project 3
%% Creating the building
Tmin=[294,294,294,294,294,291,290];
Tmax=[300,300,300,300,300,305,295];
%add rooms, walls, roof, floor
building = addLayout(1);

%% Running simulation
tic
f = @(t,T) building.dTdt(t,T);
T0 = [295;295;295;295;295;295;295];
ODEOPTS = odeset('MaxStep',0.1);
[tRange,T] = ode15s(f,[1 10],T0,ODEOPTS);
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
