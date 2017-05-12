Copypath("0:/Functions/circularize","1:").
Run once "circularize".

Runpath("0:/preferences").

dunaTurn(60000).
Circularize().
Print "Ascent complete.".
Set warp to 0.
SAS on.

Function dunaTurn { //deal with lazyglobal scope eventually.
  Parameter targetAltitude.
  SAS off.
  Lock steering to heading(90,90) + R(0,0,270).
  Print "Launch!".
  Lock throttle to 1.
  Gear off.
  Lock desiredPitch to 90 - min(max(altitude * 0.0045,0),90).
  Lock desiredHeading to heading(90,desiredPitch) + R(0,0,270).
  Lock steering to desiredHeading.
  Wait until apoapsis > targetAltitude.
  Print "Suborbital trajectory reached.".
  Lock throttle to 0.
  Print "Switching to prograde.".
  Lock steering to r(prograde:pitch,prograde:yaw,facing:roll).
  Set steeringCheck to false.
  Print "Coasting to circularization...".
  Wait until altitude > 50000.
  Print "Exited atmosphere.".
  Return.
}.
