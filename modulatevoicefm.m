%% voice data fm modulate
%
Fs = 20000;
Fc = 5000; %carrier frequency
dev = 0.2; %adjust sigma
[v, Fvs] = audioread('voice.wav');
[n, d] = rat(Fvs/Fs);
vrr = resample(v, d, n);
[r, c] = size(vrr);
t = (0:1/Fs:r/Fs-1/Fs);
y = zeros(r,2); % IQ signal storage
for i=1:r
    y(i,1) = cos(2*pi()*(Fc+vrr(i)*dev)*t(i));
    y(i,2) = sin(2*pi()*(Fc+vrr(i)*dev)*t(i));
end
subplot(2,1,1)
plot(y(:,1));
title('modulated signal')
subplot(2,1,2)
plot(vrr)
title('baseband signal')
audiowrite('voice5k20kfm.wav', y, Fs);