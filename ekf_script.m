load('artificial_measurments.mat') % loads the variable x
%% Constant velocity

fs = 2;
f = '[1 0 1/2 0; 0 1 0 1/2; 0 0 1 0; 0 0 0 1]*x';
h = '[1 0 0 0; 0 1 0 0]*x';
nn = [4 0 2 0];

mCV = nl(f,h,nn,fs);

y = sig(x',fs);
Q = [0 0 0 0; 0 0 0 0; 0 0 0.004 0; 0 0 0 0.004];
P0 = [1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1];

x_CV = my_EKF(mCV, y, x_cov, Q, P0);


%% Constant acceleration

fs = 2;
f = '[1 0 .5 0 .25 0; 0 1 0 .5 0 .25; 0 0 1 0 .5 0; 0 0 0 1 0 .5; 0 0 0 0 1 0; 0 0 0 0 0 1]*x';
h = '[1 0 0 0 0 0; 0 1 0 0 0 0]*x';
nn = [6 0 2 0];

mCA = nl(f,h,nn,fs);

y = sig(x',fs);
Q = [0 0 0 0 0 0;
     0 0 0 0 0 0; 
     0 0 0 0 0 0; 
     0 0 0 0 0 0;
     0 0 0 0 .01 0;
     0 0 0 0 0 .01];
P0 = eye(6);

x_CA = my_EKF(mCA, y, x_cov, Q, P0);

%%
mic_pos = reshape([0 0 0 0.5 0 0.991 0.6 0.991 1.222 0.991 1.222 0.5 ...
    1.222 0], 2,7);
figure(1)
plot(x_CV(1,:), x_CV(2,:), 'b-', x_CA(1,:), x_CA(2,:), 'r-', x(1,:), x(2,:), 'gx')
legend('Constant velocity', 'Constant acceleration', 'Measurements')
SFlabCompEstimGroundTruth(x_CV(1:2,:), mic_pos, 9);
legend('Constant velocity');
%%
SFlabCompEstimGroundTruth(x_CA(1:2,:), mic_pos, 10);
legend('Constant acceleration');