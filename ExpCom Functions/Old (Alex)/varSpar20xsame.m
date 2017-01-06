function varSpar20xsame
global ExpStruct Exp_Defaults LED Ramp h window a
tic
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
% sparseness=[0.5 1 2 4 8 16 32 64 128 256];
    
calllib('DMD','DLP_Source_SetDataSource','SL_EXT3P3');

 
if isfield(ExpStruct,'noisecount') ==0
ExpStruct.currentsparseness=str2num(get(h.custom_sequence,'String'));
% ExpStruct.currentsparseness=round(ExpStruct.currentsparseness*10);
   
%load up front of buffer if first trial
    ExpStruct.currentseed=1;       
    ss = RandStream('mt19937ar','Seed',ExpStruct.currentseed);
    reset(ss,ExpStruct.currentseed) 
    
     
  
    for j=1:length(ExpStruct.currentsparseness)        
        for i = 1:10
        y = randi(ss,1000,ExpStruct.wgngrid.numrow,ExpStruct.wgngrid.numcol);
        y=y/10;
        y = (y<=ExpStruct.currentsparseness(j));    
        ExpStruct.currentStimtoLoad{i+(j-1)*10}=y;
        end
    end
    
    ExpStruct.stimarchive{workingsweep-1}=ExpStruct.currentStimtoLoad;
    
    for i = 1:400
    frameToload=i;
    mask = zeros(size(ExpStruct.wgngridmask));
    noise = resizem(ExpStruct.currentStimtoLoad{frameToload},[ExpStruct.wgngrid.totalheight ExpStruct.wgngrid.totalwidth]);
    mask(ceil(ExpStruct.wgngrid.top:ExpStruct.wgngrid.bottom-1),ceil(ExpStruct.wgngrid.left:ExpStruct.wgngrid.right-1))=noise;
    finalmask = zeros(1024,768);
    finalmask(padleft+1:padleft+660,padtop+1:padtop+480)=(mask');
    x = bi2de(reshape(finalmask,8,98304)');
    calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',x,98304,frameToload);
    waitbar(i/400)
    end
    
    
       
    ExpStruct.lastseed =ExpStruct.currentseed;
    ExpStruct.lastsparseness=ExpStruct.currentsparseness;
    ExpStruct.noisecount = 0;
    ExpStruct.noiseseed=[];
    ExpStruct.bufferstart = 0;
    ExpStruct.bufferloadcounter=20; 
    
end


ExpStruct.noisecount = ExpStruct.noisecount+1;

%check if buffer is full
if ExpStruct.bufferloadcounter==20;
    
    ExpStruct.lastseed =ExpStruct.currentseed;
    ExpStruct.lastsparseness=ExpStruct.currentsparseness;
    ExpStruct.currentsparseness=str2num(get(h.custom_sequence,'String'));
    ExpStruct.currentseed=randi(10000);       
    ss = RandStream('mt19937ar','Seed',ExpStruct.currentseed);
    reset(ss,ExpStruct.currentseed) 
        %generate new stimuli set
        
        for j=1:length(ExpStruct.currentsparseness)
            for i = 1:10
            y = randi(ss,1000,ExpStruct.wgngrid.numrow,ExpStruct.wgngrid.numcol);
            y=y/10;
            y = (y<=ExpStruct.currentsparseness(j));          
            ExpStruct.currentStimtoLoad{i+(j-1)*10}=y;
            end
        end
        
        ExpStruct.stimarchive{workingsweep}=ExpStruct.currentStimtoLoad;
        
        
        
        
        if ExpStruct.bufferstart == 400;
        newbufferstart=0;
        ExpStruct.playstart=400;
        elseif ExpStruct.bufferstart == 0;
        newbufferstart=400;
        ExpStruct.playstart=0;
        end
        
        ExpStruct.bufferstart=newbufferstart;
        ExpStruct.bufferloadcounter=0;
end


%set up frame order for next sweep

% 11 frames, same sparseness
ExpStruct.spchoose(:,ExpStruct.sweep_counter)=ones(20,1)*randi(length(ExpStruct.lastsparseness));
% ExpStruct.spchoose(:,ExpStruct.sweep_counter)=ones(20,1)*randi(15);
% ExpStruct.spchoose(:,ExpStruct.sweep_counter)=ones(20,1)*8;
ExpStruct.sparseness(:,ExpStruct.sweep_counter)=ExpStruct.lastsparseness(ExpStruct.spchoose(:,ExpStruct.sweep_counter));
ExpStruct.whitenoiseframeorder(:,ExpStruct.sweep_counter) = randi(20,[20 1])+ExpStruct.playstart+(ExpStruct.spchoose(:,ExpStruct.sweep_counter)-1)*20;
calllib('DMD','DLP_RegIO_WriteImageOrderLut',1,ExpStruct.whitenoiseframeorder(:,ExpStruct.sweep_counter), length(ExpStruct.whitenoiseframeorder(:,ExpStruct.sweep_counter)));    
ExpStruct.trackplayseed(ExpStruct.sweep_counter)=ExpStruct.lastseed;
toc

% %20 frames, variable sparsenesss
% ExpStruct.spchoose(:,ExpStruct.sweep_counter)=randi(length(ExpStruct.lastsparseness),20,1);
% % ExpStruct.spchoose(:,ExpStruct.sweep_counter)=randi(10,20,1);
% ExpStruct.sparseness(:,ExpStruct.sweep_counter)=ExpStruct.lastsparseness(ExpStruct.spchoose(:,ExpStruct.sweep_counter));
% ExpStruct.whitenoiseframeorder(:,ExpStruct.sweep_counter) = randi(10,[20 1])+ExpStruct.playstart+(ExpStruct.spchoose(:,ExpStruct.sweep_counter)-1)*10;
% calllib('DMD','DLP_RegIO_WriteImageOrderLut',1,ExpStruct.whitenoiseframeorder(:,ExpStruct.sweep_counter), length(ExpStruct.whitenoiseframeorder(:,ExpStruct.sweep_counter)));    
% ExpStruct.trackplayseed(ExpStruct.sweep_counter)=ExpStruct.lastseed;
% toc



%load current partition of buffer
tic
    for i = 1:20
    frameToload=ExpStruct.bufferloadcounter*20+i;
    mask = zeros(size(ExpStruct.wgngridmask));
    noise = resizem(ExpStruct.currentStimtoLoad{frameToload},[ExpStruct.wgngrid.totalheight ExpStruct.wgngrid.totalwidth]);
    mask(ceil(ExpStruct.wgngrid.top:ExpStruct.wgngrid.bottom-1),ceil(ExpStruct.wgngrid.left:ExpStruct.wgngrid.right-1))=noise;
    finalmask = zeros(1024,768);
    finalmask(padleft+1:padleft+660,padtop+1:padtop+480)=(mask');
    x = bi2de(reshape(finalmask,8,98304)');
    calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',x,98304,ExpStruct.bufferstart+frameToload);
    end
toc

ExpStruct.trackloadcounter(workingsweep)=ExpStruct.bufferloadcounter;
ExpStruct.bufferloadcounter=ExpStruct.bufferloadcounter+1;
ExpStruct.noiseloadseed(workingsweep)=ExpStruct.currentseed;

    




updateAOaxes