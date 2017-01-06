function randomizeStimOrder(~)
global h ExpStruct
persistent RSO

thisSweep = ExpStruct.sweep_counter;

%check if this is the first time its being called or something has changed
if isempty(RSO) || (thisSweep-RSO.lastSweep)~=1 || ExpStruct.newCustomString == 1
    
    RSO.firstSweep = thisSweep;
    RSO.lastSweep = thisSweep;
    ExpStruct.sequence_List= str2num(get(h.custom_sequence,'String'));
    RSO.totNum = numel( ExpStruct.sequence_List);
    ExpStruct.random_sequence_List=ExpStruct.sequence_List(randperm(RSO.totNum));
    RSO.num =1;
    if max(ExpStruct.sequence_List)>numel(ExpStruct.output_patterns)
        errordlg('Output does not exist')
        return
    end
    
    ExpStruct.newCustomString =0;
    disp('randomize sequence');
end

load_outputs(ExpStruct.random_sequence_List(RSO.num));

%re randomize when hit end
if RSO.num==RSO.totNum
    ExpStruct.random_sequence_List=ExpStruct.sequence_List(randperm(RSO.totNum));
    RSO.num=0;
    disp('rerandomize sequence')
end

RSO.num = RSO.num+1;
RSO.lastSweep = thisSweep;
