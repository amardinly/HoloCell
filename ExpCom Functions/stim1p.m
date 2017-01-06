function stim1p(int,color,PL)
global L

delay=300;
pulselength =PL;
%int = 3; %3
%int = 100; %3
%color = 'c';
%color = 'g';
pause(delay/1000)
lumen(int,color)
pause(pulselength/1000)
lumen(0,color)

