% example of voice record
recObj = audiorecorder(16000, 16, 1); % create a recorder object with sampling rate 16000 Hz
disp("Start speaking"); % print out a start message
recordblocking(recObj, 5); % record the voice for 5 seconds
disp("Stop recording"); % print out a stop message after 5 second
play(recObj); % play back the voice
% obtain the pressure sequence as y array
y = getaudiodata(recObj);
%plot(y) % visualize the array
audiowrite('voice.wav', y, 16000); % save the audio data as a wave file. 