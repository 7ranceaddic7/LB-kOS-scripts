Copypath("0:/Functions/executeNode","1:").
Run once "executeNode".
Copypath("0:/Scripts/executeNext","1:").

Copypath("0:/Functions/hoverslam","1:").
Run once "hoverslam".
Copypath("0:/Scripts/landNow","1:").

Runpath("0:/preferences").

Wait until periapsis > 70000 or abort.
If abort {
  runpath("1:/landNow").
}.