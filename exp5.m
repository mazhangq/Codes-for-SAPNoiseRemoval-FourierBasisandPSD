close all;
clear
addpath('functions','images','results');

filename={'barbara256.bmp','baboon256.bmp','couple256.bmp','pepper256.bmp',...
    'lena512.bmp','cameraman512.bmp','street512.bmp'};

noises=0.3:0.2:0.9;
bh=8;bw=8;

%%%%%%%%%%PSD parameters%%%%%%%%%%%%%%
beta=[25 50 75 100];
fun=@(x) 1./(x.^2+eps);%exp(-200*x);%
%%%%%%%%%%padmm parameters%%%%%%%%%%%%%%
Amap = @(X)X;
Atmap = @(X)X;
LargestEig = 1;
p = 2;
lambda = 0.8;
acc = 1/255;
penalty_ratio = 10;

warning('off','all');

% 0---load the results; 
% 1---run code£¬it will cost about 90 minutes
% for seven test images,four noise levels and 10 repetition depending 
% your computer
implement=0;  
if implement
    for i=1:numel(filename)  %seven test images
        img_gray = imread(['images/',filename{i}]);
        [m,n]=size(img_gray);
        statics_TSM=[];
        statics_PDA=[];
        statics_PADMM=[];
        statics_AD=[];
        for j=1:numel(noises)  %four noise levels
            t_TSM=[];
            t_PDA=[];
            t_PADMM=[];
            t_AD=[];
            for t=1:10  %repeat 10 times
                I = imnoise(img_gray,'salt & pepper',noises(j));
                
                tstart=tic;
                img_RAMF=RAMF(I,21);
                
                Mask=(img_RAMF~=I) &...
                    (I==0 | I==255);
                mask=~Mask;
                t_AMF=toc(tstart);
                %%%%%%%%%2 stage %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                tstart=tic;
                img_TSM=uint8(255*twostage(I,mask,500));
                t_TSM=[t_TSM;toc(tstart)];
                %%%%%%%%L0TVPDA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                tstart=tic;
                img_PDA=uint8(255*L0TVPDA(double(img_RAMF),mask,1.4));
                t_PDA=[t_PDA;toc(tstart)+t_AMF];
                %%%%%%%%%%padmm%%%%%%%%%%%%%%
                tstart=tic;
                img_padmm = l0tv_padmm_color(double(img_RAMF)/255,mask,Amap,...
                    Atmap,p,lambda,LargestEig,acc,penalty_ratio);
                img_padmm=uint8(255*img_padmm);
                t_PADMM=[t_PADMM;toc(tstart)+t_AMF];
                %%%%%%%%%%%OURS%%%%%%%%%%%%%%%
                tstart=tic;
                emask=expandimg(mask,bh/2+2,bw/2+2);
                img=expandimg(img_RAMF,bh/2+2,bw/2+2);
                img_AD=denoisebyalldata(img,emask,bh,bw,beta(j),fun);
                img_AD=uint8(smblock(img_AD,mask,bh,bw));
                t_AD=[t_AD;toc(tstart)+t_AMF];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            cputime{i,j}=[t_TSM,t_PDA,t_PADMM,t_AD];
        end
    end
    
    save('cputime.mat','cputime');
else
    load('cputime.mat');
end

%%%%%%%%%%%%%%%%%%%%cputime vs noise level for 256%%%%%%%%%
mt256=[];
mt512=[]
errs=[];

for j=1:numel(noises)
    aa=[];
    for i=1:4
        aa=[aa;cputime{i,j}];
    end
    mt256=[mt256;mean(aa)];
    bb=[];
    for i=5:7
        bb=[bb;cputime{i,j}];
    end
    mt512=[mt512;mean(bb)];
end

figure;
plot(1:4,mt256(:,1),'-rs','LineWidth',2,'MarkerSize',10);
hold on;
plot(1:4,mt256(:,2),'-b^','LineWidth',2,'MarkerSize',10);
plot(1:4,mt256(:,3),'-gV','LineWidth',2,'MarkerSize',10);
plot(1:4,mt256(:,4),'-ko','LineWidth',2,'MarkerSize',10);

plot(1:4,mt512(:,1),'--rs','LineWidth',2,'MarkerSize',10);
hold on;
plot(1:4,mt512(:,2),'--b^','LineWidth',2,'MarkerSize',10);
plot(1:4,mt512(:,3),'--gV','LineWidth',2,'MarkerSize',10);
plot(1:4,mt512(:,4),'--ko','LineWidth',2,'MarkerSize',10);

xlabel('Noise level');
ylabel('CPU time (s)');
% legend({'TSM+256','PDA+256','PADMM+256','OURS+256','TSM+512',...
%     'PDA+512','PADMM+512','OURS+512'},'Location','northwest','NumColumns',2);
xticks(1:4);
xticklabels({'30%','50%','70%','90%'});
axis([1 4 0 19]);
ax=gca;
ax.FontName='Times New Roman';
ax.FontSize = 20;
mean(mt256)
mean(mt512)
print('-f1','cputime1','-djpeg');

%%%%%%%%%%%%%%%%%%%%cputime vs test images %%%%%%%%%
mt=[];
for i=1:numel(filename)
    aa=[];
    for j=1:numel(noises)
      aa=[aa;cputime{i,j}];
    end
    mt=[mt;mean(aa)];
end
figure;
plot(1:numel(filename),mt(:,1),'-rs','LineWidth',2,'MarkerSize',10);
hold on;
plot(1:numel(filename),mt(:,2),'-b^','LineWidth',2,'MarkerSize',10);
plot(1:numel(filename),mt(:,3),'-gV','LineWidth',2,'MarkerSize',10);
plot(1:numel(filename),mt(:,4),'-ko','LineWidth',2,'MarkerSize',10);
%xlabel('Noise level');
ylabel('CPU time (s)');

% legend({'TSM','PDA','PADMM','OURS'},'Location','northwest','NumColumns',2);
xticks(1:numel(filename));
xticklabels({'Barbara','Baboon','Couple','Pepper','Lena','Cameraman','Street'});
axis([1 7 0 14]);
ax=gca;
ax.FontName='Times New Roman';
ax.FontSize = 20;
print('-f2','cputime2','-djpeg');
mean(mt)

