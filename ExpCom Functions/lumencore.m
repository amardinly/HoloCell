function lumencore(delay,duration,int,color)
% example lumencore(500,5,10,'c')
% colors: uv b r g t c

pause(delay/1000)
lumen(int,color)
pause(duration/1000)
lumen(0,color)

