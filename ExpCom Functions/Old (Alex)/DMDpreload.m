function DMDpreload

global ExpStruct Exp_Defaults LED Ramp h window a sweeps

load('DMDsaveFile');

ExpStruct.currentrate=currentrate;
ExpStruct.currentsparseness=currentsparseness;
ExpStruct.numSpar=numSpar;
ExpStruct.numRate=numRate;
ExpStruct.framesPerspar=framesPerspar;
ExpStruct.totalBufferlength=totalBufferlength;
ExpStruct.currentseed=currentseed;                
ExpStruct.noisecount = noisecount;
ExpStruct.bufferstart = bufferstart;
ExpStruct.bufferloadcounter=bufferloadcounter;     
ExpStruct.condcount=condcount;
ExpStruct.wgngrid=wgngrid;
ExpStruct.wgngridmask=wgngridmask;
end