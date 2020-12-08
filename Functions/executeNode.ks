If homeConnection:isConnected {
  Copypath("0:/Functions/burnTime","1:").
}.
Run once "burnTime".

Function executeNode {
  Local myNode is nextNode.
  Local burnLength to burnTime(myNode:deltav:mag).
  Print "Calculated burn duration: " + round(burnLength,2) + "s".
  Local burnETA is 0.
  Lock burnETA to myNode:eta - burnLength / 2.
  Print "Burn ETA: "  + round(burnETA,2) + "s".
  SAS off.
  Lock steering to r(myNode:burnvector:direction:pitch,myNode:burnvector:direction:yaw,facing:roll).
  Print "Waiting to execute...".
  Wait until burnETA < 15.
  Print "Zeroing warp.".
  Set warp to 0.
  Wait until burnETA < 0.25.
  Print "Executing node.".
  Lock throttle to 1.
  Local executionStart is time:seconds.
  Wait until burnTime(myNode:deltav:mag) < 10.
  Print "Zeroing warp.".
  Set warp to 0.
  Wait until burnTime(myNode:deltav:mag) < 2.
  Print "Completing execution.".
  Lock throttle to myNode:deltav:mag / (ship:availablethrust / mass).
  Wait until myNode:deltav:mag < 0.1.
  Lock throttle to 0.
  Print "Execution complete.".
  Local executionFinish is time:seconds.
  Print "Actual burn duration: " + round(executionFinish - executionStart,2) + "s".
  Set ship:control:pilotmainthrottle to 0.
  Unlock throttle.
  Unlock steering.
  SAS on.
  Return.
}.
