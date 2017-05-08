//Just an executable alias for the hoverslam function.

If homeConnection:isConnected {
  Copypath("0:/Functions/hoverslam","1:").  //grab latest version if possible
}.
Run once "hoverslam". //Our bootfile should have grabbed a copy

Wait until verticalspeed < -5.
Hoverslam(1.5). //or take some input to get radar offset
