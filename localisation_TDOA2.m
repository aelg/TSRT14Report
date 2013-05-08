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

    %{
    figure(k)
    hold off;
    bar(l, N/(Ny*Wb));
    hold on
    plot(pe);
    %}
end
bias_dm = mic_bias
std_dev_dm = sqrt(mic_var)


%% Create sensornetwork
%load('matlab_spread.mat')
load('test2.mat')
tphat = tphat(2:end,:)*300;
sm = exsensor('tdoa2', 7, 1, 2);
%sm.th = [0.2 0 0.4 0 0.6 0 0 0 0 0.2 0 0.4 0 0.6]';
sm.th = [0 0 0 0.5 0 0.991 0.6 0.991 1.222 0.991 1.222 0.5 ...
    1.222 0];
sm.x0 = [0.5 0.5]';
sm.px0 = [1]*eye(2);
sm.pv = [0.05]*eye(2);
yy_var = [];
for k = 1:6,
    for l = k+1:7,
        yy_var = [yy_var mic_var(l) + mic_var(k)];
    end
end
sm.pe = repmat(yy_var, sm.nn(3), 1).*eye(sm.nn(3));
figure(1)
hold off
axis equal
plot(sm)
sig_y = create_y_tdoa2(tphat);
%% CRLB
[cx X1 X2] = crlb2(sm, [], (-0.2:0.05:0.99)', (-0.2:0.05:1.3)')
%%
hold off
plot(sm)
hold on
crlb2(sm, [], (-0.2:0.05:1.3)', (-0.2:0.05:1.0)');
%contour(X1, X2, cx);
%colorbar
xlim([0 1.3])
ylim([0 1])
xlabel('x1 [m]')
ylabel('x2 [m]')
title('CRLB TDOA2 MSRE')
%%
[x, x_cov] = estimate_pos(sm, tphat, 1:size(tphat, 1));
%%
figure(2);
plot(x(1,:), x(2,:))

