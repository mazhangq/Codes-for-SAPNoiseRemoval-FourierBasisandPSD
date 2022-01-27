close all;
clear
addpath('functions','images','results');
filename={'barbara256.bmp','baboon256.bmp','couple256.bmp','pepper256.bmp',...
    'lena512.bmp','cameraman512.bmp','street512.bmp'};

bh=8;bw=8;

%%%%%%%%%%PSD parameters%%%%%%%%%%%%%%
beta=10;
fun=@(x) 1./(x.^2+eps);%exp(-200*x);%


noises=0.3:0.2:0.9;
implement=0;  % 0---load the results; 1---run code
if implement
    for i=1:numel(filename)
        psnrs{i}=[];
        img_gray = imread(['images/',filename{i}]);
        psnrb=[];
        for j=1:numel(noises)
            [m,n]=size(img_gray);
            bu=mean(double(img_gray(:)));
            psnra=[];
            for t=1:10               
                I = imnoise(img_gray,'salt & pepper',noises(j));
                img_RAMF=RAMF(I,21);
                Mask=(img_RAMF~=I) &...
                    (I==0 | I==255);
                mask=~Mask;
                
               
                emask=expandimg(mask,bh/2+2,bw/2+2);
                img=expandimg(img_RAMF,bh/2+2,bw/2+2);
                img_AD=denoisebyalldata(img,emask,bh,bw,beta,fun);
                img_AD=uint8(smblock(img_AD,mask,bh,bw));
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                psnra=[psnra,[psnr(I,img_gray);psnr(img_RAMF,img_gray);psnr(img_AD,img_gray)]];
                
            end
            psnrb(:,:,j)=[psnra,mean(psnra,2),std(psnra')'];
        end
        psnrs{i}=psnrb;
    end
    save('psnrs.mat','psnrs');
else
    load('psnrs.mat');
end

for i=1:numel(filename)
    mpsnr=[];
    stdpsnr=[];
    for j=1:numel(noises)
        mpsnr=[mpsnr,psnrs{i}(:,end-1,j)];
        stdpsnr=[stdpsnr,psnrs{i}(:,end,j)];
    end
    disp(filename{i});
    disp('psnr:               ---30%----------------50%-----------------70%----------------90%---');       
    disp(['noisy image      ',num2str(mpsnr(1,1)),'+-',num2str(stdpsnr(1,1)),...
        '   ',num2str(mpsnr(1,2)),'+-',num2str(stdpsnr(1,2)),...
        '   ',num2str(mpsnr(1,3)),'+-',num2str(stdpsnr(1,3)),...
        '   ',num2str(mpsnr(1,4)),'+-',num2str(stdpsnr(1,4))]);
     disp(['AMF              ',num2str(mpsnr(2,1)),'+-',num2str(stdpsnr(2,1)),...
        '   ',num2str(mpsnr(2,2)),'+-',num2str(stdpsnr(2,2)),...
        '   ',num2str(mpsnr(2,3)),'+-',num2str(stdpsnr(2,3)),...
        '   ',num2str(mpsnr(2,4)),'+-',num2str(stdpsnr(2,4))]);
     disp(['OURS             ',num2str(mpsnr(3,1)),'+-',num2str(stdpsnr(3,1)),...
        '   ',num2str(mpsnr(3,2)),'+-',num2str(stdpsnr(3,2)),...
        '   ',num2str(mpsnr(3,3)),'+-',num2str(stdpsnr(3,3)),...
        '   ',num2str(mpsnr(3,4)),'+-',num2str(stdpsnr(3,4))]);
    
end


