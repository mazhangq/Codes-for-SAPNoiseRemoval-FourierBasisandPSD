function II=smblock(II,mask,bh,bw)
[h,w]=size(II);
hmask=ones(h,w);
hmask(:,1:bw:end)=0;
hmask(:,2:bw:end)=0;
hmask(:,bw:bw:end)=0;
hmask(:,bw-1:bw:end)=0;
hmask=(hmask+mask)>0;
I1=II;

for i=1:h
    xq=find(hmask(i,:));
    x=1:w;
    x(xq)=[];
    yq=II(i,xq);
    I1(i,x)=interp1(xq,yq,x,'spline');
end

hmask=ones(h,w);
hmask(1:bh:end,:)=0;
hmask(2:bh:end,:)=0;
hmask(bh-1:bh:end,:)=0;
hmask(bh:bh:end,:)=0;
hmask=(hmask+mask)>0;
I2=II;

for i=1:w
    xq=find(hmask(:,i));
    x=1:h;
    x(xq)=[];
    yq=II(xq,i);
    I2(x,i)=interp1(xq,yq,x,'spline');
end
II=(I1+I2)/2;

