function [ spikeTimes ] = poissonSpikeTrainAM( t, fr)
% Generate a poisson spike train, with mean firing rate fr.
% t = duration of the trial in seconds
% Fs = sampling rate in Hz
% fr = input firing rate to model in Hz
% pulseAmp is the amplitdue of the output signal in volts
% pulseDuration is length of each pulse (fixed) in ms

Fs = 20000; 
if nargin < 6
    plotOption = 0;
end


%% generate poisson train

nBins = floor(t/(1/Fs));
spikeMat = rand(1, nBins) < fr*(1/Fs);
spikeMat = find(spikeMat==1); % extract spike times from binary spikeMat
k=spikeMat/Fs;
spikeTimes=round(k*1000);
spikeTimes=spikeTimes';
