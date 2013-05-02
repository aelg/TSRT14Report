function [ output_args ] = NLS_using_GN(sm,y,tphat)
%NLS_USING_GN Summary of this function goes here
%   Detailed explanation goes here

tphat = tphat*340;
bias = abs(mean(tphat(1,:))-mean(tphat(2,:)));
sm.x0(3) = bias;
FS = 2;
tphat = tphat;
for i = 1:length(y.y)-1
    y_k = sig(tphat(i,:),FS);
    xhat = nls(sm, y_k, 'thmask',zeros(1,sm.nn(4)));
    disp(i)
    pos(:,i)=xhat.x0(1:2);
    sm.x0=[xhat.x0(1:2); xhat.x0(3)+bias];
    display(xhat.x0)
end

SFlabCompEstimGroundTruth(pos,[0 0; 0 0.5; 0 0.991; 0.6 0.991; 1.222 0.991; 1.222 0.5; 1.222 0]');
end
