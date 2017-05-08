//Set config:ipu to 400.
Set config:audioerr to true.
//Set config:stat to true.
//Set config:verbose to true.

Set terminal:brightness to 1.
//Set terminal:charwidth to 8.
//Set terminal:charheight to 8.
//Set terminal:width to 50.
//Set terminal:height to 36.
//Set terminal:visualbeep to true.
Clearscreen.

Copypath("0:/Functions/executeNode","1:").
Run once "executeNode".
Copypath("0:/Scripts/executeNext","1:").

Copypath("0:/Functions/hoverslam","1:").
Run once "hoverslam".
Copypath("0:/Scripts/landNow","1:").
