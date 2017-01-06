function SmartFI(~)

global Exp_Defaults ExpStruct LED Ramp cell1 cell2 globalTimer s a sweeps h

if isfield(ExpStruct,'SFI') ==0
    ExpStruct.SFI.count = 0;
    ExpStruct.SFI.before1curr=0;
    ExpStruct.SFI.before2curr=0;
    ExpStruct.SFI.before1spikes=0;
    ExpStruct.SFI.before2spikes=0;
    ExpStruct.SFI.thiscurr=0;
end

ExpStruct.postSweepprogramChoice='SFI_post';
ExpStruct.SFI.sweeptrack(ExpStruct.sweep_counter)=1;
ExpStruct.SFI.count = ExpStruct.SFI.count+1;


