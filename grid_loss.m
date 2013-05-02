load('test2.mat')
%load('matlab_spread.mat')
close all
tphat = tphat(2:end,:)*340;

yy_var = [];
for k = 1:6,
    for l = k+1:7,
        yy_var = [yy_var mic_var(l) + mic_var(k)];
    end
end

y = [];
for m = 1:size(tphat, 1)
    yy = [];
    for k = 1:6,
        for l = k+1:7,
            yy = [yy tphat(m, k) - tphat(m,l)];
        end
    end
    y = [y; yy];
end

sm = exsensor('tdoa2', 7, 1, 2);

scale = 1;
%sm.th = [.2 0 .4 0 .6 0 0 0 0 .2 0 .4 0 .6]'*scale;
sm.th = [0 0 0 0.5 0 0.991 0.6 0.991 1.222 0.991 1.222 0.5 ...
    1.222 0];
sm.x0 = [.38 .1]'*scale;
sm.pe = zeros(sm.nn(3));
%sm.pe = repmat(yy_var, sm.nn(3), 1).*eye(sm.nn(3));

grid = 1:1:20;
grid_pos = (grid-5)*0.1;
V = zeros(length(grid), length(grid));
R = repmat(yy_var, sm.nn(3), 1).*eye(sm.nn(3));
%R = eye(sm.nn(3));
one_y = sig(y(10,:));
%{
for x1 = grid,
    for x2 = grid,
        sm.x0 = [grid_pos(x1); grid_pos(x2)];
        h_x = simulate(sm, 1);
        a = (one_y - h_x);
        V(x1, x2) = a.y*inv(R)*a.y';
    end
end
%}

%%{
sm.pe = R;
for x1 = grid,
    for x2 = grid,
        sm.x0 = [grid_pos(x1); grid_pos(x2)];
        cramer = crlb(sm);
        V(x1, x2) = sqrt(trace([cramer.Px(:,:,1); cramer.Px(:,:,2)]'));
        %h_x = simulate(sm, 1);
        %y = simulate(sm, 1);
        %a = (y - h_x);
        %[xhat, shat] = ls(sm, y);
        %V(x1, x2) = sqrt(trace([xhat.Px(:,:,1); xhat.Px(:,:,2)]'));
    end
end
%%}
%%
figure(2)
%V(1, 10) = 1000000;
contour(grid_pos, grid_pos, V', 10)
colorbar
[x1_min, Ix1] = min(V, [], 1);
[dummy, Ix2] = min(x1_min);
%%
grid_pos(Ix1(Ix2))
grid_pos(Ix2)