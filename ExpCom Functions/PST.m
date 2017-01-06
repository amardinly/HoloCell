function PST( t, fr, pulseAmp, pulseDuration)

%defaults for PV cells, need only specify voltage (power)!
if nargin==1
    pulseAmp=t;
    t=2;
    fr=15;
    pulseDuration=2;
end


% Generate a poisson spike train, with mean firing rate fr.
% t = duration of the trial in seconds
% Fs = sampling rate in Hz
% fr = input firing rate to model in Hz
% pulseAmp is the amplitdue of the output signal in volts
% pulseDuration is length of each pulse (fixed) in ms
global ExpStruct Exp_Defaults
Fs=Exp_Defaults.Fs;



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

%ExpStruct.checkStimpattern = 1;
%k=ExpStruct.output_patterns{1};
%k(:,4)=spikeTrainV;
%k(:,9)=spikeTrainG;
%ExpStruct.output_patterns{1}=k;

ExpStruct.StimLaserGate=spikeTrainG;
ExpStruct.StimLaserEOM=spikeTrainV';
updateAOaxes
end