If homeConnection:isConnected {
  Copypath("0:/Functions/executeNode","1:").
}.
Run once "executeNode".
If homeConnection:isConnected {
  Copypath("0:/Scripts/executeNext","1:").
}.

If homeConnection:isConnected {
  Copypath("0:/Functions/hoverslam","1:").
}.
Run once "hoverslam".
If homeConnection:isConnected {
  Copypath("0:/Scripts/landNow","1:").
}.

If homeConnection:isConnected {
  Copypath("0:/Functions/circularize","1:").
}.
Run once "circularize".
If homeConnection:isConnected {
  Copypath("0:/Scripts/vacuumAscent","1:").
}.

If homeConnection:isConnected {
  Copypath("0:/Functions/gravityTurn","1:").
}.
Run once "gravityTurn".
If homeConnection:isConnected {
  Copypath("0:/Scripts/atmoAscent","1:").
}.

If homeConnection:isConnected {
  Runpath("0:/preferences").
}.

If status = "PRELAUNCH" {
  Wait until periapsis > body:atm:height or abort.
  If abort {
    Runpath("1:/landNow",1.5).
  }.
}.
