function ScanningGridMap

global ExpStruct Exp_Defaults LED Ramp h window a dmd sweeps

calllib('DMD','DLP_Source_SetDataSource','SL_EXT3P3')

if ~isfield(ExpStruct,'JGM')  
    if ~isfield(ExpStruct.JGM,'SGMstart')
    ExpStruct.JGM.totalStimsiteNo=size(ExpStruct.JGM.grid.maskbinary,2)*length(ExpStruct.mapmerge.mapind);
    ExpStruct.JGM.trialsPersite=zeros(1,ExpStruct.JGM.totalStimsiteNo);    
    ExpStruct.JGM.currentObjsite=1;
    ExpStruct.JGM.stimsPertrial=100;
    ExpStruct.JGM.SGMstart=1;
    end
end



ExpStruct.postSweepprogramChoice='SGMplaySelection';