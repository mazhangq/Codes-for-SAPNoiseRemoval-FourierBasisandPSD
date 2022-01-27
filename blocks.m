function s=blocks(img,h,w)
[m,n]=size(img);
M=fix(m/h);
N=fix(n/w);
s=[];
for i=1:M
    for j=1:N
        bb=img(h*(j-1)+1:h*j,w*(i-1)+1:w*i);
        s=[s,bb(:)];
    end
end