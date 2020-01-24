%% voicedemodfm
% 71844993 Nozomi Tanetani
%{
Fs = 20000;
Fc = 5000; %carrier frequency
dev = 0.2; %adjust sigma
[v, Fvs] = audioread('voice5k20kfm.wav');
[n, d] = rat(Fvs/Fs);
[r, c] = size(v);
t = (0:1/Fs:r/Fs-1/Fs);
z = zeros(r,1); % result storage
prev = 0;
for i=1:r
    tmp = atan2(v(i,1), v(i,2));
    if (tmp-prev > pi())
        z(i,1) = tmp - prev - pi() * 2.0;
    elseif (tmp-prev < -pi())
        z(i,1) = tmp - prev + pi() * 2.0;
    else
        z(i,1) = tmp - prev;
    end
    prev = tmp;
end
z = z .* dev;
fz = resample(z, d, n);
audiowrite('voicefm.wav', fz, Fs);
%}
iqw = dsp.AudioFileWriter("radioiq.wav", ...
    "SampleRate", samplerate, "DataType", "double");
if  ~isempty(sdrinfo(h.RadioAddress))
    while(1)
        [data,  ~] = step(h);  % no "len" output needed for blocking operation
        ddata = [real(data) imag(data)];
        iqw(ddata);
    end
end
fz = fdemod(iqw);
Fs = 20000;
audiowrite('famefm.wav', fz, Fs);

function R = fdemod(audio)
    Fs = 20000;
    dev = 0.2;
    [v, Fvs] = audioread(audio);
    [n, d] = rat(Fvs/Fs);
    [r, ~] = size(v);
    R = zeros(r,1); % result storage
    prev = 0;
    for i=1:r
        tmp = atan2(v(i,1), v(i,2));
        if (tmp-prev > pi())
            R(i,1) = tmp - prev - pi() * 2.0;
        elseif (tmp-prev < -pi())
            R(i,1) = tmp - prev + pi() * 2.0;
        else
            R(i,1) = tmp - prev;
        end
        prev = tmp;
    end
    R = R .* dev;
    R = resample(R, d, n);
end