function varargout = manual_laser_control(varargin)
% MANUAL_LASER_CONTROL MATLAB code for manual_laser_control.fig
%      MANUAL_LASER_CONTROL, by itself, creates a new MANUAL_LASER_CONTROL or raises the existing
%      singleton*.
%
%      H = MANUAL_LASER_CONTROL returns the handle to a new MANUAL_LASER_CONTROL or the handle to
%      the existing singleton*.
%
%      MANUAL_LASER_CONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANUAL_LASER_CONTROL.M with the given input arguments.
%
%      MANUAL_LASER_CONTROL('Property','Value',...) creates a new MANUAL_LASER_CONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before manual_laser_control_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to manual_laser_control_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help manual_laser_control

% Last Modified by GUIDE v2.5 29-Sep-2014 14:10:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @manual_laser_control_OpeningFcn, ...
                   'gui_OutputFcn',  @manual_laser_control_OutputFcn, ...
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


% --- Executes just before manual_laser_control is made visible.
function manual_laser_control_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to manual_laser_control (see VARARGIN)

% Choose default command line output for manual_laser_control
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes manual_laser_control wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = manual_laser_control_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global listener s laser_struct ExpStruct
listener.Enabled = false;

output=make_ramps(1, laser_struct.duration,1, 1, laser_struct.voltage, laser_struct.voltage, laser_struct.Fs, laser_struct.duration/1000);  
s.queueOutputData([ones(length(output),6) output*0 output*0 output output*0]);
s.prepare
s.startBackground

% --- Executes on button press in Stop.
function Stop_Callback(hObject, eventdata, handles)
% hObject    handle to Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global laserTimer listener s laser_struct ExpStruct
listener.Enabled = false;
output=make_ramps(1, laser_struct.duration,1, 1, laser_struct.voltage, laser_struct.voltage, laser_struct.Fs, laser_struct.duration/1000);    
s.queueOutputData([ones(length(output),6)  output*0 output*0 output*0 output*0]);
s.prepare
s.startBackground

% --- Executes on button press in Pulse.
function Pulse_Callback(hObject, eventdata, handles)
% hObject    handle to Pulse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global laserTimer listener s laser_struct dmd ExpStruct
listener.Enabled = false;
output=make_ramps(1, laser_struct.duration-1,1, 1, laser_struct.voltage, laser_struct.voltage, laser_struct.Fs, laser_struct.duration/1000);    
s.queueOutputData([output*0 output*0 output output*0]);
s.prepare
tic
s.startBackground
toc
if get(handles.checkbox1,'Value')
pause(0.05)
dmd.objectivePosition=getPosition(ExpStruct.MP285);
dmd.sliceshot = getsnapshot(dmd.vhandle.vid);
toc
dmd.bigslice = resizem(dmd.sliceshot,[480 660]);
figure
colormap('gray');
imagesc(dmd.bigslice)
axis image

set(gca,'xtick',[0 56.2500 112.5000 168.7500 225.0000 281.2500 337.5000 393.7500 450.0000 506.2500 562.5000],...
    'xticklabel',{'0';'100';'200';'300';'400';'500';'600';'700';'800';'900';'1000'});
set(gca,'ytick',[0  109.0909  218.1818  327.2727  436.3636],'yticklabel',{'0';'200';'400';'600';'800'})
dmd.mask = zeros(size(dmd.bigslice));
end

function ontime_Callback(hObject, eventdata, handles)
% hObject    handle to ontime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global laser_struct
laser_struct.duration=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of ontime as text
%        str2double(get(hObject,'String')) returns contents of ontime as a double


% --- Executes during object creation, after setting all properties.
function ontime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ontime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global laser_struct
laser_struct.voltage=get(hObject,'Value');
set(handles.voltage,'String',num2str(laser_struct.voltage));
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



function voltage_Callback(hObject, eventdata, handles)
% hObject    handle to voltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global laser_struct
laser_struct.voltage =str2double(get(hObject,'String'));
set(handles.slider1,'Value',laser_struct.voltage);
% Hints: get(hObject,'String') returns contents of voltage as text
%        str2double(get(hObject,'String')) returns contents of voltage as a double


% --- Executes during object creation, after setting all properties.
function voltage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to voltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global listener
listener.Enabled = true;
% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
