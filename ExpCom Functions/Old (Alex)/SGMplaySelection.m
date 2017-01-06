function SGMplaySelection
% tic
global ExpStruct Exp_Defaults LED Ramp h window a dmd sweeps

frameno=ExpStruct.JGM.stimsPertrial;

%move Obj to new site

thissite=randi(length(ExpStruct.mapmerge.mapind));

ExpStruct.JGM.objSite(ExpStruct.sweep_counter)=thissite;
moveTime = moveTo(ExpStruct.MP285,ExpStruct.sliceImagecoordinates{thissite});

stimRange=(1:size(ExpStruct.JGM.maskbinary,2))+(thissite-1)*size(ExpStruct.JGM.maskbinary,2);

currentMax= max(ExpStruct.JGM.trialsPersite(stimRange));
currentPool=find(ExpStruct.JGM.trialsPersite(stimRange)<currentMax);

if length(currentPool)<frameno
    currentPool=[currentPool randsample(size(ExpStruct.JGM.maskbinary,2),frameno-length(currentPool))];
end

% 
% [sorttrials sortind] =sort(ExpStruct.JGM.trialsPersite(stimRange(currentPool)));
% currentStimsitePool=currentPool(sortind(1:frameno));

thisPlayorder=randsample(currentPool,frameno);
calllib('DMD','DLP_RegIO_WriteImageOrderLut',1,thisPlayorder,frameno);
ExpStruct.JGM.playOrder{ExpStruct.sweep_counter}=stimRange(thisPlayorder);
ExpStruct.JGM.trialsPersite(ExpStruct.JGM.playOrder{ExpStruct.sweep_counter})=ExpStruct.JGM.trialsPersite(ExpStruct.JGM.playOrder{ExpStruct.sweep_counter})+1;


%autoupdate display if desired
if get(dmd.auto_update,'Value')
    OGM_calc_map(dmd.cell_disp_no,dmd.type_disp_no);
end