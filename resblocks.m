function s=resblocks(yy,bh,bw,h,w)
s=zeros(h,w);
M=h/bh;
N=w/bw;
for i=1:M
    for j=1:N
        s(bh*(j-1)+1:bh*j,bw*(i-1)+1:bw*i)...
            =reshape(yy(:,N*(i-1)+j),bh,bw);
    end
end