function SFI_post(~)

global Exp_Defaults ExpStruct LED Ramp cell1 cell2 globalTimer s a sweeps h
rampstart_time=500;  % in milleseconds
ramp_duration=1000; % in milleseconds
ramp_frequency = 1;
ramp_number = 1;
deltacurrent=50;
cellno=2;

%update spikes and current record
ExpStruct.SFI.before2curr=ExpStruct.SFI.before1curr;
ExpStruct.SFI.before2spikes=ExpStruct.SFI.before1spikes;
ExpStruct.SFI.before1spikes=countspikes(sweeps{ExpStruct.sweep_counter-1}(:,cellno),9000:9999,10000:30000,2,0);
ExpStruct.SFI.before1curr=ExpStruct.SFI.thiscurr;

ExpStruct.SFI.spikes(ExpStruct.sweep_counter-1)=ExpStruct.SFI.before1spikes;
ExpStruct.SFI.curr(ExpStruct.sweep_counter-1)=ExpStruct.SFI.before1curr;
    
ExpStruct.CCoutput2(:) = 0;
if ExpStruct.SFI.before1curr<1000 & ~(ExpStruct.SFI.before2spikes>ExpStruct.SFI.before1spikes+3)
   ExpStruct.SFI.thiscurr=ExpStruct.SFI.before1curr+deltacurrent;
   temp=make_ramps(500,1000,1,1,ExpStruct.SFI.thiscurr,ExpStruct.SFI.thiscurr,Exp_Defaults.Fs, Exp_Defaults.sweepduration);
else
   ExpStruct.SFI.thiscurr=-100;
   temp=make_ramps(500,1000,1,1,ExpStruct.SFI.thiscurr,ExpStruct.SFI.thiscurr,Exp_Defaults.Fs, Exp_Defaults.sweepduration);
   ExpStruct.SFI.before2curr=0;
   ExpStruct.SFI.before2spikes=0;
   ExpStruct.SFI.before1spikes=0;
   ExpStruct.SFI.before1curr=0;
end

ExpStruct.CCoutput2 = temp/Exp_Defaults.CCexternalcommandsensitivity+ExpStruct.CCoutput2;

updateAOaxes
