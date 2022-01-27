close all;
clear
addpath('functions','images','results');
filename={'walkbridge512.bmp','pepper512.bmp','mandril512.bmp','lake512.bmp','jetplane512.bmp'};

bh=8;bw=8;

%%%%%%%%%%PSD parameters%%%%%%%%%%%%%%
beta=10;
fun=@(x) 1./(x.^2+eps);%exp(-200*x);%
%%%%%%%%%%padmm parameters%%%%%%%%%%%%%%
Amap = @(X)X;
Atmap = @(X)X;
LargestEig = 1;
p = 2;
lambda = 0.8;
acc = 1/255;
penalty_ratio = 10;

noises=0.3:0.2:0.9;
implement=0;  % 0---load the results; 1---run code
if implement
    for i=1:numel(filename)
        snr0{i}=[];
        snr1{i}=[];
        snr2{i}=[];
        img_gray = imread(['images/',filename{i}]);
        snr0b=[];
        snr1b=[];
        snr2b=[];
        for j=1:numel(noises)
            [m,n]=size(img_gray);
            bu=mean(double(img_gray(:)));
            snr0a=[];
            snr1a=[];
            snr2a=[];
            for t=1:10
                I = imnoise(img_gray,'salt & pepper',noises(j));
                img_RAMF=RAMF(I,21);
                
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
                img_AD=denoisebyalldata(img,emask,bh,bw,beta,fun);
                %img_AD = imgaussfilt(uint8(img_AD));
                img_AD=uint8(smblock(img_AD,mask,bh,bw));
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                snr0a=[snr0a,[snr_l0(img_gray,I);snr_l0(img_gray,img_RAMF);...
                    snr_l0(img_gray,img_TSM);snr_l0(img_gray,img_PDA);...
                    snr_l0(img_gray,img_padmm);snr_l0(img_gray,img_AD)]];
                snr1a=[snr1a,[snr_l1(img_gray,I);snr_l1(img_gray,img_RAMF);...
                    snr_l1(img_gray,img_TSM);snr_l1(img_gray,img_PDA);...
                    snr_l1(img_gray,img_padmm);snr_l1(img_gray,img_AD)]];
                snr2a=[snr2a,[snr_l2(img_gray,I);snr_l2(img_gray,img_RAMF);...
                    snr_l2(img_gray,img_TSM);snr_l2(img_gray,img_PDA);...
                    snr_l2(img_gray,img_padmm);snr_l2(img_gray,img_AD)]];
                
            end
            snr0b(:,:,j)=[snr0a,mean(snr0a,2)];
            snr1b(:,:,j)=[snr1a,mean(snr1a,2)];
            snr2b(:,:,j)=[snr2a,mean(snr2a,2)];
        end
        
        snr0s{i}=snr0b;
        snr1s{i}=snr1b;
        snr2s{i}=snr2b;
    end
    save('results\snr0s.mat','snr0s');
    save('results\snr1s.mat','snr1s');
    save('results\snr2s.mat','snr2s');
else
    load('snr0s.mat');
    load('snr1s.mat');
    load('snr2s.mat');
end

for i=1:numel(filename)
    msnr0=[];
    msnr1=[];
    msnr2=[];
    for j=1:numel(noises)
        msnr0=[msnr0,snr0s{i}(:,end,j)];
        msnr1=[msnr1,snr1s{i}(:,end,j)];
        msnr2=[msnr2,snr2s{i}(:,end,j)];
    end
    disp(filename{i});
    disp('snr0:           -----------30%---------------------50%----------------------70%---------------------90%---');       
    disp(['noisy image      ',num2str(msnr0(1,1)),'/',num2str(msnr1(1,1)),'/',num2str(msnr2(1,1)),...
        '   ',num2str(msnr0(1,2)),'/',num2str(msnr1(1,2)),'/',num2str(msnr2(1,2)),...
        '   ',num2str(msnr0(1,3)),'/',num2str(msnr1(1,3)),'/',num2str(msnr2(1,3)),...
        '   ',num2str(msnr0(1,4)),'/',num2str(msnr1(1,4)),'/',num2str(msnr2(1,4))]);
    disp(['AMF              ',num2str(msnr0(2,1)),'/',num2str(msnr1(2,1)),'/',num2str(msnr2(2,1)),...
        '   ',num2str(msnr0(2,2)),'/',num2str(msnr1(2,2)),'/',num2str(msnr2(2,2)),...
        '   ',num2str(msnr0(2,3)),'/',num2str(msnr1(2,3)),'/',num2str(msnr2(2,3)),...
        '   ',num2str(msnr0(2,4)),'/',num2str(msnr1(2,4)),'/',num2str(msnr2(2,4))]);
    disp(['TSM              ',num2str(msnr0(3,1)),'/',num2str(msnr1(3,1)),'/',num2str(msnr2(3,1)),...
        '   ',num2str(msnr0(3,2)),'/',num2str(msnr1(3,2)),'/',num2str(msnr2(3,2)),...
        '   ',num2str(msnr0(3,3)),'/',num2str(msnr1(3,3)),'/',num2str(msnr2(3,3)),...
        '   ',num2str(msnr0(3,4)),'/',num2str(msnr1(3,4)),'/',num2str(msnr2(3,4))]);
    disp(['PDA              ',num2str(msnr0(4,1)),'/',num2str(msnr1(4,1)),'/',num2str(msnr2(4,1)),...
        '   ',num2str(msnr0(4,2)),'/',num2str(msnr1(4,2)),'/',num2str(msnr2(4,2)),...
        '   ',num2str(msnr0(4,3)),'/',num2str(msnr1(4,3)),'/',num2str(msnr2(4,3)),...
        '   ',num2str(msnr0(4,4)),'/',num2str(msnr1(4,4)),'/',num2str(msnr2(4,4))]);
    disp(['PADMM            ',num2str(msnr0(5,1)),'/',num2str(msnr1(5,1)),'/',num2str(msnr2(5,1)),...
        '   ',num2str(msnr0(5,2)),'/',num2str(msnr1(5,2)),'/',num2str(msnr2(5,2)),...
        '   ',num2str(msnr0(5,3)),'/',num2str(msnr1(5,3)),'/',num2str(msnr2(5,3)),...
        '   ',num2str(msnr0(5,4)),'/',num2str(msnr1(5,4)),'/',num2str(msnr2(5,4))]);
    disp(['OURS             ',num2str(msnr0(6,1)),'/',num2str(msnr1(6,1)),'/',num2str(msnr2(6,1)),...
        '   ',num2str(msnr0(6,2)),'/',num2str(msnr1(6,2)),'/',num2str(msnr2(6,2)),...
        '   ',num2str(msnr0(6,3)),'/',num2str(msnr1(6,3)),'/',num2str(msnr2(6,3)),...
        '   ',num2str(msnr0(6,4)),'/',num2str(msnr1(6,4)),'/',num2str(msnr2(6,4))]);
    
end


