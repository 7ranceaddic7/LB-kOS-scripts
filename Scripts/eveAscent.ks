Copypath("0:/Functions/circularize","1:").
Run once "circularize".
Copypath("0:/Functions/twr","1:").
Run once "twr".

Runpath("0:/preferences").

eveTurn(100000).
Circularize().
Print "Ascent complete.".
Set warp to 0.
SAS on.

Function eveTurn { //deal with lazyglobal scope eventually.
  Parameter targetAltitude.
  SAS off.
  Lock steering to heading(90,90) + R(0,0,270).
  Print "Launch!".
  Lock throttle to 3/max(twr(),0.0001).
  Gear off.
  Lock desiredPitch to 90 - max((altitude - 15000) * 0.0012,0).
  Lock desiredHeading to heading(90,desiredPitch) + R(0,0,270).
  Lock steering to desiredHeading.
  When burnout() then {
    Stage.
    Print "Staging.".
    Preserve.
  }.
  Lock pitchDifference to vectorangle(facing:forevector,desiredHeading:forevector).
  Set steeringCheck to true.
  When pitchDifference > 10 then {
    if steeringCheck {
      Print "Steering error; unlocking throttle.".
      Unlock throttle.
      Set ship:control:pilotmainthrottle to 0.
    }.
  }.
  Until apoapsis > targetAltitude {
    Print "Alt: " + round(altitude,0) + "m; Target: " + round(desiredPitch,0) + "; Diff: " + round(pitchDifference,2).
    Wait 1.
  }.
  Print "Suborbital trajectory reached.".
  Lock throttle to 0.
  Print "Switching to prograde.".
  Lock steering to r(prograde:pitch,prograde:yaw,facing:roll).
  Set steeringCheck to false.
  Print "Coasting to circularization...".
  Wait until altitude > 90000.
  Print "Exited atmosphere.".
  Return.
}.

Function burnout {
  Local myEngines is list().
  List engines in myEngines.
  For eng in myEngines {
    If eng:flameout {
      Return true.
    }.
  }.
  Return false.
}.
