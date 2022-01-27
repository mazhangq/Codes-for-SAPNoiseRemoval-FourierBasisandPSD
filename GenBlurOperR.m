function [P] = GenBlurOperR(R)
[x,y] = meshgrid(-R:R,-R:R);
K = double(x.^2 + y.^2 <= R^2);
P = K/sum(K(:));



