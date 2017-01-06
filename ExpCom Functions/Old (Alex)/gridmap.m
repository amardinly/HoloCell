function gridmap()
global ExpStruct Exp_Defaults LED Ramp h window a

if isempty(ExpStruct.gridmaporder);
    ExpStruct.gridmapcount = 0;    
    for i = 1:100
    ExpStruct.gridmaporder = [ExpStruct.gridmaporder randperm(size(ExpStruct.grid.maskbinary,2))];
    end
end

% white = WhiteIndex(window); % pixel value for white
% black = BlackIndex(window); % pixel value for black
        
ExpStruct.gridmapcount = ExpStruct.gridmapcount+1;
ExpStruct.gridmap(ExpStruct.sweep_counter)=ExpStruct.gridmaporder(ExpStruct.sweep_counter);


ExpStruct.gridmapframeorder(:,ExpStruct.sweep_counter) = randi(624,[1 500]);
calllib('DMD','DLP_RegIO_WriteImageOrderLut',1,ExpStruct.gridmapframeorder(:,ExpStruct.sweep_counter), length(ExpStruct.gridmapframeorder(:,ExpStruct.sweep_counter)))


% Screen(window, 'FillRect',black);

% masktexture = Screen(window, 'MakeTexture',ExpStruct.gmask(:,:,ExpStruct.gridmaporder(ExpStruct.sweep_counter)));
% % Screen('DrawTexture', window, masktexture); % put image on screen
% % Screen(window, 'Flip');    
% xoffset = 10;
% yoffset = -70;
% finalmask=[];
% xborder = 1024-650;
% % xborder = 1024-475;
% padleft = round(xborder/2+xoffset);
% padright = xborder-padleft;
% yborder = 768-475;
% % yborder = 768-650;
% padtop = round(yborder/2+yoffset);
% padbottom = yborder-padtop;
% 
% finalmask = zeros(1024,768);
% 
% finalmask(padleft+1:padleft+650,padtop+1:padtop+475)=(ExpStruct.gmask(:,:,ExpStruct.gridmaporder(ExpStruct.sweep_counter)))/255;
% x=reshape(finalmask,8,98304)';
% final = bi2de(x);
% calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',final,98304,0);



calllib('DMD','DLP_RegIO_WriteImageOrderLut',1, ExpStruct.gridmaporder(ExpStruct.sweep_counter), 1);
calllib('DMD','DLP_Display_DisplayPatternManualForceFirstPattern');

end
