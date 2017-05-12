Parameter offset.

If homeConnection:isConnected {
  Copypath("0:/Functions/hoverslam","1:").
}.
Run once "hoverslam".

Print "Waiting until vertspeed < 0...".
Wait until verticalspeed < -5.
Hoverslam(offset).
