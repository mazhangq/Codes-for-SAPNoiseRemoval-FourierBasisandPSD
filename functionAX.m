function [R] = functionAX(A,X,type)
if(strcmp(type,'denoising'))
    R = X;
elseif(strcmp(type,'deblurring'))
    R= conv2padded(X,A);
else
    error('unknown type');
end
