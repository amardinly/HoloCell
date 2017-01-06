function VSRM2
global ExpStruct Exp_Defaults LED Ramp h window a sweeps

tic
workingsweep = ExpStruct.sweep_counter+1 

xborder = 1024-660;
padleft = floor((xborder)/2+ExpStruct.xoffset);
padright = xborder-padleft;
yborder = 768-480;
padtop = round((yborder)/2+ExpStruct.yoffset);
padbottom = yborder-padtop;

    
calllib('DMD','DLP_Source_SetDataSource','SL_EXT3P3');
% ExpStruct.currentsparseness=[0.1 0.2 0.5:0.5:10 11:20 22:2:40 60 100];

ExpStruct.currentrate=[1 5:5:45];
ExpStruct.currentsparseness=str2num(get(h.custom_sequence,'String'));
ExpStruct.numSpar=length(ExpStruct.currentsparseness);
ExpStruct.numRate=length(ExpStruct.currentrate);
ExpStruct.framesPerspar=floor(22/ExpStruct.numSpar)*20;
ExpStruct.totalBufferlength=ExpStruct.numSpar*ExpStruct.framesPerspar;



if isfield(ExpStruct,'noisecount') ==0

   
%load up front of buffer if first trial
    ExpStruct.currentseed=1;       
    ss = RandStream('mt19937ar','Seed',ExpStruct.currentseed);
    reset(ss,ExpStruct.currentseed) 
          
    for j=1:length(ExpStruct.currentsparseness)        
        for i = 1:ExpStruct.framesPerspar
        y = randi(ss,1000,ExpStruct.wgngrid.numrow,ExpStruct.wgngrid.numcol);
        y=y/10;
        y = (y<=ExpStruct.currentsparseness(j));    
        ExpStruct.currentStimtoLoad{i+(j-1)*ExpStruct.framesPerspar}=y;
        end
    end
    
    ExpStruct.stimarchive{workingsweep-1}=ExpStruct.currentStimtoLoad;    
    for i = 1:ExpStruct.totalBufferlength
    frameToload=i;
    mask = zeros(size(ExpStruct.wgngridmask));
    noise = resizem(ExpStruct.currentStimtoLoad{frameToload},[ExpStruct.wgngrid.totalheight ExpStruct.wgngrid.totalwidth]);
    mask(ceil(ExpStruct.wgngrid.top:ExpStruct.wgngrid.bottom-1),ceil(ExpStruct.wgngrid.left:ExpStruct.wgngrid.right-1))=noise;
    finalmask = zeros(1024,768);
    finalmask(padleft+1:padleft+660,padtop+1:padtop+480)=(mask'); 

    DMDload(frameToload,finalmask);
    waitbar(i/400)
    end
    
    ExpStruct.lastseed =ExpStruct.currentseed;
    ExpStruct.lastsparseness=ExpStruct.currentsparseness;
    ExpStruct.noisecount = 0;
    ExpStruct.noiseseed=[];
    ExpStruct.bufferstart = 0;
    ExpStruct.bufferloadcounter=ceil(ExpStruct.totalBufferlength/20);     
    ExpStruct.condcount=zeros(ExpStruct.numSpar,ExpStruct.numRate);
    
end


ExpStruct.noisecount = ExpStruct.noisecount+1;

%check if buffer is full
if ExpStruct.bufferloadcounter>=(ExpStruct.totalBufferlength/20);    
    ExpStruct.lastseed =ExpStruct.currentseed;
    ExpStruct.lastsparseness=ExpStruct.currentsparseness;
    ExpStruct.currentseed=randi(10000);       
    ss = RandStream('mt19937ar','Seed',ExpStruct.currentseed);
    reset(ss,ExpStruct.currentseed) 
        %generate new stimuli set        
        for j=1:length(ExpStruct.currentsparseness)
            for i = 1:ExpStruct.framesPerspar
            y = randi(ss,1000,ExpStruct.wgngrid.numrow,ExpStruct.wgngrid.numcol);
            y=y/10;
            y = (y<=ExpStruct.currentsparseness(j));          
            ExpStruct.currentStimtoLoad{i+(j-1)*ExpStruct.framesPerspar}=y;
            end
        end        
        ExpStruct.stimarchive{workingsweep}=ExpStruct.currentStimtoLoad;                
        if ExpStruct.bufferstart == ExpStruct.totalBufferlength;
        newbufferstart=0;
        ExpStruct.playstart=ExpStruct.totalBufferlength;
        elseif ExpStruct.bufferstart == 0;
        newbufferstart=ExpStruct.totalBufferlength;
        ExpStruct.playstart=0;
        end        
        ExpStruct.bufferstart=newbufferstart;
        ExpStruct.bufferloadcounter=0;
end

toc



%load current partition of buffer
% tic
    for i = 1:20
    frameToload=ExpStruct.bufferloadcounter*20+i;
    mask = zeros(size(ExpStruct.wgngridmask));
    noise = resizem(ExpStruct.currentStimtoLoad{frameToload},[ExpStruct.wgngrid.totalheight ExpStruct.wgngrid.totalwidth]);
    mask(ceil(ExpStruct.wgngrid.top:ExpStruct.wgngrid.bottom-1),ceil(ExpStruct.wgngrid.left:ExpStruct.wgngrid.right-1))=noise;
    finalmask = zeros(1024,768);
    finalmask(padleft+1:padleft+660,padtop+1:padtop+480)=(mask');

    DMDload(frameToload+ExpStruct.bufferstart,finalmask);
    end
toc

ExpStruct.trackloadcounter(workingsweep)=ExpStruct.bufferloadcounter;
ExpStruct.bufferloadcounter=ExpStruct.bufferloadcounter+1;
ExpStruct.noiseloadseed(workingsweep)=ExpStruct.currentseed;

if ExpStruct.noisecount>0
ExpStruct.postSweepprogramChoice='VSRMpulseSetup';
end

% if ExpStruct.onlineAnalysis==1
%     for i = 1:2
%     ExpStruct.hz(i,ExpStruct.sweep_counter-1)= get_spike_times(sweeps{ExpStruct.sweep_counter-1}(i,1));
%     end
%     if ~ishold(h.analysis1_axes)
%         hold(h.analysis1_axes)
%     end
%     
%     plot(h.analysis1_axes,ExpStruct.sparseness{ExpStruct.sweep_counter-1},...
%         ExpStruct.hz(1,ExpStruct.sweep_counter-1),'o','Color',[ExpStruct.shuffle(ExpStruct.sweep_counter-1) 0 0]);
%     plot(h.analysis1_axes,ExpStruct.sparseness{ExpStruct.sweep_counter-1},...
%         ExpStruct.hz(2,ExpStruct.sweep_counter-1),'x','Color',[ExpStruct.shuffle(ExpStruct.sweep_counter-1) 0 0]);
% end


updateAOaxes