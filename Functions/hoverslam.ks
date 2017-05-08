//This is the function definition.
//For a script that can be run from the terminal, run landNow.

Copypath("0:/Functions/availableEngines","1:").
Run once "availableEngines".

//Adapted from https://github.com/mrbradleyjh/kOS-Hoverslam

Function hoverslam { //deal with lazyglobal scope
  Parameter someOffset.
  Print "Steering to retrograde.".
  SAS off.
  Lock steering to R(srfretrograde:pitch,srfretrograde:yaw,facing:roll).
  Print "Calculating landing.".
  Lock localGravity to body:mu / (altitude + body:radius) ^ 2.
  Lock myThrust to angledThrust().
  Print "Usable thrust is " + round(myThrust,2) + " out of " + round(ship:availablethrust,2) + " possible.".
  Lock maxAcceleration to myThrust / ship:mass - localGravity.
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
  Wait until verticalspeed > -7.
  Print "Touching down.".
  Lock throttle to localGravity / (maxAcceleration + localGravity) * 0.8.
  Lock steering to R(up:pitch,up:yaw,facing:roll).
  Wait until verticalspeed < -6 or status = "LANDED" or status = "SPLASHED" or verticalspeed > -1.
  Lock throttle to localGravity / (maxAcceleration + localGravity).
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

Function angledThrust {
  Local usedEngines is availableEngines().
  Local netThrust is 0.
  For eng in usedEngines {
    if eng:title = "Taurus HCV" or eng:name = "TaurusHCV" {
      set netThrust to netThrust + eng:availableThrust * 0.71.
    } else {
      Set netThrust to netThrust + eng:availableThrust * cos(vectorangle(facing:forevector,eng:facing:forevector)).
    }.
  }.
  Return netThrust.
}.

Function srfDistance {
  Parameter myOffset.
  Local someDistance to alt:radar - myOffset.
  If addons:TR:hasImpact {
    Set someDistance to addons:TR:impactPos:distance - myOffset.
    If addons:TR:impactPOS:terrainHeight < 0 {
      Set someDistance to someDistance + addons:TR:impactPOS:terrainHeight. //crude
    }.
  }.
  Return someDistance.
}.
