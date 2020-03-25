Function gravityTurn {
  Parameter targetAltitude, degFromNorth is 90.
  Print "Target altitude is " + targetAltitude + "m.".
  SAS off.
  Lock steering to heading(90,90) + R(0,0,270).
  Print "Launch!".
  Stage.
  Wait 5. //clear the launch tower
  Print "Beginning trajectory...".
  Lock desiredPitch to 87.
  Lock desiredHeading to heading(degFromNorth,desiredPitch) + R(0,0,270). //should work with any inclination
  Lock steering to desiredHeading.
  Wait 5.
  Lock steering to r(srfprograde:pitch,srfprograde:yaw,facing:roll).
  Print "Steering to prograde.".
  Wait until apoapsis > targetAltitude.
  Print "Suborbital trajectory reached.".
  Lock throttle to 0.
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
