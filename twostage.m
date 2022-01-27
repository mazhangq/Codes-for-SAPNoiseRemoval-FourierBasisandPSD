%%%%%%%%%%%%%%%%%%%%%%%%%%%
%two stage image denoising
%B_corrupted: noisy image
%mask: 1--clean pixels,0--corrupted pixels
%lambda: the regularization parameter
%recovery:the recovery image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function recovery=twostage(B_Corrupted,mask,lambda)
[height,width]=size(B_Corrupted);
f = double(B_Corrupted)/255;
P = [];
D=double(~mask);
recovery = tvinpaint(f,lambda,D,P);