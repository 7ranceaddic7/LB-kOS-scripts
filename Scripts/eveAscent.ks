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
  Lock steering to heading(90,90) + R(0,0,270).
  Print "Launch!".
  Lock throttle to 3/twr().
  Gear off.
  Lock desiredPitch to max(90 - (altitude - 10000) * 0.001125,0).
  Lock desiredHeading to heading(90,desiredPitch) + R(0,0,270).
  Lock steering to desiredHeading.
  When burnout() {
    Stage.
    Print "Staging!".
    Preserve.
  }.
  Lock pitchDifference to vectorangle(facing:forevector,desiredHeading:forevector).
  Until altitude > 90000 or apoapsis > targetAltitude {
    Print "Alt: " + round(altitude,0) + "m; Target: " + round(desiredPitch,0) + "; Diff: " + round(pitchDifference,2).
    Wait 1.
  }.
  If apoapsis < targetAltitude {
    Print "Raising apoapsis to target altitude.".
    Lock steering to heading(90,0) + R(0,0,270).
    Wait until apoapsis > targetAltitude.
  }.
  Print "Suborbital trajectory reached.".
  Lock throttle to 0.
  Print "Switching to prograde.".
  Lock steering to r(prograde:pitch,prograde:yaw,facing:roll).
  Print "Coasting to circularization...".
  Until altitude > 90000 {
    If throttle = 0 and apoapsis < 90000 {
      Print "   Raising apoapsis again.".
      Lock throttle to 1.
    }.
    If throttle > 0 and apoapsis > targetAltitude {
      Print "   Coasting again.".
      Lock throttle to 0.
    }.
    Wait 0.1.
  }.
  Print "Exited atmosphere.".
  Lock throttle to 0.
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
