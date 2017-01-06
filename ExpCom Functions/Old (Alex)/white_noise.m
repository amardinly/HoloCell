%white noise

y = wgn(768,1024,1);
imagesc(y)

pixelsize = 1;
tic

for i = 1:100
y = wgn(round(768/pixelsize),round(1024/pixelsize),10);
y(y<4)=0;
y(y>=4)=1;
finalmask(:,:,i)=resizem(y,[768 1024]);
end
toc

ss = RandStream('mt19937ar','Seed',1);
reset(ss,1) 
for z = 1:50:960
tic
for i = 1:z
% y=randi(ss,4,48,64)-3;
% y=randi(s,4,384,512)-3;
% y(y<1)=0;
demo(:,:,i)=resizem(y,[768 1024]);
x = bi2de(reshape(resizem(y,[768 1024])',8,98304)');
calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',x,98304,i-1);
% waitbar(i/100)
end
timeelapsed(z)=toc;
end

for i = 1:10
    name = strcat('demo_image',num2str(i),'.bmp');
    imwrite(demo(:,:,i),name);
end


calllib('DMD','DLP_RegIO_WriteImageOrderLut',1, [0:99], 100)

for i = 1:size(finalmask,3)
x=reshape(finalmask(:,:,i)',8,98304)';
final(:,i) = bi2de(x);
end


s = RandStream('mt19937ar','Seed',1);
reset(s,1) 
for i = 1:100
y(:,:,i)=randi(s,4,48,64);
end
reset(s,1) 
for i = 1:100
x(:,:,i)=randi(s,4,48,64);
end
y-x

tic
for i = 1:60
calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',final(:,i),98304,i-1);
end
toc

calllib('DMD','DLP_RegIO_WriteImageOrderLut',1, [0:59], 60)
calllib('DMD','DLP_Display_DisplayPatternAutoStepRepeatForMultiplePasses') 

calllib('DMD','DLP_Display_DisplayStop')