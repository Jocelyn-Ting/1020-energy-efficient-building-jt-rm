clear all;
close all;

%% Main function for Project 3
%% Creating the building
Tmin=[294,294,294,294,294,291,290];
Tmax=[300,300,300,300,300,305,295];
%add rooms, walls, roof, floor
%specify building layout scenario
building = addLayout(4);

%% Running simulation
tic
f = @(t,T) building.dTdt(t,T);
% T0 = [295;295;295;295;295;295;295];
T0 = [298;298;298;298;298;298;298]; %to test starting in summer
ODEOPTS = odeset('MaxStep',0.1);
[tRange,T] = ode15s(f,[1 365],T0,ODEOPTS);
% If you are running into difficulties with ode15s getting stuck, try
% using, which uses a different solution algorithm, but it runs slower
%[tRange,T] = ode23s(f,[1 10],T0,ODEOPTS);
toc

%% Plotting
coolerPowerkW = zeros(1,size(T,1));
heaterPowerkW = zeros(1,size(T,1));
for i = 1:size(T,1)
    coolerPowerkW(i)=building.cooler.power(tRange(i),T(i,:).')/1000;
    heaterPowerkW(i)=building.heater.power(tRange(i),T(i,:).')/1000;
end
%kWh requires multiplying by 24 bc the time stamps are in days
coolerEnergy = num2str(trapz(tRange*24,coolerPowerkW),'%e'); 
heaterEnergy = num2str(trapz(tRange*24,heaterPowerkW),'%e');

%occupancy
givenOccupancy = zeros(1,size(T,1));
realOccupancy = zeros(1,size(T,1));
for i = 1:size(T,1)
    givenOccupancy(i) = isWorkHours(tRange(i));
end

disp(tRange)
figure(1);
subplot(5,1,1)
plot(tRange,T)
title('Layout 1 real occupancy')
ylabel('T (K)')
legend('Room 1','Room 2','Room 3','Room 4','Room 5','Room 6','Room 7')
subplot(5,1,2)
plot(tRange,building.outside.T(tRange))
hold on;
plot(tRange,building.outside.T_sky(tRange))
plot(tRange,building.ground.T(tRange))
legend('T_{air}','T_{sky}','T_{ground}')
ylabel('T (K)')
subplot(5,1,3)
plot(tRange,building.outside.S(tRange))
ylabel('Solar Radiance (W/m^2)')
subplot(5,1,4)
yyaxis left
plot(tRange, coolerPowerkW)
ylabel('Energy Usage (W)')
yyaxis right
plot(tRange, heaterPowerkW)
legend('cooler','heater')
title(strcat('Total yearly energy (kWh) : cooler = ',coolerEnergy,' heater = ',heaterEnergy));
subplot(5,1,5)
xlabel('time (days)')
plot(tRange,givenOccupancy)
hold on
% plot(([1:(tRange(end)-1)*96+1]-1)/96+1, building.realBuilding.occupancy(1:(tRange(end)-1)*96+1))
plot(([1:size(building.realBuilding.occupancy,1)]-1)/96+1, building.realBuilding.occupancy)
legend('given','real')
ylabel('occupancy')

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
save('layout1_realOccupancy_5.14.21','tRange','T')
