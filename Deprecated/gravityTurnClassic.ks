Function gravityTurn {
  Parameter targetAltitude, degFromNorth is 90.
  Set startingPressure to body:atm:altitudePressure(altitude).
  Print "Target altitude is " + targetAltitude + "m.".
  Set initialRoll to facing:roll.
  SAS off.
  Lock steering to heading(90,90) + R(0,0,270).
  //Lock steering to heading(90,90,initialRoll).
  Print "Launch!".
  Stage.
  Wait 1. //clear the launch tower
  Print "Beginning trajectory...".
  Lock fractionalPressure to body:atm:altitudePressure(altitude) / startingPressure. //should work on any planet
  Lock desiredPitch to 90 - (1 - fractionalPressure ^ (1/3)) * 90. //the secret sauce
  Lock desiredHeading to heading(degFromNorth,desiredPitch) + R(0,0,270). //should work with any inclination
  Lock steering to desiredHeading.
  Lock pitchDifference to vectorangle(facing:forevector,desiredHeading:forevector).
  Set switchOver to false.
  Until switchOver {
    Print "Alt: " + round(altitude,0) + "m; Prs: " + round(body:atm:altitudePressure(altitude),3) + "atm; Trgt: " + round(desiredPitch,1) + "; Diff: " + round(pitchDifference,1).
    Wait 1.
    If apoapsis > body:atm:height * 0.85 { Set switchOver to true. }.
    If fractionalPressure < 0.001 { Set switchOver to true. }.
    If altitude > body:atm:height * 0.6 { Set switchOver to true. }.
    If desiredPitch < 5  { Set switchOver to true. }.
  }.
  Print "Switching to apoapsis monitoring.".
  If apoapsis < targetAltitude {
    Print "Raising apoapsis to target altitude.".
    Wait until apoapsis > targetAltitude.
  }.
  Print "Suborbital trajectory reached.".
  Lock throttle to 0.
  Print "Steering to prograde.".
  Lock steering to r(prograde:pitch,prograde:yaw,facing:roll).
  Print "Coasting to circularization...".
  Until altitude > body:atm:height {
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
