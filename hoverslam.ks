//Adapted from https://github.com/mrbradleyjh/kOS-Hoverslam

Function hoverslam { //deal with lazyglobal scope
  Parameter someOffset.
  Print "Steering to retrograde.".
  SAS off.
  Lock steering to R(srfretrograde:pitch,srfretrograde:yaw,facing:roll).
  Print "Calculating landing.".
  Lock localGravity to body:mu / (altitude + body:radius) ^ 2.
  Lock maxAcceleration to ship:availablethrust / ship:mass - localGravity.
  Lock stoppingDistance to verticalspeed ^ 2 / (2 * maxAcceleration). //account for horizontal velocity
  Lock idealThrottle to stoppingDistance / (alt:radar - someOffset).
  Wait until alt:radar - someOffset < stoppingDistance.
  Print "Performing hoverslam.".
  Lock throttle to idealThrottle.
  Gear on.
  Wait until verticalspeed > -5.
  Print "Touching down.".
  Lock throttle to localGravity / (maxAcceleration + localGravity).
  Print "Setting throttle to " + round(throttle * 100,2) + "%".
  Lock steering to R(up:pitch,up:yaw,facing:roll).
  Wait until status = "LANDED" or status = "SPLASHED".
  Set ship:control:pilotmainthrottle to 0.
  Unlock throttle.
  Unlock steering.
  Print "Enabling SAS.".
  SAS on.
  Print "Situation: " + status.
  Return.
}.
