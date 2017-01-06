function customStimOrder(~)
global h ExpStruct
persistent CSO

thisSweep = ExpStruct.sweep_counter;

%check if this is the first time its being called or something has changed
if isempty(CSO) || (thisSweep-CSO.lastSweep)~=1 || ExpStruct.newCustomString == 1    
    CSO.firstSweep = thisSweep;
    CSO.lastSweep = thisSweep;
    ExpStruct.sequence_List= str2num(get(h.custom_sequence,'String'));
    CSO.totNum = numel( ExpStruct.sequence_List);
    CSO.num =1;
    if max(ExpStruct.sequence_List)>numel(ExpStruct.output_patterns)
        errordlg('Output does not exist')
        return
    end
    
    ExpStruct.newCustomString =0;
    disp('starting');
end

load_outputs(ExpStruct.sequence_List(CSO.num));

%re randomize when hit end
if CSO.num==CSO.totNum
    CSO.num=0;
    disp('startingOver');
end

CSO.num = CSO.num+1;
CSO.lastSweep = thisSweep;
