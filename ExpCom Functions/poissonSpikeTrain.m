function [ spikeTrainV spikeTrainG ] = poissonSpikeTrain( t, fr, pulseAmp, pulseDuration)
% Generate a poisson spike train, with mean firing rate fr.
% t = duration of the trial in seconds
% Fs = sampling rate in Hz
% fr = input firing rate to model in Hz
% pulseAmp is the amplitdue of the output signal in volts
% pulseDuration is length of each pulse (fixed) in ms
global ExpStruct Exp_Defaults
Fs=Exp_Defaults.Fs;

if nargin < 6
    plotOption = 0;
end


%% generate poisson train

nBins = floor(t/(1/Fs));
spikeMat = rand(1, nBins) < fr*(1/Fs);
spikeMat = find(spikeMat==1); % extract spike times from binary spikeMat

timeBase = (0:1/Fs:t-1/Fs); 
spikeTrainV = zeros(1,length(timeBase)); 
spikeTrainG = zeros(1,length(timeBase)); 

% loop to convolve poisson train with square function for light control
for i=1:length(spikeMat)
    thisPulse = zeros(1,length(timeBase)); 
    thisPulse(spikeMat(i):(spikeMat(i)+pulseDuration*Fs/1000-1)) = pulseAmp;
    
    
    thatPulse = zeros(1,length(timeBase)); 
    thatPulse(spikeMat(i):(spikeMat(i)+pulseDuration*Fs/1000-1)) = 1;
    
    
    
    
    if length(thisPulse)<=length(spikeTrainV)
        spikeTrainV = spikeTrainV+thisPulse;
        spikeTrainG = spikeTrainG+thatPulse;
    end
end

% if two pulses overlap, prevent doubling of amplitude
for i=1:length(spikeTrainV)
    if spikeTrainV(i)>pulseAmp
        spikeTrainV(i) = pulseAmp;
        spikeTrainG(i) = 1;

    end
end


ExpStruct.StimLaserGate=spikeTrainG;
ExpStruct.StimLaserEOM=spikeTrainV;
updateGUI
end