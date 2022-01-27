function [V,psd,r]=gsp_FB_estimate(S)
N=size(S,1);
U = dctmtx(N)';
B=U(:,2:end);
BSB=B'*S*B;
[X,d] = eig(BSB);

V=[U(:,1),B*X];

psd=[sum(U(:,1).* sum(S.*repmat(U(:,1)',N,1),2));diag(d)];

r=norm(psd)/norm(S,'fro');