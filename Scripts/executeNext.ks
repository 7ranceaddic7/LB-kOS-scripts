//Just an executable alias for the function.

If homeConnection:isConnected {
  Copypath("0:/Functions/executeNode","1:"). //grab latest version if possible
}.
Run once "executeNode". //Our bootfile should have grabbed a copy

executeNode().
