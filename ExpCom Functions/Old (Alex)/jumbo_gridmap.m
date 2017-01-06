function jumbo_gridmap
tic
global ExpStruct Exp_Defaults LED Ramp h window a
workingsweep = ExpStruct.sweep_counter+1 
load('DMDcalibration.mat');
handles.xoffset=xoffset;
handles.yoffset=yoffset;
xborder = 1024-660;
padleft = floor((xborder)/2+handles.xoffset);
padright = xborder-padleft;
yborder = 768-480;
padtop = round((yborder)/2+handles.yoffset);
padbottom = yborder-padtop;

calllib('DMD','DLP_Source_SetDataSource','SL_EXT3P3');
calllib('DMD','DLP_Display_DisplayPatternAutoStepRepeatForMultiplePasses')

if not(isfield(ExpStruct,'JGM'))
    ExpStruct.JGM.currentParams=str2num(get(h.custom_sequence,'String'));
    ExpStruct.JGM.trialsPersite=zeros(1,size(ExpStruct.grid.maskbinary,2));
    ExpStruct.JGM.bufferstart=0;
    ExpStruct.JGM.playstart=400;
    calllib('DMD','DLP_RegIO_WriteImageOrderLut',1,(1:400)+ExpStruct.JGM.playstart,400);    
end

%select 400 sites that have not been played more than any other
%sites
currentMaxstims= max(ExpStruct.JGM.trialsPersite);

currentStimsitePool=find(ExpStruct.JGM.trialsPersite<currentMaxstims);
if length(currentStimsitePool)<400
    currentStimsitePool=[currentStimsitePool randsample(find(ExpStruct.JGM.trialsPersite==currentMaxstims),400-length(currentStimsitePool))];
end

currentLoadsites=randsample(currentStimsitePool,400);
ExpStruct.JGM.trialsPersite(currentLoadsites)=ExpStruct.JGM.trialsPersite(currentLoadsites)+1;

%Load up the 400 sites- note that this is in a random order determined by randsample    

for i = 1:400        
    calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',ExpStruct.grid.maskbinary(:,currentLoadsites(i)),98304,ExpStruct.JGM.bufferstart+i);    
    waitbar(i/400)
end

toc

%document which sites will be playing on the next sweep
ExpStruct.JGM.playOrder(:,workingsweep)=currentLoadsites';

%switch to other half of the buffer   
if ExpStruct.JGM.bufferstart == 400;
    newbufferstart=0;
    ExpStruct.JGM.playstart=400;
elseif ExpStruct.JGM.bufferstart == 0;
    newbufferstart=400;
    ExpStruct.JGM.playstart=0;
end        
ExpStruct.JGM.bufferstart=newbufferstart;



%set play order for next trial
calllib('DMD','DLP_RegIO_WriteImageOrderLut',1,(1:400)+ExpStruct.JGM.playstart,400);


  
