%%---This program is designed to reconstruct signals
%%---G: a graph
%%---s: A matrix whose eachcolumn is a sampled signal
%%---Mask:A matrix the same size as s. A element is 1 
%%--       means known label, and 0 means unknown label
%%---beta: the regularization parameter
%%---w: the weight function, if default, reconstruct signal by GM
%%---ff: the reconstructed signals which is s matrix the same size as s

function [ff,S,U] = recon_alldatadrive(s,mask,x,xmask,beta,fun)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
%s=s+0.1*max(s(:))*(rand(size(s))-0.5).*mask;
S=cov(s');
[U,psd,r]=gsp_FB_estimate(S);


[N,Ns]=size(x);
E=eye(N);
idx=find(mask);
mc=sum(s(idx))/numel(idx); %calculate the mean
ff=[];
%--the maximum value of the weight function is 
%--standardized to $\lambda_{max}$
psd=psd/sum(psd);
w=fun(psd);
w=w/max(w);
KL=U*(repmat(w,1,N).*U');
for j=1:Ns
    labels=find(xmask(:,j));
    if isempty(labels)
        f=mc*ones(N,1);
    else
        lbs=numel(labels);
        Ek=diag(xmask(:,j));
        x1=x(:,j).* xmask(:,j);  
        V=Ek+beta*KL;
        f=inv(V)*x1;
    end
    ff=[ff,f];
end
end



