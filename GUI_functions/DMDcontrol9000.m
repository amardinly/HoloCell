function varargout = DMDcontrol9000(varargin)
% DMDCONTROL9000 MATLAB code for DMDcontrol9000.fig
%      DMDCONTROL9000, by itself, creates a new DMDCONTROL9000 or raises the existing
%      singleton*.
%
%      H = DMDCONTROL9000 returns the handle to a new DMDCONTROL9000 or the handle to
%      the existing singleton*.
%
%      DMDCONTROL9000('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DMDCONTROL9000.M with the given input arguments.
%
%      DMDCONTROL9000('Property','Value',...) creates a new DMDCONTROL9000 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DMDcontrol9000_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DMDcontrol9000_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DMDcontrol9000

% Last Modified by GUIDE v2.5 29-Jun-2015 15:30:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DMDcontrol9000_OpeningFcn, ...
                   'gui_OutputFcn',  @DMDcontrol9000_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before DMDcontrol9000 is made visible.
function DMDcontrol9000_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DMDcontrol9000 (see VARARGIN)

% Choose default command line output for DMDcontrol9000
handles.output = hObject;

global ExpStruct dmd

newobjs=instrfind;
if ~isempty(newobjs)
    fclose(newobjs);  % only close if port was open
end
% open COM3 and associate with MP285
ExpStruct.MP285 = sutterMP285('COM3');
% setOrigin(ExpStruct.MP285)




% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DMDcontrol9000 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DMDcontrol9000_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in center_grid.
function center_grid_Callback(hObject, eventdata, handles)
% hObject    handle to center_grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct dmd

ExpStruct.gridmaporder=[];
if isfield(ExpStruct,'grid')
%     ExpStruct=rmfield(ExpStruct,'grid');
    ExpStruct.gridmapcount = 0;
    ExpStruct.gridmaporder=[];
    ExpStruct.gmask=[];
    ExpStruct.grid.maskbinary=[];
end

ExpStruct.gridmask= createMask(dmd.roi);
[row,col]=find(ExpStruct.gridmask);
ExpStruct.grid.top = row(1)+ExpStruct.grid.height/2;
ExpStruct.grid.bottom = row(end)-ExpStruct.grid.height/2;

ExpStruct.grid.left = col(1)+ExpStruct.grid.width/2;
ExpStruct.grid.right = col(end)-ExpStruct.grid.width/2;

%
% xborder = 768-ExpStruct.xdim;
% padleft = round(xborder/2+dmd.xoffset+400);
% padright = xborder-padleft;
% yborder = 1024-ExpStruct.ydim;
% padtop = round(yborder/2+dmd.yoffset+400);
% padbottom = yborder-padtop;
ExpStruct.grid.maskbinary=zeros(98304,ExpStruct.grid.numcol*ExpStruct.grid.numrow);
ExpStruct.grid.index=zeros(ExpStruct.grid.numrow,ExpStruct.grid.numcol);
count=0;


for i = 1:ExpStruct.grid.numcol
    for j = 1:ExpStruct.grid.numrow
        
        
        thistop = (ExpStruct.grid.top+(j-1)*ExpStruct.grid.spacing-ExpStruct.grid.height/2);
        thisbottom = (ExpStruct.grid.top+(j-1)*ExpStruct.grid.spacing+ExpStruct.grid.height/2);
        thisleft=(ExpStruct.grid.left+(i-1)*ExpStruct.grid.spacing-ExpStruct.grid.width/2);
        thisright=(ExpStruct.grid.left+(i-1)*ExpStruct.grid.spacing+ExpStruct.grid.width/2);
        testmask=zeros(ExpStruct.ydim,ExpStruct.xdim);
        testmask(thistop:thisbottom,thisleft:thisright)=1;

%         finalmask= zeros(1024,768);
%         finalmask = padarray(finalmask,[400 400]);
        
%         finalmask(padleft+thisleft:padleft+thisright,padtop+thistop:padtop+thisbottom)=1;    
        
%         finalmask = finalmask(401:1424,401:1168);
%         x=bi2de(reshape(finalmask,8,98304)');
        x=im2DMD(testmask);
        
        count = count+1;
        ExpStruct.grid.maskbinary(:,count) = x;        
        ExpStruct.grid.index(j,i)=count;
    end
    waitbar(i/ExpStruct.grid.numcol);
end


if size(ExpStruct.grid.maskbinary,2)<959
    for i = 1:size(ExpStruct.grid.maskbinary,2)
        calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',ExpStruct.grid.maskbinary(:,i),98304,i);
        waitbar(i/size(ExpStruct.grid.maskbinary,2))
    end
    calllib('DMD','DLP_Source_SetDataSource','SL_EXT3P3')
    
elseif size(ExpStruct.grid.maskbinary,2)>=959
    disp(['# of stimulation sites = ' num2str(size(ExpStruct.grid.maskbinary,2))])
    disp('Use OnlineGridMap')
end

ExpStruct.JGM.grid=ExpStruct.grid;
ExpStruct.JGM.gridmask=ExpStruct.gridmask;
ExpStruct.JGM.maskbinary=ExpStruct.grid.maskbinary;
ExpStruct.JGM.index=ExpStruct.grid.index;
beep
guidata(hObject,handles);


% --- Executes on button press in whitenoise.
function whitenoise_Callback(hObject, eventdata, handles)
% hObject    handle to whitenoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct dmd


pos = round(getPosition(dmd.roi));

xscalefactor = 1000/562.5;
yscalefactor = 200/109.0909;

ExpStruct.wgngrid.numcol=ExpStruct.grid.numcol;
ExpStruct.wgngrid.numrow=ExpStruct.grid.numrow;

ExpStruct.wgngridmask= createMask(dmd.roi);
[row,col]=find(ExpStruct.wgngridmask);
ExpStruct.wgngrid.top = row(1)+ExpStruct.grid.height/2;
ExpStruct.wgngrid.totalheight=ExpStruct.wgngrid.numrow*ExpStruct.grid.spacing;
ExpStruct.wgngrid.bottom = ExpStruct.wgngrid.top+ExpStruct.wgngrid.totalheight;
ExpStruct.wgngrid.left = col(1)+ExpStruct.grid.width/2;
ExpStruct.wgngrid.totalwidth=ExpStruct.wgngrid.numcol*ExpStruct.grid.spacing;
ExpStruct.wgngrid.right = ExpStruct.wgngrid.left+ExpStruct.wgngrid.totalwidth;



set(gca,'xtick',[0 56.2500 112.5000 168.7500 225.0000 281.2500 337.5000 393.7500 450.0000 506.2500 562.5000],...
    'xticklabel',{'0';'100';'200';'300';'400';'500';'600';'700';'800';'900';'1000'});
set(gca,'ytick',[0  109.0909  218.1818  327.2727  436.3636],'yticklabel',{'0';'200';'400';'600';'800'})



% --- Executes on button press in imageacq.
function imageacq_Callback(hObject, eventdata, handles)
% hObject    handle to imageacq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%image slice

global ExpStruct dmd

load('DMDcalibration.mat');
dmd.xoffset=xoffset;
dmd.yoffset=yoffset;

dmd.vhandle.vid = imaqfind;

ExpStruct.xoffset=xoffset;
ExpStruct.yoffset=yoffset;

dmd.objectivePosition=getPosition(ExpStruct.MP285);

if isempty(dmd.vhandle.vid)
    dmd.vhandle.vid = videoinput('winvideo', 1, 'YUY2_720x480');
    triggerconfig(dmd.vhandle.vid, 'manual');
    
    dmd.vhandle.vid.FramesPerTrigger = 1;
    start(dmd.vhandle.vid);
    dmd.vhandle.vid.ReturnedColorspace = 'grayscale';
end

temp=getsnapshot(dmd.vhandle.vid);
dmd.sliceshot = temp(:,4:716);
colormap('gray');
% ExpStruct.ydim=484; %old config with 5x, 20cm 1 inch lens
% ExpStruct.xdim=664;
%with 5x, 20 cm 2inch lens
% ExpStruct.ydim=420;
% ExpStruct.xdim=576;
% ExpStruct.ydim=1024;
% ExpStruct.xdim=768;
ExpStruct.ydim=712;
ExpStruct.xdim=520;


dmd.bigslice = resizem(rot90(dmd.sliceshot),[ExpStruct.ydim,ExpStruct.xdim]);


dmd.im=imagesc(dmd.bigslice,'Parent',dmd.axes1);


% axis image

if ~isfield(dmd,'currentimageno')
    dmd.currentimageno=1;
end

dmd.mask = zeros(size(dmd.bigslice));
imagesc(dmd.mask,'Parent',dmd.axes2);

relabel_axes1

guidata(hObject,handles)
relabel_axes1

% --- Executes on button press in saveimage.
function saveimage_Callback(hObject, eventdata, handles)
% hObject    handle to saveimage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct dmd

if isfield(ExpStruct,'sliceimage')== 0
    ExpStruct.sliceimage = {};
    ExpStruct.sliceimage{1} = dmd.bigslice;
    ExpStruct.sliceImagecoordinates{1}= dmd.objectivePosition;
    ExpStruct.NormsliceImagecoordinates{1}= [0;0;0];
    changeimage(1);
elseif isfield(ExpStruct,'sliceimage')
    imageno=length(ExpStruct.sliceimage)+1;
    ExpStruct.sliceImagecoordinates{imageno}= dmd.objectivePosition;
    ExpStruct.NormsliceImagecoordinates{imageno}=ExpStruct.sliceImagecoordinates{imageno}-ExpStruct.sliceImagecoordinates{1};
    ExpStruct.sliceimage{imageno} = dmd.bigslice;
    changeimage(imageno);
    
end




% --- Executes on button press in DMDmask.
function DMDmask_Callback(hObject, eventdata, handles)
% hObject    handle to DMDmask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global dmd ExpStruct



% xborder = 768-ExpStruct.xdim;
% padleft = round(xborder/2+dmd.xoffset)+200;
% rightborder=padleft+ExpStruct.xdim;
% 
% yborder = 1024-ExpStruct.ydim;
% padtop = round(yborder/2+dmd.yoffset)+200;
% bottomborder=padtop+ExpStruct.ydim;
% 
% 
% finalmask = zeros(1024,768);
% finalmask = padarray(finalmask,[200 200]);
% 
% 
% finalmask(padtop+1:bottomborder,padleft+1:rightborder)=(dmd.mask)/255;
% finalmask = finalmask(201:1224,201:968);
% 
% x=reshape(finalmask,8,98304)';

final=im2DMD(dmd.mask/255);

% final = bi2de(x);
calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',final,98304,0);
calllib('DMD','DLP_RegIO_WriteImageOrderLut',1, 0, 1);
calllib('DMD','DLP_Display_DisplayPatternManualForceFirstPattern')
guidata(hObject,handles)


function final=im2DMD(mask)
global dmd ExpStruct

xborder = 768-ExpStruct.xdim;
padleft = round(xborder/2+dmd.xoffset+400);
rightborder=padleft+ExpStruct.xdim;

yborder = 1024-ExpStruct.ydim;
padtop = round(yborder/2+dmd.yoffset+400);
bottomborder=padtop+ExpStruct.ydim;


finalmask = zeros(1024,768);
finalmask = padarray(finalmask,[400 400]);

finalmask(padtop+1:bottomborder,padleft+1:rightborder)=fliplr(mask);
finalmask = finalmask(401:1424,401:1168);

x=reshape(finalmask,8,98304)';
final = bi2de(x);


% --- Executes on button press in makemask.
function makemask_Callback(hObject, eventdata, handles)
% hObject    handle to makemask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dmd
pos = getPosition(dmd.roi)
temp= createMask(dmd.roi);
dmd.mask = dmd.mask+temp*255;
dmd.mask(dmd.mask>255)=255;
imagesc(((dmd.mask+255)/2).*dmd.bigslice,'Parent',dmd.axes1);
relabel_axes1

dmd.roi=imrect(dmd.axes1,pos)


guidata(hObject,handles)


% --- Executes on button press in savemask.
function savemask_Callback(hObject, eventdata, handles)
% hObject    handle to savemask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct dmd

if isfield(ExpStruct,'masks')== 0
    ExpStruct.masks = {};
    ExpStruct.masknames = {};
end

maskno= length(ExpStruct.masks)+1;

try
    pos = getPosition(dmd.roi);
    temp= createMask(dmd.roi);
    dmd.mask = dmd.mask+temp*255;
    dmd.mask(dmd.mask>255)=255;
    imagesc(((dmd.mask+255)/2).*dmd.bigslice,'Parent',dmd.axes1);
    relabel_axes1
    
    ExpStruct.maskcoords{maskno} = pos;
end

maskno= length(ExpStruct.masks)+1;
ExpStruct.masknames{maskno} = get(dmd.maskname,'String');
ExpStruct.masks{maskno} = dmd.mask;

set(dmd.masklist,'String',ExpStruct.masknames)


% finalmask=[];
% 
% xborder = 768-ExpStruct.xdim;
% padleft = round(xborder/2+dmd.xoffset);
% padright = xborder-padleft;
% 
% yborder = 1024-ExpStruct.ydim;
% padtop = round(yborder/2+dmd.yoffset);
% padbottom = yborder-padtop;

guidata(hObject,handles)


% --- Executes on button press in loadmask.
function loadmask_Callback(hObject, eventdata, handles)
% hObject    handle to loadmask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct dmd
dmd.mask = zeros(size(dmd.bigslice));
dmd.mask = ExpStruct.masks{get(dmd.masklist,'Value')};
imagesc(((dmd.mask+255)/2).*dmd.bigslice,'Parent',dmd.axes1);
relabel_axes1


guidata(hObject,handles);



% --- Executes on button press in deletemasks.
function deletemasks_Callback(hObject, eventdata, handles)
% hObject    handle to deletemasks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.masks={};
ExpStruct.masknames={};





% --- Executes on button press in load_ROI.
function load_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to load_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global ExpStruct dmd

temp = ExpStruct.masks{get(dmd.masklist,'Value')};
[row,col]=find(temp)
top = row(1);
bottom = row(end);
left = col(1);
right = col(end);
height = bottom-top;
width = right-left;
pos = [left top width height];
dmd.roi=imrect(dmd.axes1,pos)


relabel_axes1

guidata(hObject,handles);

% --- Executes on button press in clear.
function clear_Callback(hObject, eventdata, handles)
% hObject    handle to clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dmd

dmd.mask = zeros(size(dmd.bigslice));
imagesc(((dmd.mask+255)/2).*dmd.bigslice,'Parent',dmd.axes1);
relabel_axes1


guidata(hObject,handles)


function changeimage(x)
global ExpStruct dmd

imagesc(ExpStruct.sliceimage{round(x)},'Parent',dmd.axes1);
dmd.currentimageno=x;
colormap('gray');
set(dmd.imagenumber, 'String',num2str(x));
set(dmd.slider1,'Value',x);

set(dmd.xcoordinates,'String',num2str(ExpStruct.NormsliceImagecoordinates{x}(1)))
set(dmd.ycoordinates,'String',num2str(ExpStruct.NormsliceImagecoordinates{x}(2)))
set(dmd.zcoordinates,'String',num2str(ExpStruct.NormsliceImagecoordinates{x}(3)))
relabel_axes1


function relabel_axes1

global dmd

%make this changeable later for different objectives
% scalefactor=20/11;
% scalefactor=10/11;
scalefactor=dmd.scalefactor;

intendedXticks=100:100:900;
DMDspacexticks=round((intendedXticks)/scalefactor);
set(dmd.axes1,'xtick',DMDspacexticks);
set(dmd.axes1,'xticklabel',cellstr(num2str(intendedXticks')));

intendedYticks=100:100:1200;
DMDspaceyticks=round((intendedYticks)/scalefactor);
set(dmd.axes1,'ytick',DMDspaceyticks);
set(dmd.axes1,'yticklabel',cellstr(num2str(intendedYticks')));
axis image




% --- Executes on button press in polygon.
function polygon_Callback(hObject, eventdata, handles)
% hObject    handle to polygon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global dmd
% handles.roi=impoly(handles.hparent);
dmd.roi=impoly(dmd.axes1);
temp= createMask(dmd.roi);
dmd.mask = dmd.mask+temp*255;
dmd.mask(dmd.mask>255)=255;
imagesc(((dmd.mask+255)/2).*dmd.bigslice,'Parent',dmd.axes1);
relabel_axes1

guidata(hObject,handles)

% --- Executes on button press in rectangle.
function rectangle_Callback(hObject, eventdata, handles)
% hObject    handle to rectangle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct dmd
ExpStruct.gridmaporder=[];
if isfield(ExpStruct,'grid')
    rmfield(ExpStruct,'grid');
    ExpStruct.gridmapcount = 0;
    ExpStruct.gridmaporder=[];
    ExpStruct.gmask=[];
    ExpStruct.grid.maskbinary=[];
end

dmd.gmask=[];
dmd.roi=imrect(dmd.axes1);
addNewPositionCallback(dmd.roi,@updateDMDroi);
pos = round(getPosition(dmd.roi));
updateDMDroi(pos);
guidata(hObject,handles);


relabel_axes1


guidata(hObject,handles)

% --- Executes on button press in ellipse.
function ellipse_Callback(hObject, eventdata, handles)
% hObject    handle to ellipse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dmd

dmd.roi=imellipse(dmd.axes1);
temp= createMask(dmd.roi);
dmd.mask = dmd.mask+temp*255;
dmd.mask(dmd.mask>255)=255;
imagesc(((dmd.mask+255)/2).*dmd.bigslice,'Parent',dmd.axes1);
relabel_axes1

guidata(hObject,handles)



% --- Executes on selection change in masklist.
function masklist_Callback(hObject, eventdata, handles)
% hObject    handle to masklist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns masklist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from masklist


% --- Executes during object creation, after setting all properties.
function masklist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to masklist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maskname_Callback(hObject, eventdata, handles)
% hObject    handle to maskname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maskname as text
%        str2double(get(hObject,'String')) returns contents of maskname as a double


% --- Executes during object creation, after setting all properties.
function maskname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maskname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes on button press in calibrate.
function calibrate_Callback(hObject, eventdata, handles)
% hObject    handle to calibrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dmd ExpStruct


% xoffset = dmd.xoffset;
% yoffset = dmd.yoffset;

dmd.xoffset = 0;
dmd.yoffset = 0;


% 
% finalmask=[];
% xborder = 768-ExpStruct.xdim;
% padleft = round(xborder/2+xoffset);
% yborder = 1024-ExpStruct.ydim;
% padtop = round(yborder/2+yoffset);
% finalmask = zeros(1024,768);
testmask = zeros(ExpStruct.ydim,ExpStruct.xdim);
% testmask(400,400) = 1;
% testmask(295:305,295:305) = 1;
testmask(399:401,299:301) = 1;

% testmask(455:555,455:555) = 1;
% finalmask(padleft+1:padleft+ExpStruct.xdim,padtop+1:padtop+ExpStruct.ydim)= testmask;
% finalmask(padtop+1:padtop+ExpStruct.ydim,padleft+1:padleft+ExpStruct.xdim)= testmask';
% x=reshape(finalmask,8,98304)';
final=im2DMD(testmask);


% final = bi2de(x);
calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',final',98304,0);
calllib('DMD','DLP_RegIO_WriteImageOrderLut',1, 0, 1);
calllib('DMD','DLP_Source_SetDataSource','SL_AUTO')
calllib('DMD','DLP_Display_DisplayPatternManualForceFirstPattern')
pause(0.1)
dmd.vhandle.vid = imaqfind;
temp = getsnapshot(dmd.vhandle.vid);
dmd.sliceshot=temp(:,4:716);
colormap('gray');
dmd.bigslice = resizem(rot90(dmd.sliceshot),[ExpStruct.ydim ExpStruct.xdim]);

dmd.im=imagesc(dmd.bigslice,'Parent',dmd.axes1);


point1 = impoint

error(1,:) = [300 400]-getPosition(point1)
delete(point1);

yoffset = error(:,2)
% yoffset =0
dmd.yoffset=yoffset;

xoffset = -error(:,1)
% xoffset=0;
% xoffset = 125
dmd.xoffset=xoffset;

save('DMDcalibration.mat','yoffset','xoffset')

% finalmask=[];
% xborder = 768-ExpStruct.xdim;
% padleft = round(xborder/2+dmd.xoffset);
% yborder = 1024-ExpStruct.ydim;
% padtop = round(yborder/2+dmd.yoffset);
% finalmask = zeros(1024,768);
testmask = zeros(ExpStruct.ydim,ExpStruct.xdim);
testmask(499:501,399:401) = 1;

% finalmask(padleft+1:padleft+ExpStruct.xdim,padtop+1:padtop+ExpStruct.ydim)= testmask;
% finalmask(padtop+1:padtop+ExpStruct.ydim,padleft+1:padleft+ExpStruct.xdim)= testmask';
% x=reshape(finalmask,8,98304)';
% final = bi2de(x);

final = im2DMD(testmask);
calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',final,98304,0);
calllib('DMD','DLP_RegIO_WriteImageOrderLut',1, 0, 1);
calllib('DMD','DLP_Display_DisplayPatternManualForceFirstPattern')
pause(0.1)
temp = getsnapshot(dmd.vhandle.vid);
dmd.sliceshot=temp(:,4:716);
colormap('gray');
dmd.bigslice = resizem(rot90(dmd.sliceshot),[ExpStruct.ydim ExpStruct.xdim]);
dmd.im=imagesc(dmd.bigslice,'Parent',dmd.axes1);
point3 = impoint;
getPosition(point3)
finalerror = [400 500]-getPosition(point3)

guidata(hObject,handles);


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
changeimage(get(hObject,'Value'))
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function imagenumber_Callback(hObject, eventdata, handles)
% hObject    handle to imagenumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of imagenumber as text
%        str2double(get(hObject,'String')) returns contents of imagenumber as a double


% --- Executes during object creation, after setting all properties.
function imagenumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imagenumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function spacingtext_Callback(hObject, eventdata, handles)
% hObject    handle to spacingtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dmd
updateDMDroi(getPosition(dmd.roi));
% Hints: get(hObject,'String') returns contents of spacingtext as text
%        str2double(get(hObject,'String')) returns contents of spacingtext as a double


% --- Executes during object creation, after setting all properties.
function spacingtext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spacingtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function heighttext_Callback(hObject, eventdata, handles)
% hObject    handle to heighttext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dmd

updateDMDroi(getPosition(dmd.roi));
% Hints: get(hObject,'String') returns contents of heighttext as text
%        str2double(get(hObject,'String')) returns contents of heighttext as a double


% --- Executes during object creation, after setting all properties.
function heighttext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to heighttext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function widthtext_Callback(hObject, eventdata, handles)
% hObject    handle to widthtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dmd

updateDMDroi(getPosition(dmd.roi));
% Hints: get(hObject,'String') returns contents of widthtext as text
%        str2double(get(hObject,'String')) returns contents of widthtext as a double


% --- Executes during object creation, after setting all properties.
function widthtext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to widthtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Hint: get(hObject,'Value') returns toggle state of makemask






function map_sweeps_Callback(hObject, eventdata, handles)
% hObject    handle to map_sweeps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of map_sweeps as text
%        str2double(get(hObject,'String')) returns contents of map_sweeps as a double


% --- Executes during object creation, after setting all properties.
function map_sweeps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to map_sweeps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in calc_map.
function calc_map_Callback(hObject, eventdata, handles)
% hObject    handle to calc_map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dmd
if dmd.type_disp_no==1|2
    JGM_calc_map(dmd.cell_disp_no,dmd.type_disp_no);
elseif dmd.type_disp_no==3
    JGM_calc_map_spike(dmd.cell_disp_no);
end


% --- Executes when selected object is changed in cell_selection_panel.
function cell_selection_panel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in cell_selection_panel
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global dmd
switch get(eventdata.NewValue,'Tag')
    case 'Cell1disp'
        dmd.cell_disp_no=1;
    case 'Cell2disp'
        dmd.cell_disp_no=2;
end


% --- Executes when selected object is changed in map_type_panel.
function map_type_panel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in map_type_panel
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global dmd
switch get(eventdata.NewValue,'Tag')
    case 'charge'
        dmd.type_disp_no=1;
    case 'current'
        dmd.type_disp_no=2;
    case 'spikes'
        dmd.type_disp_no=2;
end


% --- Executes on button press in auto_update.
function auto_update_Callback(hObject, eventdata, handles)
% hObject    handle to auto_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of auto_update


% --- Executes on button press in merge_map.
function merge_map_Callback(hObject, eventdata, handles)
% hObject    handle to merge_map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct dmd
% scalefactor=20/11;
% scalefactor=10/11;
% scalefactor=0.94;
scalefactor=dmd.scalefactor

if ~isfield(ExpStruct,'mapmerge')
    ExpStruct.mapmerge.origin=ExpStruct.sliceImagecoordinates{dmd.currentimageno};
    ExpStruct.mapmerge.map=resizem(ExpStruct.sliceimage{dmd.currentimageno},scalefactor);
    ExpStruct.mapmerge.mapind=dmd.currentimageno;
    ExpStruct.mapmerge.coord(:,1)=[0;0;0];
else
    %find total mapsize
    ExpStruct.mapmerge.mapind=[ExpStruct.mapmerge.mapind dmd.currentimageno];
    imdim=size(resizem(ExpStruct.sliceimage{dmd.currentimageno},scalefactor));
    ExpStruct.mapmerge.coord(:,length(ExpStruct.mapmerge.mapind))=ExpStruct.sliceImagecoordinates{dmd.currentimageno}-ExpStruct.mapmerge.origin;
    gleftbound=floor(min(ExpStruct.mapmerge.coord(1,:))-imdim(2)/2);
    grightbound=ceil(max(ExpStruct.mapmerge.coord(1,:))+imdim(2)/2);
    gtopbound=floor(min(ExpStruct.mapmerge.coord(2,:))-imdim(1)/2);
    gbottombound=ceil(max(ExpStruct.mapmerge.coord(2,:))+imdim(1)/2);
    
    template=zeros(gbottombound-gtopbound,grightbound-gleftbound);
    for i = 1:length(ExpStruct.mapmerge.mapind)
        imleft=floor(ExpStruct.mapmerge.coord(1,i)-imdim(2)/2)-gleftbound+1;
        %         imleft=floor(-ExpStruct.mapmerge.coord(1,ExpStruct.mapmerge.mapind(i)))-gleftbound+1
        %         imleft=floor(ExpStruct.mapmerge.coord(1,ExpStruct.mapmerge.mapind(i)))+1;
        imright=imleft+imdim(2)-1;
        imtop=floor(ExpStruct.mapmerge.coord(2,i)-imdim(1)/2)-gtopbound+1;
        %         imtop=floor(ExpStruct.mapmerge.coord(2,ExpStruct.mapmerge.mapind(i)))+1;
        imbot=imtop+imdim(1)-1;
        ExpStruct.mapmerge.mapboundaries(i,:)= [imleft imright imtop imbot];
        template(imtop:imbot,imleft:imright)=resizem(ExpStruct.sliceimage{ExpStruct.mapmerge.mapind(i)},scalefactor);
    end
    ExpStruct.mapmerge.map=template;

    
end

% --- Executes on button press in clear_map.
function clear_map_Callback(hObject, eventdata, handles)
% hObject    handle to clear_map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct dmd
ExpStruct=rmfield(ExpStruct,'mapmerge');


% --- Executes on button press in show_mergemap.
function show_mergemap_Callback(hObject, eventdata, handles)
% hObject    handle to show_mergemap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct dmd

imagesc(ExpStruct.mapmerge.map,'Parent',dmd.axes2);
axis image


% --- Executes on button press in fullgrid.
function fullgrid_Callback(hObject, eventdata, handles)
% hObject    handle to fullgrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct dmd

ExpStruct.gridmaporder=[];
if isfield(ExpStruct,'grid')
%     rmfield(ExpStruct,'grid');
    ExpStruct.gridmapcount = 0;
    ExpStruct.gridmaporder=[];
    ExpStruct.gmask=[];
    ExpStruct.grid.maskbinary=[];
end

% ExpStruct.gridmask= createMask(dmd.roi);
% [row,col]=find(ExpStruct.gridmask);
ExpStruct.grid.top = 1+ExpStruct.grid.height/2;
ExpStruct.grid.bottom = ExpStruct.ydim-ExpStruct.grid.height/2;
ExpStruct.grid.left = 1+ExpStruct.grid.width/2;
ExpStruct.grid.right = ExpStruct.xdim-ExpStruct.grid.width/2;

ExpStruct.grid.numcol = round((ExpStruct.xdim-ExpStruct.grid.width)/ExpStruct.grid.spacing);
ExpStruct.grid.numrow = round((ExpStruct.ydim-ExpStruct.grid.height)/ExpStruct.grid.spacing);

xborder = 768-ExpStruct.xdim;
padleft = round(xborder/2+dmd.xoffset);
padright = xborder-padleft;
yborder = 1024-ExpStruct.ydim;
padtop = round(yborder/2+dmd.yoffset);
padbottom = yborder-padtop;
ExpStruct.grid.maskbinary=zeros(98304,ExpStruct.grid.numcol*ExpStruct.grid.numrow);
ExpStruct.grid.index=zeros(ExpStruct.grid.numrow,ExpStruct.grid.numcol);
count=0;

for i = 1:ExpStruct.grid.numcol
    for j = 1:ExpStruct.grid.numrow      
        thistop = (ExpStruct.grid.top+(j-1)*ExpStruct.grid.spacing-ExpStruct.grid.height/2);
        thisbottom = (ExpStruct.grid.top+(j-1)*ExpStruct.grid.spacing+ExpStruct.grid.height/2);
        thisleft=(ExpStruct.grid.left+(i-1)*ExpStruct.grid.spacing-ExpStruct.grid.width/2);
        thisright=(ExpStruct.grid.left+(i-1)*ExpStruct.grid.spacing+ExpStruct.grid.width/2);
        
         
        thistop = (ExpStruct.grid.top+(j-1)*ExpStruct.grid.spacing-ExpStruct.grid.height/2);
        thisbottom = (ExpStruct.grid.top+(j-1)*ExpStruct.grid.spacing+ExpStruct.grid.height/2);
        thisleft=(ExpStruct.grid.left+(i-1)*ExpStruct.grid.spacing-ExpStruct.grid.width/2);
        thisright=(ExpStruct.grid.left+(i-1)*ExpStruct.grid.spacing+ExpStruct.grid.width/2);
        testmask=zeros(ExpStruct.ydim,ExpStruct.xdim);
        testmask(thistop:thisbottom,thisleft:thisright)=1;

        x=im2DMD(testmask);
      
        count = count+1;
        ExpStruct.grid.maskbinary(:,count) = x;        
        ExpStruct.grid.index(j,i)=count;
    end
    waitbar(i/ExpStruct.grid.numcol);
end

if size(ExpStruct.grid.maskbinary,2)<959
    for i = 1:size(ExpStruct.grid.maskbinary,2)
        calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',ExpStruct.grid.maskbinary(:,i),98304,i);
        waitbar(i/size(ExpStruct.grid.maskbinary,2))
    end
    calllib('DMD','DLP_Source_SetDataSource','SL_EXT3P3')
    
elseif size(ExpStruct.grid.maskbinary,2)>=959
    disp(['# of stimulation sites = ' num2str(size(ExpStruct.grid.maskbinary,2))])
    disp('Use OnlineGridMap')
end

ExpStruct.JGM.grid=ExpStruct.grid;
% ExpStruct.JGM.gridmask=ExpStruct.gridmask;
ExpStruct.JGM.gridmask=zeros(ExpStruct.ydim,ExpStruct.xdim);
ExpStruct.JGM.maskbinary=ExpStruct.grid.maskbinary;
ExpStruct.JGM.index=ExpStruct.grid.index;
beep
guidata(hObject,handles);




% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% delete(handles.vid);
% sca
% Hint: delete(hObject) closes the figure
delete(hObject);









% --- Executes on button press in grid.
function grid_Callback(hObject, eventdata, handles)
% hObject    handle to grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct dmd

ExpStruct.gridmaporder=[];

if isfield(ExpStruct,'gridmap')
    rmfield(ExpStruct,'gridmap');
    ExpStruct.gridmapcount = 0;
    ExpStruct.gmask=[];
    ExpStruct.grid.maskbinary=[];
end

dmd.gmask=[];
dmd.roi=imrect;
pause
pos = round(getPosition(dmd.roi));

prompt = {'Width','Height'};
dlg_title = 'Define grid unit dimensions';
num_lines = 1;
def = {'25','25'};
dim= inputdlg(prompt,dlg_title,num_lines,def);
xscalefactor = 1000/562.5;
% yscalefactor = 200/109.0909;
yscalefactor = xscalefactor;
ExpStruct.grid.width = round(str2num(dim{1})/xscalefactor);
ExpStruct.grid.height = round(str2num(dim{2})/yscalefactor);
ExpStruct.grid.numcol = round(pos(3)/ExpStruct.grid.width);
ExpStruct.grid.numrow = round(pos(4)/ExpStruct.grid.height);

ExpStruct.grid.grid = reshape(1:(ExpStruct.grid.numcol*ExpStruct.grid.numrow),ExpStruct.grid.numcol,ExpStruct.grid.numrow)';
temp= createMask(dmd.roi);
[row,col]=find(temp);
ExpStruct.grid.top = row(1);
ExpStruct.grid.bottom = row(end);
ExpStruct.grid.left = col(1);
ExpStruct.grid.right = col(end);


for i = 1:(ExpStruct.grid.numcol*ExpStruct.grid.numrow)
    [y x] =find(ExpStruct.grid.grid==i);
    mask = zeros(size(temp));
    mask((ExpStruct.grid.top+(y-1)*ExpStruct.grid.height):(ExpStruct.grid.top+y*ExpStruct.grid.height),(ExpStruct.grid.left+(x-1)*ExpStruct.grid.width):(ExpStruct.grid.left+(x)*ExpStruct.grid.width))=255;
    
    finalmask=[];
    xborder = 1024-664;
    padleft = round(xborder/2+dmd.xoffset);
    padright = xborder-padleft;
    yborder = 768-484;
    padtop = round(yborder/2+dmd.yoffset);
    padbottom = yborder-padtop;
    finalmask = zeros(1024,768);
    finalmask(padleft+1:padleft+660,padtop+1:padtop+480)=(mask');
    x=reshape(finalmask/255,8,98304)';
    ExpStruct.grid.maskbinary(:,i) = bi2de(x);
    
end

% ExpStruct.gmask = handles.gmask;

% handles.mask = handles.mask+temp*255;
% handles.mask(handles.mask>255)=255;
% handles.axes1=imagesc(((sum(handles.gmask,3)+255)/2).*handles.bigslice);
relabel_axes1


for i = 1:size(ExpStruct.grid.maskbinary,2)
    calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',ExpStruct.grid.maskbinary(:,i),98304,i);
end



calllib('DMD','DLP_RegIO_WriteImageOrderLut',1, [1:size(ExpStruct.grid.maskbinary,2)], size(ExpStruct.grid.maskbinary,2))

guidata(hObject,handles);



function translate_coords_Callback(hObject, eventdata, handles)
% hObject    handle to translate_coords (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of translate_coords as text
%        str2double(get(hObject,'String')) returns contents of translate_coords as a double


% --- Executes during object creation, after setting all properties.
function translate_coords_CreateFcn(hObject, eventdata, handles)
% hObject    handle to translate_coords (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in translate.
function translate_Callback(hObject, eventdata, handles)
% hObject    handle to translate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global ExpStruct dmd
coordinates=str2num(get(dmd.translate_coords,'String'));
translate(ExpStruct.MP285,coordinates);


% --- Executes on button press in go_to.
function go_to_Callback(hObject, eventdata, handles)
% hObject    handle to go_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct dmd
moveTo(ExpStruct.MP285,ExpStruct.sliceImagecoordinates{dmd.currentimageno});

% --- Executes on selection change in scale_factor_select.
function scale_factor_select_Callback(hObject, eventdata, handles)
% hObject    handle to scale_factor_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dmd Expstruct
switch get(hObject,'Value')
    case 1
        dmd.scalefactor = 20/11;
    case 2
        dmd.scalefactor=10/11;
end

% Hints: contents = cellstr(get(hObject,'String')) returns scale_factor_select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scale_factor_select


% --- Executes during object creation, after setting all properties.
function scale_factor_select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale_factor_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
