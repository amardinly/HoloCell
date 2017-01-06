function jumbo_gridmap3

global ExpStruct Exp_Defaults LED Ramp h window a
calllib('DMD','DLP_Source_SetDataSource','SL_EXT3P3')
if isfield(ExpStruct,'JGM')
    if not(isfield(ExpStruct.JGM,'trialsPersite'))    
    ExpStruct.JGM.trialsPersite=zeros(1,size(ExpStruct.JGM.maskbinary,2));   
    end
else
    ExpStruct.JGM.trialsPersite=zeros(1,size(ExpStruct.JGM.maskbinary,2)); 
end

ExpStruct.JGM.currentParams=str2num(get(h.custom_sequence,'String'));

%select sites that have not been played more than any other
%sites

frameno=ExpStruct.JGM.currentParams;
currentMaxstims= max(ExpStruct.JGM.trialsPersite);
currentStimsitePool=find(ExpStruct.JGM.trialsPersite<currentMaxstims);
if length(currentStimsitePool)<frameno
    currentStimsitePool=[currentStimsitePool randsample(find(ExpStruct.JGM.trialsPersite==currentMaxstims),frameno-length(currentStimsitePool))];
end



ExpStruct.JGM.playOrder{ExpStruct.sweep_counter}=randsample(currentStimsitePool,frameno);
ExpStruct.JGM.trialsPersite(ExpStruct.JGM.playOrder{ExpStruct.sweep_counter})=ExpStruct.JGM.trialsPersite(ExpStruct.JGM.playOrder{ExpStruct.sweep_counter})+1;


%set play order for next trial
calllib('DMD','DLP_RegIO_WriteImageOrderLut',1,ExpStruct.JGM.playOrder{ExpStruct.sweep_counter},frameno)

toc