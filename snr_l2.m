function snrl2=snr_l2(original,noisy)
bu=mean(original(:));
snrl2=10*log10(sum((double(original(:))-bu).^2)/...
            sum((double(original(:))-double(noisy(:))).^2));
