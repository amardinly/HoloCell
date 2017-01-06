function FastFI(~)

global Exp_Defaults ExpStruct LED Ramp cell1 cell2 globalTimer s a sweeps h

if isfield(ExpStruct,'FastFIcount') ==0
    ExpStruct.FastFIcount = 0;
end

count = mod(ExpStruct.FastFIcount,8);

% setup current injection params for cell1

deltacurrentpulseamp1=100;
rampstart_voltage=(count-2)*deltacurrentpulseamp1;
rampend_voltage=rampstart_voltage; % in volts
rampstart_time=500;  % in milleseconds
ramp_duration=1000; % in milleseconds
ramp_frequency = 1;
ramp_number = 1;


%update GUI
settingnames = {'rampstart_voltage';'rampend_voltage';...
    'rampstart_time';'ramp_duration';'ramp_frequency';'ramp_number'};

for i = 1:length(settingnames)
set(eval(['h.',settingnames{i}]),'String',eval(settingnames{i}))
end
temp=make_ramps(rampstart_time, ramp_duration, ramp_frequency, ramp_number, rampstart_voltage, rampend_voltage, Exp_Defaults.Fs, Exp_Defaults.sweepduration);
ExpStruct.CCoutput1(:) = 0;
ExpStruct.CCoutput1 = temp/Exp_Defaults.CCexternalcommandsensitivity+ExpStruct.CCoutput1;

%check if two cells
if get(h.record_cell2_check, 'Value')
    ExpStruct.CCoutput2 = ExpStruct.CCoutput1;
end

ExpStruct.FastFIcount = ExpStruct.FastFIcount+1;
% set(a.sweepnum,'String',num2str(ExpStruct.FastFIcount));
ExpStruct.FastFI(ExpStruct.sweep_counter)=1;
% cell1.spikerate1(ExpStruct.sweep_counter-1) = countspikes(sweeps{(ExpStruct.sweep_counter-1)}(:,1),19000:19999,20001:40000,3,0);
% parameterchange(pulseamp,pulseduration,pulsenumber,pulsefrequency,pulse_starttime,rampstart_voltage,rampend_voltage,rampstart_time,ramp_duration,ramp_frequency, ramp_number,ccpulseamp1,ccpulse_dur1,ccnumpulses1,ccpulsefreq1,ccpulsestarttime1,deltacurrentpulseamp1,ccpulseamp2,ccpulse_dur2,ccnumpulses2,ccpulsefreq2,ccpulsestarttime2,deltacurrentpulseamp2,set_ISI,set_length)
updateAOaxes
