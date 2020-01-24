%%final project
%71844993 Nozomi Tanetani

prompt = "Input the center freq(MHz)(e.g. FM Yokohama 84.7):";
centerfreq = input(prompt) * 1e+6;
samplerate = 240e+3;
framesize = 100000;
audiosr = 48e+3;

h = comm.SDRRTLReceiver("0","CenterFrequency", centerfreq, ...
    "SampleRate", samplerate, ...
    "SamplesPerFrame", framesize, ...
    "EnableTunerAGC", true, ...
    "OutputDataType", "double");

N = 480; % Num of Filter Tap
Rp = 0.00057565;
Rst = 1e-5;

%create LPF
Fp = 15e+3;
eqnum1 = firceqrip(N,Fp/(samplerate/2),[Rp Rst],'passedge');
lowpassFIR = dsp.FIRFilter('Numerator', eqnum1);

%create HPF
Qp = 38e+3;
eqnum2 = firceqrip(N,Qp/(samplerate/2),[Rp Rst],'high');
hpf38kFIR = dsp.FIRFilter('Numerator', eqnum2);

%create BPF
eqnum3 = firceqrip(N,52e+3/(samplerate/2),[Rp Rst],'high');
eqnum4 = firceqrip(N,23e+3/(samplerate/2),[Rp Rst],'high');
eqnum34 = eqnum3 - eqnum4;
bpfFIR = dsp.FIRFilter('Numerator', eqnum34);

%create de-enphasis filter
L = samplerate; % sample length
FL = 480; % tap
N = 50e+3;
f = zeros(L,1);
tau = 50e-6;
for i=1:N
    f(i) = 1*2*pi*samplerate*tau;
    f(samplerate-i+1) = 1*2*pi*samplerate*tau;
end
yt = ifft(f);
yt = resample(yt, FL, L);
yt = yt / max(yt);
deenphasisFIR = dsp.FIRFilter('Numerator', transpose(real(yt)));

%create audio player with the audio sampling rate (audiosr)
player = audioDeviceWriter("SampleRate", audiosr);
if  ~isempty(sdrinfo(h.RadioAddress)) % acquire frame until empty
    while(1)
       [audiodata,  ~] = step(h);  % fetch data and save in audio variable.
        demodData = fdemod(audiodata); % demodulation
       % apply lowpass filter
        lradd = lowpassFIR(demodData);
       % obtain 19k pilot tone to extract stereo signals
        d = fdesign.peak("N,F0,BW,Ast",20,2*19000/samplerate,.02,80);
        peakf = design(d,"cheby2","SystemObject",true);
        a19k = peakf(demodData);% apply the peak filter to received signal
        a38k = a19k .* a19k;% square to produce double frequency tone
        a38k = a38k/(max(a38k)); %nomarize
        a38k = hpf38kFIR(a38k); % apply a high pass filter to extract 38 kHz tone
        % peak frequency required to decode stereo sounds
        lrsubraw = bpfFIR(demodData);
        lrsub = lrsubraw .* a38k;
       % apply de-emphasis filter
        lradd = deenphasisFIR(lradd);
        lrsub = deenphasisFIR(lrsub);
       % resample (->48kHz)
        leftch = (lradd + lrsub) / 2 ;
        rightch = (lradd - lrsub) / 2;
        leftch = resample(leftch, audiosr, samplerate);
        rightch = resample(rightch, audiosr, samplerate);
        % aggregates two channel
        aggch = horzcat(leftch,rightch); %left and right channels are merged
        player(aggch); %playback the audio stream as stereo
    end
end

function R = fdemod(audio)
    [r, ~] = size(audio);
    R = zeros(r,1); % result storage
    prev = 0;
    for i=1:r
        tmp = atan2(real(audio(i)), imag(audio(i)));
        if (tmp-prev > pi())
            R(i,1) = tmp - prev - pi() * 2.0;
        elseif (tmp-prev < -pi())
            R(i,1) = tmp - prev + pi() * 2.0;
        else
            R(i,1) = tmp - prev;
        end
        prev = tmp;
    end
end