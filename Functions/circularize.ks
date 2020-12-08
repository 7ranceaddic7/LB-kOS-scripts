//Adapted from https://www.reddit.com/r/Kos/comments/2wuo9o/what_is_the_easiest_way_to_circularize_while/?st=j1zx53ez&sh=9da227a7

If homeConnection:isConnected {
  Copypath("0:/Functions/executeNode","1:").
}.
Run once "executeNode".

Function circularize {
  Print "Calculating circularization burn.".
  Local targetSpeed to sqrt(body:mu / (body:radius + apoapsis)).
  Local suborbitalApoapsisSpeed to velocityat(ship,time:seconds + eta:apoapsis):orbit:mag.
  Local circularizationDV to targetspeed - suborbitalApoapsisSpeed.
  Print "Circularization dv: " + round(circularizationDV,2).
  Local circularizationNode to node(time:seconds + eta:apoapsis,0,0,circularizationDV).
  Add circularizationNode.
  Print "Node added.".
  executeNode().
  Print "Eccentricity: " + round(obt:eccentricity,6).
}.
