function idx0=getidx(h,w,bh,bw,step)
idx=(1:bw)';
for i=1:bw-1
    idx=[idx;idx(end-bw+1:end)+h];
end
for i=1:fix((h-bh)/step)
    idx=[idx,idx(:,end)+step];
end
idx0=idx;
for i=1:fix((w-bw)/step)
    idx0=[idx0,idx+i*step*h];
end
