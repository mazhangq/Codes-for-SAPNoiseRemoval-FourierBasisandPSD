%%%%%%%%%%%%%%%%%%%%%%%%%%%
%L0PDA image denoising
%B_corrupted: noisy image
%mask: 1--clean pixels,0--corrupted pixels
%lambda: the regularization parameter
%recovery:the recovery image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function recovery=L0TVPDA(B_Corrupted,mask,lambda)

B_Corrupted = B_Corrupted/255;

p = 2;
P = GenBlurOper;
LargestEig = min(sqrt(sum(abs(P(:))>0)*sum(P(:).*P(:))), sum(abs(P(:))));% Largest Eigenvalue of A'A

Amap = @(X)functionAX(P,X,'denoising');
Atmap = @(X)functionAX(P',X,'denoising');

acc = 1/255;

recovery = l0tv_proj_reg(B_Corrupted,mask,Amap,Atmap,p,lambda,LargestEig,acc);%,B_Clean);