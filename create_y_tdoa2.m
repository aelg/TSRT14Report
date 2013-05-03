function y = create_y_tdoa2(tphat)

nn = factorial(size(tphat, 2))/(2*factorial(size(tphat, 2)-2));

yy = zeros(size(tphat, 1), nn);
for m = 1:size(tphat, 1)
    y = [];
    for k = 1:6,
        for l = k+1:7,
            y = [y tphat(m, k) - tphat(m,l)];
        end
    end
    yy(m,:) = y;
end
y = sig(yy, 2);
end