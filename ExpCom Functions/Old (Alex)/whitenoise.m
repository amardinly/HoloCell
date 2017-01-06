function whitenoise
global ExpStruct Exp_Defaults LED Ramp h window a

if isfield(ExpStruct,'noisecount') ==0
    ExpStruct.noisecount = 0;
    ExpStruct.noiseseed=[];
end
        
ExpStruct.noisecount = ExpStruct.noisecount+1;
ExpStruct.noiseseed(ExpStruct.sweep_counter)=ExpStruct.noisecount;

buffer = 0;
% for i = 1:buffer
% % final =zeros(98304,1)*255;
% % calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',final,98304,150)
% % end
% x = bi2de(zeros(8,98304));
% calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',x,98304,i-1);
% end
% x = bi2de(zeros(8,98304));
% calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',x,98304,150)

ss = RandStream('mt19937ar','Seed',ExpStruct.noisecount);
reset(ss,ExpStruct.noisecount) 
tic
for i = 1:25
% i = 1;
% y=randi(ss,25,48,64)-24;
y = wgn(48,64,1,1,ss);
% y=randi(ss,25,96,128)-24;
% y=randi(ss,6,192,256)-5;
% y=randi(ss,6,768,1024)-5;

y(y<2)=0;
y(y>=2)=1;

% imagesc(y)
x = bi2de(reshape(resizem(y,[768 1024])',8,98304)');
calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',x,98304,i+buffer-1);
% end
end
calllib('DMD','DLP_RegIO_WriteImageOrderLut',1, 0:24, 25)
% calllib('DMD','DLP_RegIO_WriteImageOrderLut',1, 0, 1)
toc