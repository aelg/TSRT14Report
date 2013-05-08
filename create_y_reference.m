function y = create_y_reference(tphat)

yy = zeros(size(tphat, 1), 6);
for k = 1:size(tphat, 1)
    y = [];
    for l = 2:7,
        y = [y tphat(k, 1) - tphat(k,l)];
    end
    yy(k,:) = y;
end
y = sig(yy, 2);
end