function sendPhotoAmp(x)
global sweeps ExpStruct Exp_Defaults
%function expects a sweep containing 33 pulses to test regenerative
%holograms

thisSweep = sweeps{ExpStruct.sweep_counter-1}(:,x);
laser = ExpStruct.StimLaserEOM;
difLas = find(diff(laser));
difLas2 = difLas(1:2:length(difLas));  %pulse start times
for pulse = 1:numel(difLas2);
start = difLas2(pulse);
baseline = mean(thisSweep(start-(.05*Exp_Defaults.Fs):start));  %baseline is mean of 50 ms before pulse
response_window = thisSweep(start:start+(.025*Exp_Defaults.Fs)); %get 25 ms after pulse
photocurrent(pulse) = abs(min(response_window))-abs(baseline)
display(num2str(numel(photocurrent)))
end;

save('\\128.32.173.33\Imaging\STIM\HoloCost_function\output.mat','photocurrent');


