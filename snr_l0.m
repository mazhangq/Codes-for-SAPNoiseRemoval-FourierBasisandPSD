function snrl0=snr_l0(original,noisy)
diff = abs(double(noisy(:))-double(original(:)));
snrl0=100*(1-sum(diff>20)/numel(original));
