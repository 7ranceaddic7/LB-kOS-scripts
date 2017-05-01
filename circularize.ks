//Adapted from https://www.reddit.com/r/Kos/comments/2wuo9o/what_is_the_easiest_way_to_circularize_while/?st=j1zx53ez&sh=9da227a7

Copypath("0:/burnTime","1:").
Run once "burnTime".

Function circularize { 
  Print "Calculating circularization burn.".
  Local targetSpeed to sqrt(body:mu / (body:radius + apoapsis)).
  Local suborbitalApoapsisSpeed to velocityat(ship, time:seconds + eta:apoapsis):orbit:mag.
  Local circularizationDV to targetspeed - suborbitalApoapsisSpeed.
  Print "   Circularization dv: " + round(circularizationDV,2).
  Local burnLength to burnTime(circularizationDV).
  Print "   Burn duration: " + round(burnLength,2) + "s".
  Local circularizationNode to node(time:seconds + eta:apoapsis,0,0,circularizationDV).
  Add circularizationNode.
  Print "Node added.".
  Lock steering to r(circularizationNode:burnvector:direction:pitch,circularizationNode:burnvector:direction:yaw,facing:roll).
  Print "Waiting to circularize...".
  Wait until eta:apoapsis < max(burnLength,15).
  Print "Zeroing warp.".
  Set warp to 0.
  Wait until eta:apoapsis < (burnLength / 2).
  Print "Circularizing.".
  Lock throttle to 1.
  Wait until velocity:orbit:mag > targetSpeed.
  Lock throttle to 0.
  Set ship:control:pilotmainthrottle to 0.
  Print "Circularization complete.".
  Unlock throttle.
  Unlock steering.
  Return.
}.
