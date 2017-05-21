%% Display results of Hardware-Simulation
close all;
clear all;

real_fixedeta = csvread('vhdl-real-fixedeta.csv');
real_rmseta = csvread('vhdl-real-rmseta.csv');
sfixed_fixedeta = csvread('vhdl-sfixed-fixedeta.csv');
sfixed_rmseta = csvread('vhdl-sfixed-rmseta.csv');

figure;
hold on;
grid on;
plot(real_fixedeta(:,1),real_fixedeta(:,2), 'r-.');
plot(sfixed_fixedeta(:,1),sfixed_fixedeta(:,2), 'black-');
plot(real_rmseta(:,1),real_rmseta(:,2), 'r-.');
plot(sfixed_rmseta(:,1),sfixed_rmseta(:,2), 'black-');
legend('Real', 'Sfixed');
xlabel('Iteration');
ylabel('\Delta RMS');