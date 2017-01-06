function expcom(~)

global cell1 cell2 LED Ramp ExpStruct Exp_Defaults h s sweeps a

if isfield(ExpStruct,'expcom') ==0
    ExpStruct.expcom = 0;
end

if get(h.RunDuring,'Value') == 1
    string = get(h.programChoice,'String');
    eval(string{get(h.programChoice,'Value')});
    ExpStruct.expcom=get(h.programChoice,'Value');
    
    input = get(h.custom_sequence,'String');
    ExpStruct.programInput = input;
    ExpStruct.programRunDuring{ExpStruct.sweep_counter}=1;
else
    ExpStruct.programRunDuring{ExpStruct.sweep_counter}=0;
end