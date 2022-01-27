function snrl1=snr_l1(original,noisy)
bu=mean(original(:));
snrl1=10*log10(sum(abs(double(original(:))-bu))/...
            sum(abs(double(original(:))-double(noisy(:)))));