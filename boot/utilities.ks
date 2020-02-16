Copypath("0:/Functions/executeNode","1:").
Run once "executeNode".
Copypath("0:/Scripts/executeNext","1:").

Copypath("0:/Functions/hoverslam","1:").
Run once "hoverslam".
Copypath("0:/Scripts/landNow","1:").

Copypath("0:/Functions/circularize","1:").
Run once "circularize".
Copypath("0:/Scripts/vacuumAscent","1:").

Copypath("0:/Functions/gravityTurn","1:").
Run once "gravityTurn".
Copypath("0:/Scripts/atmoAscent","1:").

Runpath("0:/preferences").

If status = "PRELAUNCH" {
  Wait until periapsis > body:atm:height or abort.
  If abort {
    Runpath("1:/landNow",1.5).
  }.
}.
