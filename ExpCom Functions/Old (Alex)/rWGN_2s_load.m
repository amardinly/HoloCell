function rWGN_2s_load
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


 
if isfield(ExpStruct,'noisecount') ==0
ExpStruct.currentrWGNrandomlightparams=str2num(get(h.custom_sequence,'String'));
   
    %load up front of buffer if first trial
    ExpStruct.currentseed=1;       
    ss = RandStream('mt19937ar','Seed',ExpStruct.currentseed);
    reset(ss,ExpStruct.currentseed) 
    for i = 1:400
    y = wgn(ExpStruct.wgngrid.numrow,ExpStruct.wgngrid.numcol,1,1,ss);
    y(y<ExpStruct.currentrWGNrandomlightparams)=0;
    y(y>=ExpStruct.currentrWGNrandomlightparams)=1;
    ExpStruct.currentStimtoLoad{i}=y;
    end
    
    ExpStruct.stimarchive{workingsweep-1}=ExpStruct.currentStimtoLoad;
    
    for i = 1:400
    frameToload=i;
    mask = zeros(size(ExpStruct.wgngridmask));
    noise = resizem(ExpStruct.currentStimtoLoad{frameToload},[ExpStruct.wgngrid.totalheight ExpStruct.wgngrid.totalwidth]);
    mask(ExpStruct.wgngrid.top:ExpStruct.wgngrid.bottom-1,ExpStruct.wgngrid.left:ExpStruct.wgngrid.right-1)=noise;
    finalmask = zeros(1024,768);
    finalmask(padleft+1:padleft+660,padtop+1:padtop+480)=(mask');
    x = bi2de(reshape(finalmask,8,98304)');
    calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',x,98304,frameToload);
    waitbar(i/400)
    end
    
    
       
    ExpStruct.lastseed =ExpStruct.currentseed;
    ExpStruct.lastrWGNrandomlightparams=ExpStruct.currentrWGNrandomlightparams;
    ExpStruct.noisecount = 0;
    ExpStruct.noiseseed=[];
    ExpStruct.bufferstart = 0;
    ExpStruct.bufferloadcounter=40; 
    
end


ExpStruct.noisecount = ExpStruct.noisecount+1;

%check if buffer is full
if ExpStruct.bufferloadcounter==40;
    
    ExpStruct.lastseed =ExpStruct.currentseed;
    ExpStruct.lastrWGNrandomlightparams=ExpStruct.currentrWGNrandomlightparams;
    ExpStruct.currentrWGNrandomlightparams=str2num(get(h.custom_sequence,'String'));
    ExpStruct.currentseed=randi(10000);       
    ss = RandStream('mt19937ar','Seed',ExpStruct.currentseed);
    reset(ss,ExpStruct.currentseed) 
        %generate new stimuli set
        for i = 1:400
        y = wgn(ExpStruct.wgngrid.numrow,ExpStruct.wgngrid.numcol,1,1,ss);
        y(y<ExpStruct.currentrWGNrandomlightparams)=0;
        y(y>=ExpStruct.currentrWGNrandomlightparams)=1;
        ExpStruct.currentStimtoLoad{i}=y;
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


%load current partition of buffer

    for i = 1:10
    frameToload=ExpStruct.bufferloadcounter*10+i;
    mask = zeros(size(ExpStruct.wgngridmask));
    noise = resizem(ExpStruct.currentStimtoLoad{frameToload},[ExpStruct.wgngrid.totalheight ExpStruct.wgngrid.totalwidth]);
    mask(ExpStruct.wgngrid.top:ExpStruct.wgngrid.bottom-1,ExpStruct.wgngrid.left:ExpStruct.wgngrid.right-1)=noise;
    finalmask = zeros(1024,768);
    finalmask(padleft+1:padleft+660,padtop+1:padtop+480)=(mask');
    x = bi2de(reshape(finalmask,8,98304)');
    calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',x,98304,ExpStruct.bufferstart+frameToload);
    end


ExpStruct.trackloadcounter(workingsweep)=ExpStruct.bufferloadcounter;
ExpStruct.bufferloadcounter=ExpStruct.bufferloadcounter+1;
ExpStruct.noiseloadseed(workingsweep)=ExpStruct.currentseed;
ExpStruct.trackrWGNrandomlightloadparams(workingsweep)=ExpStruct.currentrWGNrandomlightparams;
    


%set up frame order for next sweep
ExpStruct.whitenoiseframeorder(:,workingsweep) = randi(400,[1 50])+ExpStruct.playstart;
calllib('DMD','DLP_RegIO_WriteImageOrderLut',1,ExpStruct.whitenoiseframeorder(:,workingsweep), length(ExpStruct.whitenoiseframeorder(:,workingsweep)));    
ExpStruct.trackplayseed(workingsweep)=ExpStruct.lastseed;
ExpStruct.trackrWGNrandomlightplayparams(workingsweep)=ExpStruct.lastrWGNrandomlightparams;


% % % make random light pattern
% ExpStruct.LEDoutput1=zeros(size(ExpStruct.LEDoutput1));
% trialStart = 1000;
% j = randi([0 10],1,200);
% % j(j<=5)=5;
% j(j>=6)=0;
% 
% for b = 1:length(j)
% thisStart=(trialStart+(b-1)*5)*20;
% ExpStruct.LEDoutput1(thisStart:thisStart+99)=j(b);
% end



% make random light pattern
ExpStruct.LEDoutput1=zeros(size(ExpStruct.LEDoutput1));
trialStart = 500;
j = randi([0 19],1,50);

for b = 1:length(j)
thisStart=(trialStart+(b-1)*20+j(b))*20;
thisEnd=thisStart+randi([0 10])*20; 
ExpStruct.LEDoutput1(thisStart:thisEnd)=4;
end


updateAOaxes