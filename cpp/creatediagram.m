%% Create diagram out of test runs
clear all;
close all;

% Net with tanh and d/dx tanh
tanh_orig1 = csvread('tanh_orig1.csv');
tanh_orig2 = csvread('tanh_orig2.csv');
tanh_orig3 = csvread('tanh_orig3.csv');

figure;
hold on;
grid on;
plot(tanh_orig1(:,1),tanh_orig1(:,2), 'black-');
plot(tanh_orig2(:,1),tanh_orig2(:,2), 'r--');
plot(tanh_orig3(:,1),tanh_orig3(:,2), 'b-.');
legend('Run 1', 'Run 2', 'Run 3');
xlabel('Iteration');
ylabel('\Delta RMS');

% Net with aproximation of tanh and 1/(1+x*x)
tanh_hw1 = csvread('tanh_hw1.csv');
tanh_hw2 = csvread('tanh_hw2.csv');
tanh_hw3 = csvread('tanh_hw3.csv');

figure;
hold on;
grid on;
plot(tanh_hw1(:,1),tanh_hw1(:,2), 'black-');
plot(tanh_hw2(:,1),tanh_hw2(:,2), 'r--');
plot(tanh_hw3(:,1),tanh_hw3(:,2), 'b-.');
legend('Run 1', 'Run 2', 'Run 3');
xlabel('Iteration');
ylabel('\Delta RMS');

% Net with aproximation of tanh, 1/(1+x*x) and using the error for weight
% update
tanh_etaback1 = csvread('tanh_etaback1.csv');
tanh_etaback2 = csvread('tanh_etaback2.csv');
tanh_etaback3 = csvread('tanh_etaback3.csv');

figure;
hold on;
grid on;
plot(tanh_etaback1(:,1),tanh_etaback1(:,2), 'black-');
plot(tanh_etaback2(:,1),tanh_etaback2(:,2), 'r--');
plot(tanh_etaback3(:,1),tanh_etaback3(:,2), 'b-.');
legend('Run 1', 'Run 2', 'Run 3');
xlabel('Iteration');
ylabel('\Delta RMS');