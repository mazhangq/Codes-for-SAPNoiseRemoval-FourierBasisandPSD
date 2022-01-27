function [U] = l0tv_proj_reg(B,O,Amap,Atmap,p,lambda,LargestEig,acc)%,B_Clean)

% min_{u}  lambda || Dxu Dyu ||_{p,1} + ||o.*(Ku-b)||_0
% min_{u}  lambda || r s ||_{p,1} + ||o.*z||_0,
% s.t. Dxu = r, Dyu = s, Ku - b = z

% L = lambda || r s ||_{p,1} + ||o.*z||_0 + <piz,Ku-b-z> + 0.5 alpha|Ku-b-z|_2^2
%                                      + <pir,Dxu-r>  + 0.5 beta |Dxu-r|_2^2
%                                      + <pis,Dyu-s>  + 0.5 beta |Dyu-s|_2^2

% When pen = 0, it is an Augmented Lagrangian method 
% When pen = 1, it is an penalty decomposition method
pen = 1;

% Primal Variables
U = B;
dx = difX(U);
dy = difY(U);
Z = 1*randn(size(B));
R = dx;
S = dy;

% Multipliers
piz = 0*randn(size(B));
pir = 0*randn(size(B));
pis = 0*randn(size(B));

gamma = 0.5*(1+sqrt(5)); %  golden ratio



alpha = 1;
beta  = 1;
ratio = sqrt(10);
his = [];
for iter = 1:10000,
    
    % Update RS
    % min_{R,S} lambda sum(sum((R.^p + S.^p).^(1/p))) + mdot(pir, -R) + 0.5*beta*fnorm(dx-R)^2 + mdot(pis, -S) + 0.5*beta*fnorm(dy-S)^2;
    R1 = - pir/beta -dx;    S1 = - pis/beta - dy;
    [R,S] = threadholding_RS(R1,S1,lambda,beta,p);
    
    % Update U
    g1 = Atmap(piz) + alpha*Atmap(Amap(U)-B-Z);
    g2 = divX(-pir+beta*R)  - beta*divX(dx);
    g3 = divY(-pis+beta*S) - beta*divY(dy);
    gradU =     g1 + g2 + g3;
    Lip = beta*4 + beta*4 + alpha*LargestEig;
    U   = boxproj(U - gradU/Lip);
    dx  = difX(U);    dy  = difY(U);
    
    % Update Z:
    D = Amap(U)-B;
    % min_{Z} ||o.*z||_0 + mdot(piz, Amap(U)-B-Z) + 0.5 * alpha*fnorm(D-Z)^2
    % min_{Z} ||o.*z||_0 + mdot(piz, -Z) + 0.5 * alpha*fnorm(D-Z)^2
    % min_{Z} ||o.*z||_0 + 0.5 * alpha*fnorm(Z-(D+piz/alpha))^2
    % min_{Z} 1/alpha||o.*z||_0 + 0.5 * fnorm(Z-(D+piz/alpha))^2
    Z=threadholding_l0_matrix(-D-piz/alpha,O/alpha);
 
    
    
    %     Lag = sum(sum((R.^p + S.^p).^(1/p))) + mdot(piz, Amap(U)-B-Z) + 0.5 * alpha*fnorm(Amap(U)-B-Z)^2 ...
    %         + mdot(pir, dx-R) + 0.5*beta*fnorm(dx-R)^2 + mdot(pis, dy-S) + 0.5*beta*fnorm(dy-S)^2;
    %     his = [his;Lag];
    
    
    
    r1 = fnorm(Amap(U) - B-Z);
    r2 = fnorm(dx-R)+ fnorm(dy-S);
    if(iter>10 && r1<acc && r2<acc),break;end
    
%     PSNR   =  snr_l1(U, B_Clean);
%    if(~mod(iter,30)),
%        fprintf('iter:%d, nearness: (%.1e %.1e), penalty:(%f %f), psnr: %f\n',iter,r1,r2,alpha,beta,PSNR);
%    end
    
    
    % Update Multipliers
    if(~pen)
    piz = piz + gamma*alpha*(Amap(U) - B-Z);
    pir = pir + gamma*beta*(dx-R);
    pis = pis + gamma*beta*(dy-S);
    end
    
    if(~mod(iter,30)),
%         if(r1>r2),
            alpha = alpha * ratio;
%         else
            beta = beta * ratio;
%         end
    end   
    
end
