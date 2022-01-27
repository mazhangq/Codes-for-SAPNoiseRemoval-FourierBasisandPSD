close all;
clear
addpath('functions','images','results');
filename={'barbara512.bmp','mandril512.bmp','lena512.bmp'};
bh=8;bw=8;
%%%%%%%%%%PSD parameters%%%%%%%%%%%%%%
beta=100;
fun=@(x) 1./(x.^2+eps);%exp(-200*x);%
%%%%%%%%%%padmm parameters%%%%%%%%%%%%%%
Amap = @(X)X;
Atmap = @(X)X;
LargestEig = 1;
p = 2;
lambda = 0.8;
acc = 1/255;
penalty_ratio = 10;

%%%%%%%%%for draw rectangle%%%%%%%%%%%%%%%%%%%%%%
 left=[321;97;221];
 right=[448;224;348];
 top=[321;33;193];
 bottom=[448;160;320];
 gaph=255*ones(512,2);
 gapv=255*ones(2,4*512+6);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
result=[];
for i=1:numel(filename)
    img_gray = imread(['images/',filename{i}]);
    
    I = imnoise(img_gray,'salt & pepper',0.9);
    img_RAMF=RAMF(I,31);
    
    Mask=(img_RAMF~=I) &...
        (I==0 | I==255);
    mask=~Mask;
    
    %%%%%%%%%2 stage %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    img_TSM=uint8(255*twostage(I,mask,500));
    
    %%%%%%%%L0TVPDA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    img_PDA=uint8(255*L0TVPDA(double(img_RAMF),mask,1.4));
    
    %%%%%%%%%%padmm%%%%%%%%%%%%%%
    img_padmm = l0tv_padmm_color(double(img_RAMF)/255,mask,Amap,...
        Atmap,p,lambda,LargestEig,acc,penalty_ratio);
    img_padmm=uint8(255*img_padmm);
    
    %%%%%%%%%%%OURS%%%%%%%%%%%%%%%
    emask=expandimg(mask,bh/2+2,bw/2+2);
    img=expandimg(img_RAMF,bh/2+2,bw/2+2);
    img_AD=denoisebyalldata(double(img),emask,bh,bw,beta,fun);
    img_AD=uint8(smblock(img_AD,mask,bh,bw));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    psnrs{i}=[psnr(I,img_gray);psnr(img_RAMF,img_gray);psnr(img_TSM,img_gray);...
                psnr(img_PDA,img_gray);psnr(img_padmm,img_gray);...
                psnr(img_AD,img_gray)];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    row1=[I,gaph,imresize(img_gray(top(i):bottom(i),left(i):right(i)),4),gaph,...
        img_RAMF,gaph,imresize(img_RAMF(top(i):bottom(i),left(i):right(i)),4)];
    
    row2=[img_TSM,gaph,imresize(img_TSM(top(i):bottom(i),left(i):right(i)),4),...
        gaph,img_PDA,gaph,imresize(img_PDA(top(i):bottom(i),left(i):right(i)),4)];
    
    row3=[img_padmm,gaph,imresize(img_padmm(top(i):bottom(i),left(i):right(i)),4),...
        gaph,img_AD,gaph,imresize(img_AD(top(i):bottom(i),left(i):right(i)),4)];
    
    result=[row1;gapv;row2;gapv;row3];
    figure;
    imshow(result);
    hold on;
    x=[left(i),right(i),right(i),left(i),left(i)];
    y=[top(i),top(i),bottom(i),bottom(i),top(i)];
    x1=x+1028;
    y1=y;
    plot(x1,y1,'r-','Linewidth',2);
    x1=x;
    y1=y+514;
    plot(x1,y1,'r-','Linewidth',2);
    x1=x+1028;
    plot(x1,y1,'r-','Linewidth',2);
    x1=x;
    y1=y+1028;
    plot(x1,y1,'r-','Linewidth',2);
    x1=x+1028;
    plot(x1,y1,'r-','Linewidth',2);
    
%     print(['-f',num2str(i)],['visual',num2str(i)],'-djpeg');   
end

for i=1:numel(filename)
    disp([filename{i},':']);
    disp('    Noisy-------RAMF-------TSM-------PDA-------PADMM-------AD');
    disp(['   ',num2str(psnrs{i}(1)),'    ', num2str(psnrs{i}(2)),'    ',...
        num2str(psnrs{i}(3)),'    ',num2str(psnrs{i}(4)),'    ',...
        num2str(psnrs{i}(5)),'    ',num2str(psnrs{i}(6))]);
end




