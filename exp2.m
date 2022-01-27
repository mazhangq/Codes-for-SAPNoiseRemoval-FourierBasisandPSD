close all;
clear
addpath('functions','images','results');
filename={'barbara512.bmp','mandril512.bmp','lena512.bmp'};
bh=8;bw=8;
%%%%%%%%%%PSD parameters%%%%%%%%%%%%%%
fun=@(x) 1./(x.^2+eps);%exp(-200*x);%

noises=0.3:0.2:0.9;
betas=[0.01 0.1 1 10 100 500 1000];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
implement=0;  % 0---load the results; 1---run code
if implement
    for i=1:numel(filename)
        img_gray = imread(['images/',filename{i}]);
        for j=1:numel(noises)
            snrs{i,j}=[];
            temps=[];
            for t=1:5
                I = imnoise(img_gray,'salt & pepper',noises(j));
                img_RAMF=RAMF(I,21);
                Mask=(img_RAMF~=I) &...
                    (I==0 | I==255);
                mask=~Mask;
                emask=expandimg(mask,bh/2+2,bw/2+2);
                img=expandimg(img_RAMF,bh/2+2,bw/2+2);
                temp=[];
                for k=1:numel(betas)
                    beta=betas(k);
                    img_AD=denoisebyalldata(double(img),emask,bh,bw,beta,fun);
                    img_AD=uint8(smblock(img_AD,mask,bh,bw));
                    temp=[temp;[psnr(img_AD,img_gray),snr_l0(img_gray,img_AD),...
                        snr_l1(img_gray,img_AD),snr_l2(img_gray,img_AD)]];
                end
                temps(:,:,t)=temp;
            end
            snrs{i,j}=mean(temps,3);
        end
    end
    save('results\snrs_beta.mat','snrs');
else
    load('snrs_beta.mat');
end
ylabels={'PSNR','SNR0','SNR1','SNR2'};
marks={'o-','V:','^-.','S--'};
axiss=[[1 7 16 40];[1 7 70 102];[1 7 4 15];[1 7 3 25]];
for i=1:numel(filename)
    for k=1:4
        figure;
        for j=1:numel(noises)
            plot(snrs{i,j}(:,k),marks{j},'LineWidth',2,'MarkerSize',10);
            hold on;
        end
        %xlabel('\beta');
        %ylabel(ylabels{k});
        %legend({'30%','50%','70%','90%'},'Location','southwest','NumColumns',4);
        xticks(1:7);
        xticklabels({'0.01','0.1','1','10','100','500','1000'});
        ax=gca;
        ax.FontName='Times New Roman';
        ax.FontSize = 20;
        axis(axiss(k,:));
        print(['-f',num2str((i-1)*4+k)],['beta',num2str((i-1)*4+k)],'-djpeg');        
    end
end




