function img_RAMF = RAMF(img_noise, max)

%获取图像的列数
m=size(img_noise,1);
%获取图像的列数
n=size(img_noise,2);

%确定最大的滤波半径
Nmax=max;       

%下面是边界扩展，图像上下左右各增加Nmax像素。
imgn=zeros(m+2*Nmax,n+2*Nmax,'uint8');
imgn(Nmax+1:m+Nmax,Nmax+1:n+Nmax)=img_noise;

imgn(1:Nmax,Nmax+1:n+Nmax)=img_noise(1:Nmax,1:n);                 %扩展上边界
imgn(1:m+Nmax,n+Nmax+1:n+2*Nmax+1)=imgn(1:m+Nmax,n:n+Nmax);    %扩展右边界
imgn(m+Nmax+1:m+2*Nmax+1,Nmax+1:n+2*Nmax+1)=imgn(m:m+Nmax,Nmax+1:n+2*Nmax+1);    %扩展下边界
imgn(1:m+2*Nmax+1,1:Nmax)=imgn(1:m+2*Nmax+1,Nmax+1:2*Nmax);       %扩展左边界

re=imgn;
for i=Nmax+1:m+Nmax
    for j=Nmax+1:n+Nmax
        
        r=1;                %初始滤波半径
        while r <= Nmax
            W=imgn(i-r:i+r,j-r:j+r);
            %W = my_sort(W);
            W=sort(W(:));
            W_size = size(W);
            Imin=W(1);
            Imax=W(W_size(1));
            Imed=W(ceil(W_size(1)/2));
           
            if Imin<Imed && Imed<Imax       %如果当前邻域中值不是噪声点，那么就用此次的邻域
               break;
            else
                r=r+1;              %否则扩大窗口，继续判断
            end          
        end
        
        if Imin<imgn(i,j) && imgn(i,j)<Imax         %如果当前这个像素不是噪声，原值输出
            re(i,j)=imgn(i,j);
        else                                        %否则输出邻域中值
            re(i,j)=Imed;
        end
        
    end
end

img_RAMF = re(Nmax+1:m+Nmax,Nmax+1:n+Nmax);