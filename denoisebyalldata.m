function img=denoisebyalldata(img,mask,bh,bw,beta,fun)

[m,n]=size(img);

%mbs=sum(img(:).*mask(:))/sum(mask(:));

f=[];
exth=2*bh+bh/2;
extw=2*bw+bw/2;
idx=getidx(exth,extw,bh,bw,1);
[nr,nc]=size(idx);
idx0=idx(:,(nc-1)/2+1);

bk_idx=getidx(m,n,exth,extw,bw);
for i=1:size(bk_idx,2)
    bk=img(bk_idx(:,i));
    mmask=mask(bk_idx(:,i));
    
    bs=double(bk(idx));
    bmask=double(mmask(idx));
    x=double(bk(idx0));
    xmask=mmask(idx0);
    
    mbs=mean(bs,2);
    s1=bs-mbs;
    x=x-mbs;
    
    xx= recon_alldatadrive(s1,bmask,x,xmask,beta,fun);
    
    f=[f,xx+mbs];
end



% for j=1:bw:m-extw+1
%     for i=1:bh:n-exth+1
%         bk=img(i:exth+i-1,j:extw+j-1);
%         mmask=mask(i:exth+i-1,j:extw+j-1);
%         
%         bs=double(bk(idx));
%         bmask=double(mmask(idx));
%         x=double(bk(idx0));
%         xmask=mmask(idx0);
%         
%         mbs=mean(bs,2);
%         s1=bs-mbs;
%         x=x-mbs;
%         
%         xx= recon_alldatadrive(s1,bmask,x,xmask,beta,fun);
%         
%         f=[f,xx+mbs];
%     end
% end
img=resblocks(f,bh,bw,sqrt(size(f,2))*bh,sqrt(size(f,2))*bw);
end

