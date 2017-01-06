function DMDload(frameNumber,image)
%% This will load a one bit image or binary into the DMD buffer
%Inputs:
%frameNumber: scalar ranging from 0:959
%image: one bit double or binary, must be 1024 x 768
    x = bi2de(reshape(image,8,98304)');
    calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',x,98304,frameNumber);
end