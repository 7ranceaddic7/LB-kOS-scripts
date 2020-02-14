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
  Set safeOrbit to body:atm:height + 5000.
  Print "Launching in 5 seconds.".
  Wait 5.
  gravityTurn(safeOrbit).
  Circularize().
  Print "Launch complete.".
  Set warp to 0.
  SAS on.
}.

Function gravityTurn { //deal with lazyglobal scope eventually
  Parameter targetAltitude.
  Lock steering to heading(90,90) + R(0,0,270).
  Print "Launch!".
  Stage.
  Wait 1.
  Print "Beginning trajectory...".
  Lock desiredPitch to 90 - (1 - body:atm:altitudePressure(altitude) ^ (1/3)) * 90. //the secret sauce
  Lock desiredHeading to heading(90,desiredPitch) + R(0,0,270).
  Lock steering to desiredHeading.
  Lock pitchDifference to vectorangle(facing:forevector,desiredHeading:forevector).
  Until apoapsis > targetAltitude {
    Print "Alt: " + round(altitude,0) + "m; Prs: " + round(body:atm:altitudePressure(altitude),3) + "atm; Trgt: " + round(desiredPitch,1) + "; Diff: " + round(pitchDifference,1).
    Wait 0.1.
  }.
  Print "Suborbital trajectory reached.".
  Lock throttle to 0.
  Print "Steering to prograde.".
  Lock steering to r(prograde:pitch,prograde:yaw,facing:roll).
  Print "Coasting to circularization...".
  Until altitude > body:atm:height - 5000 {
    If throttle = 0 and apoapsis < body:atm:height {
      Print "   Raising apoapsis again.".
      Lock throttle to 1.
    }.
    If throttle > 0 and apoapsis > targetAltitude {
      Print "   Coasting again.".
      Lock throttle to 0.
    }.
    Wait 0.1.
  }.
  Print "Exiting atmosphere.".
  Lock throttle to 0.
  Return.
}.
