function OGMplaySelection
% tic
global ExpStruct Exp_Defaults LED Ramp h window a dmd sweeps

frameno=ExpStruct.JGM.stimsPertrial;
bufferPool=ExpStruct.JGM.playFrames;

currentMax= max(ExpStruct.JGM.trialsPersite(bufferPool));
currentPool=find(ExpStruct.JGM.trialsPersite(bufferPool)<currentMax);

if length(currentPool)<frameno
    currentPool=[currentPool randsample((1:ExpStruct.JGM.buffSize),frameno-length(currentPool))];
end

%set play order for next trial
thisPlayorder=randsample(currentPool,frameno);

%track w/ reference to absolute frame
ExpStruct.JGM.playOrder{ExpStruct.sweep_counter}=bufferPool(thisPlayorder);


%set DMD play order
calllib('DMD','DLP_RegIO_WriteImageOrderLut',1,thisPlayorder+ExpStruct.JGM.playStart,frameno)

%track which frames have been used
ExpStruct.JGM.trialsPersite(bufferPool(thisPlayorder))=ExpStruct.JGM.trialsPersite(bufferPool(thisPlayorder))+1;

%autoupdate display if desired
if get(dmd.auto_update,'Value')
    OGM_calc_map(dmd.cell_disp_no,dmd.type_disp_no);
end

% toc

