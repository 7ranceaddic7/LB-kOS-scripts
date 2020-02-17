//Launch functions
Copypath("0:/Functions/gravityTurn","1:").
Run once "gravityTurn".

Copypath("0:/Functions/circularize","1:").
Run once "circularize".

//Utilities
Copypath("0:/Functions/executeNode","1:").
Run once "executeNode".
Copypath("0:/Scripts/executeNext","1:").

Copypath("0:/Functions/hoverslam","1:").
Run once "hoverslam".
Copypath("0:/Scripts/landNow","1:").

Copypath("0:/Functions/circularize","1:").
Run once "circularize".
Copypath("0:/Scripts/vacuumAscent","1:").

Runpath("0:/preferences").

If status = "PRELAUNCH" {
  Set desiredOrbit to (body:atm:height + 5000) * (3 + 1/3).
  Print "Launching in 5 seconds.".
  Wait 5.
  gravityTurn(desiredOrbit).
  Circularize().
  Print "Launch complete.".
  Set warp to 0.
  SAS on.
}.
