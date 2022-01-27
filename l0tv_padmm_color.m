function [U] = l0tv_padmm_color(B,O,Kmap,Ktmap,p,lambda,LargestEig,acc,penalty_ratio)%,B_Clean)
% This program solves the following optimization problem:
% min_{0<=u<=1}  lambda || Dxu Dyu ||_{p,1} + ||o.*(Ku-b)||_0
% where K is a linear operator.

% Input parameters:
% B: m x n, the corrupted image
% O: m x n, prior information, \in {0,1}
% Kmap,Ktmap: the linear operator and its adjoint operator
% p: p = 1 (anisotropic) or p = 2 (isotropic)
% lambda: the regularization parameter
% LargestEig: the square of largest singular value of the linear operator
% acc: accuracy of the optimization problem, acc = 1/255
% B_Clean: the original clean image

% Output parameter:
% U: recovered image


% We solve the OP by PADMM:
% min_{u,v} lambda sum_c=1^3 || Dxu Dyu ||_{p,1} + sum_c=1^3 <e,e-v>,  s.t. <o.*|Au-b|,v> = 0
% min_{u,v,r,s,z} sum_c=1^3 lambda || r s ||_{p,1} + sum_c=1^3 <e,e-v>, s.t. <o.*|z|,v> = 0, Au-b = z, Dxu = r, Dyu = s
% L(u,v,r,s,z) =  sum_c=1^3 lambda || r s ||_{p,1}  + sum_c=1^3 <e,e-v>
%                                  + <piz, Au-b-z> + 0.5 alpha |Au-b-z|_2^2
%                                  + <pir, Dxu-r> + 0.5 beta |Dxu-r|_2^2
%                                  + <pis, Dyu-s> + 0.5 beta |Dyu-s|_2^2,
%                                  + <piv, o.*|z|.*v> + 0.5 rho |o.*|z|.*v|_2^2

sizeB = size(B);
B = double(B);

% primal variables
U = B;
V = ones(sizeB);
dx = difX(U);
dy = difY(U);
% dual variables (multipliers)
piz = 1e-3*randn(sizeB);
pir = 1e-3*randn(sizeB);
pis = 1e-3*randn(sizeB);
pio = 1e-3*randn(sizeB);

% parameters
gamma = 1;
gamma = 0.5*(1+sqrt(5)); %  golden ratio
alpha = 0.1;
beta  = 0.1;
rho   = 0.1;



% snrs =[];
% his=[];
Kub = Kmap(U) - B;
for iter = 1:1e3,
    
    % Update Z
    VO = V.*O;
    cof_A = rho * V.*VO + alpha;
    cof_B = - piz - alpha * Kub;
    cof_C = pio.*VO;
    Z=threadholding_l1_w(cof_B./cof_A,cof_C./cof_A);
    
    % Update RS
    [R,S]=threadholding_RS(- pir/beta - dx,- pis/beta - dy,lambda,beta,p);
    
    % Update U
    g1 = Ktmap(piz) + alpha*Ktmap(Kub-Z);
    g3 = divX(-pir+beta*R)  - beta*divX(dx);
    g4 = divY(-pis+beta*S ) - beta*divY(dy);
    gradU =     g1 + g3 + g4;
    Lip = beta*4 + beta * 4 + alpha * LargestEig;
    U   = boxproj(U - gradU/Lip);
    
    dx  = difX(U);    dy  = difY(U);    Kub = Kmap(U) - B;
    % Update {dx,dy,Kub} whenever U has changed
    
    % Update V
    ZO = Z.*O;
    absZO = abs(ZO);
    cof_A = rho * Z.*ZO;
    cof_B = pio.*absZO - 1;
    V = boxproj(-cof_B./cof_A);
    
    % Update Multipliers
    Kubz = Kub-Z;
    dxR = dx-R;
    dyS = dy-S;
    VabsZO = V.*absZO;
    
    piz = piz + gamma*alpha*Kubz;
    pir = pir + gamma*beta*dxR;
    pis = pis + gamma*beta*dyS;
    pio = pio + gamma*rho*VabsZO;
    
    % Statistics
    r1 = fnorm(Kubz);
    r2 = fnorm(dxR)+ fnorm(dyS);
    r3 = fnorm(VabsZO);
    all = r1 + r2 + r3;
    if(iter>30&&all<acc),break;end
    
    %     snrs = [snrs;PSNR];
    %     his = [his;computeTrueObj(U,Kmap,B,p,lambda)];
    %     imwrite(U,sprintf('%d.png',iter));
    
%     if(~mod(iter,30)),
%         fprintf('iter:%d, dist:(%.1e %.1e %.1e), penalty:(%.1e %.1e %.1e), snrl0: %f\n',iter,r1,r2,r3,alpha,beta,rho,snr_l0(U,B_Clean));
%     end
    
    if(~mod(iter,30)),
        if(r1>r2 && r1>r3),
            alpha = alpha * penalty_ratio;
        end
        if(r2>r1 && r2>r3),
            beta = beta * penalty_ratio;
        end
        if(r3>r1 && r3>r2),
            rho = rho * penalty_ratio;
        end
    end
    
end

% save('snrs','snrs')
% save('his','his')

% function [fobj] = computeTrueObj(U,Kmap,B,p,lambda)
% fobj =  lambda * sum(sum((difX(U).^p + difY(U).^p).^(1/p)))  + softl0norm(Kmap(U)-B);
%
% function [num] = softl0norm(x)
% num = sum(sum(sum(abs(x)>5/255)));