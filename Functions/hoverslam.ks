Copypath("0:/Functions/twr","1:").
Run once "twr".

//Adapted from https://github.com/mrbradleyjh/kOS-Hoverslam

Function hoverslam { //deal with lazyglobal scope
  Parameter someOffset.
  Print "Steering to retrograde.".
  SAS off.
  Lock steering to R(srfretrograde:pitch,srfretrograde:yaw,facing:roll).
  Print "Calculating landing.".
  Lock localGravity to body:mu / (altitude + body:radius) ^ 2.
  Print "Usable thrust is " + round(angledThrust(),2) + " of " + round(ship:availablethrust,2) + " possible.".
  Lock maxAcceleration to angledThrust() / ship:mass - localGravity.
  Lock stoppingDistance to ship:velocity:surface:sqrmagnitude / (2 * maxAcceleration).
  Lock surfaceDistance to srfDistance(someOffset).
  Lock idealThrottle to stoppingDistance / surfaceDistance.
  Wait until surfaceDistance - 500 < stoppingDistance.
  Print "Zeroing warp.".
  Set warp to 0.
  Wait until surfaceDistance < stoppingDistance.
  Print "Performing hoverslam!".
  Lock throttle to idealThrottle.
  Gear on.
  Wait until alt:radar - someOffset < 250.
  Lock surfaceDistance to alt:radar - someOffset.
  Wait until verticalspeed > -6.
  Print "Touching down.".
  Lock throttle to 0.8/angledTWR().
  Lock steering to R(up:pitch,up:yaw,facing:roll).
  Wait until verticalspeed < -5 or status = "LANDED" or status = "SPLASHED" or verticalspeed > -1.
  Lock throttle to 1/angledTWR().
  Wait until status = "LANDED" or status = "SPLASHED" or verticalspeed > -1.
  Set ship:control:pilotmainthrottle to 0.
  Unlock throttle.
  Unlock steering.
  Print "Enabling SAS.".
  SAS on.
  Wait 1.
  Print "Situation: " + status.
  Return.
}.

Function srfDistance {
  Parameter myOffset.
  Local someDistance to alt:radar - myOffset.
  If addons:tr:hasImpact {
    If addons:tr:impactPOS:terrainHeight > 0 or not body:atm:exists { //not sure if impactpos:distance "sees" water
      Set someDistance to addons:tr:impactPos:distance - myOffset.
    }.
  }.
  Return someDistance.
}.
