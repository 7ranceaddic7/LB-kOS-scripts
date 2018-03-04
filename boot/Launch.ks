//Launch functions
Copypath("0:/Functions/circularize","1:").
Run once "circularize".

//Utilities
Copypath("0:/Functions/executeNode","1:").
Run once "executeNode".
Copypath("0:/Scripts/executeNext","1:").

Copypath("0:/Functions/hoverslam","1:").
Run once "hoverslam".
Copypath("0:/Scripts/landNow","1:").

Copypath("0:/Functions/circularize","1:").
Run once "circularize".
Copypath("0:/Scripts/vacuumAscent","1:").

Runpath("0:/preferences").

If status = "PRELAUNCH" {
  Print "Launching in 5 seconds.".
  Wait 5.
  gravityTurn(75000).
  Circularize().
  Print "Launch complete.".
  Set warp to 0.
  SAS on.
}.

Function gravityTurn { //deal with lazyglobal scope eventually.
  Parameter targetAltitude.
  Lock steering to heading(90,90) + R(0,0,270).
  Print "Launch!".
  Stage.
  Wait 1.
  Print "Beginning trajectory...".
  Lock desiredPitch to 90 - altitude * 0.0045.
  Lock desiredHeading to heading(90,desiredPitch) + R(0,0,270).
  Lock steering to desiredHeading.
  Lock pitchDifference to vectorangle(facing:forevector,desiredHeading:forevector).
  Until altitude > 10000 {
    Print "Alt: " + round(altitude,0) + "m; Target: " + round(desiredPitch,0) + "; Diff: " + round(pitchDifference,2).
    Wait 1.
  }.
  Print "Continuing trajectory...".
  Lock desiredPitch to 45 - (altitude - 10000) * 0.0015.
  Until altitude > 40000 or apoapsis > targetAltitude {
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
  Until altitude > 70000 {
    If throttle = 0 and apoapsis < 70000 {
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
