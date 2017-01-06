function randomized_stimulus_sequence(~)
global h Exp_Defaults ExpStruct Ramp

if isfield(ExpStruct,'randomizedSequencecount') ==0
    ExpStruct.randomizedSequencecount = 0;
end

ExpStruct.randomized_sequence_order= str2num(get(h.custom_sequence,'String'));
if mod(ExpStruct.randomizedSequencecount,length(ExpStruct.randomized_sequence_order))==0
    ExpStruct.randomized_sequence_order= ExpStruct.randomized_sequence_order(randperm(length(ExpStruct.randomized_sequence_order)));
    set(h.custom_sequence,'String',num2str(ExpStruct.randomized_sequence_order));
end

pattern_no= ExpStruct.randomized_sequence_order(mod(ExpStruct.randomizedSequencecount,length(ExpStruct.randomized_sequence_order))+1);
set(h.output_list,'Value',pattern_no)

% ExpStruct.currentStimpattern=pattern_no;
ExpStruct.stim_tag(ExpStruct.sweep_counter+1)=pattern_no;
ExpStruct.randomized_seq_track(ExpStruct.sweep_counter+1)=pattern_no;

ExpStruct.CCoutput1=ExpStruct.output_patterns{pattern_no}(:,1);
ExpStruct.CCoutput2=ExpStruct.output_patterns{pattern_no}(:,2);
ExpStruct.LEDoutput1=ExpStruct.output_patterns{pattern_no}(:,3);
ExpStruct.LEDoutput2=ExpStruct.output_patterns{pattern_no}(:,4);

if length(ExpStruct.timebase) > length(ExpStruct.LEDoutput1);
    tempTimebase = zeros(length(ExpStruct.timebase),1);
    tempCCoutput1 = tempTimebase;
    tempCCoutput1(1:length(ExpStruct.CCoutput1)) = tempCCoutput1(1:length(ExpStruct.CCoutput1))+ ExpStruct.CCoutput1;
    ExpStruct.CCoutput1= tempCCoutput1;
    tempCCoutput2 = tempTimebase;
    tempCCoutput2(1:length(ExpStruct.CCoutput2)) = tempCCoutput2(1:length(ExpStruct.CCoutput2))+ ExpStruct.CCoutput2;
    ExpStruct.CCoutput2= tempCCoutput2;
    tempLEDoutput1 = tempTimebase;
    tempLEDoutput1(1:length(ExpStruct.LEDoutput1)) = tempLEDoutput1(1:length(ExpStruct.LEDoutput1))+ ExpStruct.LEDoutput1;
    ExpStruct.LEDoutput1= tempLEDoutput1;
    tempLEDoutput2 = tempTimebase;
    tempLEDoutput2(1:length(ExpStruct.LEDoutput2)) = tempLEDoutput2(1:length(ExpStruct.LEDoutput2))+ ExpStruct.LEDoutput2;
    ExpStruct.LEDoutput2= tempLEDoutput2;
elseif length(ExpStruct.timebase) < length(ExpStruct.LEDoutput1);
    ExpStruct.CCoutput1=ExpStruct.CCoutput1(1:length(ExpStruct.timebase));
    ExpStruct.CCoutput2=ExpStruct.CCoutput2(1:length(ExpStruct.timebase));
    ExpStruct.LEDoutput1=ExpStruct.LEDoutput1(1:length(ExpStruct.timebase));
    ExpStruct.LEDoutput2=ExpStruct.LEDoutput2(1:length(ExpStruct.timebase));
end

ExpStruct.randomizedSequencecount = ExpStruct.randomizedSequencecount+1;

updateAOaxes