% TSRT14 Lab1 Localisation
addpath(genpath('../sensormod'))
clear all;
close all;
%initcourse TSRT14;
load('matlab_calibrate.mat');
tphat = tphat(2:end,:)*340;

%% Sensor calibration

e_mat = tphat - [mean(tphat,2) mean(tphat,2) mean(tphat,2) mean(tphat,2) mean(tphat,2) mean(tphat,2) mean(tphat,2)];
e = e_mat(:);

mic_bias = [];
mic_var = [];
for k = (1:7),
    mic_bias = [mic_bias mean(e_mat(:,k))]; 
    mic_var = [mic_var var(e_mat(:,k))];
    pe = ndist(mean(e_mat(:,k)), var(e_mat(:,k)));
    [N, l] = hist(e_mat(:,k), 10);
    Wb = l(2) -l(1);
    Ny = length(e_mat(:,k));
end
bias_dm = mic_bias
std_dev_dm = sqrt(mic_var)

%% Create sensornetwork
load('test2.mat')
tphat = tphat(2:end,:)*300;
h = '[';
for i = 2:7,
    h = [h sprintf('sqrt((x(1,:)-th(1)).^2+(x(2,:)-th(2)).^2) - sqrt((x(1,:)-th(%d)).^2+(x(2,:)-th(%d)).^2);', i*2-1, i*2)];
end
h = [h ']'];
 
sm = sensormod(h, [2 0 6 14])

sm.th = [0 0 0 0.5 0 0.991 0.6 0.991 1.222 0.991 1.222 0.5 ...
    1.222 0];
sm.x0 = [0.5 0.5]';
sm.px0 = [1]*eye(2);
sm.pv = [0.05]*eye(2);
yy_var = [];
for l = 2:7,
    yy_var = [yy_var mic_var(l) + mic_var(1)];
end
sm.pe = repmat(yy_var, sm.nn(3), 1).*eye(sm.nn(3));
figure(1)
hold off
axis equal
%plot(sm)
sig_y = create_y_reference(tphat);

%% Particle filter CV
fs = 2;
f = '[1 0 1/2 0; 0 1 0 1/2; 0 0 1 0; 0 0 0 1]*x';
h = '[1 0 0 0; 0 1 0 0]*x';
nn = [4 0 2 0];

mCV = nl(f,h,nn,fs);

Q = [0.00000001 0 0 0; 0 0.00000001 0 0; 0 0 0.004 0; 0 0 0 0.004];
P0 = [0.1 0 0 0; 0 .1 0 0; 0 0 .1 0; 0 0 0 .1];

figure(1);
model = nl(sm);
model.f = inline(f, 't', 'x', 'u', 'th');
model.nn = [4 0 6 14];
model.x0 = [0.2 0.5 0 0.2];
model.px0 = P0;
model.pv = Q;
model.pe = repmat(yy_var, sm.nn(3), 1).*eye(sm.nn(3))*5;
xlabel = cell(1,4);
xlabel(1) = {'x1'};
xlabel(2) = {'x2'};
xlabel(3) = {'v1'};
xlabel(4) = {'v2'};
model.xlabel = xlabel;
model.fs = 2;
y.Py = model.pe;
y.Px = model.pv;
zhatCV = pf(model, sig_y,'Np', 10000);

%% Particle filter CA

f = '[1 0 .5 0 .25 0; 0 1 0 .5 0 .25; 0 0 1 0 .5 0; 0 0 0 1 0 .5; 0 0 0 0 1 0; 0 0 0 0 0 1]*x';
Q = [0.00000001 0 0 0 0 0;
     0 0.00000001 0 0 0 0; 
     0 0 0.00000001 0 0 0; 
     0 0 0 0.00000001 0 0;
     0 0 0 0 .0005 0;
     0 0 0 0 0 .0005];
P0 = eye(6)*0.1;
P0(5, 5) = 0.001;
P0(6, 6) = 0.001;

model = nl(sm);
model.f = inline(f, 't', 'x', 'u', 'th');
model.nn = [6 0 6 14];
model.x0 = [0.2 0.5 0 0.0 0 0];
model.px0 = P0;
model.pv = Q;
model.pe = repmat(yy_var, sm.nn(3), 1).*eye(sm.nn(3))*5;
model.fs = 2;

zhatCA = pf(model, sig_y,'Np', 10000, 'type', 'xplot2');
%%
figure(3);
load('artificial_measurments.mat');
plot(zhatCV.x(:,1), zhatCV.x(:,2), 'b-', zhatCA.x(:,1), zhatCA.x(:,2), 'r-', x(1,:), x(2,:), 'gx');
xlim([-0 1.2])
ylim([-0.1 1.0])
legend('Constant velocity', 'Constant acceleration', 'Localisation estimates')
%%

mic_pos = reshape(sm.th, 2, 7);
SFlabCompEstimGroundTruth(zhatCV.x(:,1:2)', mic_pos, 9);
legend('Constant velocity');
SFlabCompEstimGroundTruth(zhatCA.x(:,1:2)', mic_pos, 10);
legend('Constant acceleration');