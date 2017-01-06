function stim1pIOchr2
global L

delay=500;
pulselength = 5;%1
int = 10; %3
%int = 100; %3
color = 'c';
%color = 'g';
pause(delay/1000)
lumen(int,color)
pause(pulselength/1000)
lumen(0,color)

