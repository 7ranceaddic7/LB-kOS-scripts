//Launch functions
Copypath("0:/Functions/circularize","1:").
Run once "circularize".

//Utilities
Copypath("0:/Functions/executeNode","1:").
Run once "executeNode".
Copypath("0:/Scripts/executeNext","1:").

Runpath("0:/preferences").

Set STEERINGMANAGER:PITCHTS to STEERINGMANAGER:PITCHTS / 2.
Set STEERINGMANAGER:YAWTS to STEERINGMANAGER:YAWTS / 2.
Set sabreEngines to ship:partsdubbed("sabre").
Set rocketEngines to ship:partsdubbed("rocket").
Set desiredPitch to 10.
Lock desiredHeading to heading(90,desiredPitch).
Wait 3.
SAS on.
Stage.
Wait until geoposition:lng > -74.51888.
Lock steering to desiredHeading.
Lock pitchDifference to vectorangle(facing:forevector,desiredHeading:forevector).
Print "Target pitch: " + round(desiredPitch,2) + " deg; diff: " + round(pitchDifference,2).
Wait until status = "FLYING".
Print "Takeoff!".
Gear off.
SAS off.
Until desiredPitch > 19.9 {
  Set desiredPitch to desiredPitch + 0.1.
  Print "Target pitch: " + round(desiredPitch,2) + " deg; diff: " + round(pitchDifference,2).
  Wait 0.25.
}.
Wait until altitude > 10000.
Until desiredPitch < 9.9 {
  Set desiredPitch to desiredPitch - 0.1.
  Print "Target pitch: " + round(desiredPitch,2) + " deg; diff: " + round(pitchDifference,2).
  Wait 0.1.
}.
If ship:airspeed < 325 {
  For rocketEngine in rocketEngines {
    rocketEngine:activate().
  }.
  Wait until ship:airspeed > 400.
  For rocketEngine in rocketEngines {
    rocketEngine:shutdown().
  }.
}.
Wait until altitude > 20000.
Stage.
Until desiredPitch > 19.9 {
  Set desiredPitch to desiredPitch + 0.1.
  Print "Target pitch: " + round(desiredPitch,2) + " deg; diff: " + round(pitchDifference,2).
  Wait 0.1.
}.
When sabreEngines[0]:thrust < 10 then {
  For sabreEngine in sabreEngines {
    sabreEngine:shutdown().
    sabreEngine:togglemode().
  }.
  Intakes off.
}.
Wait until apoapsis > 75000.
Lock throttle to 0.
Lock steering to prograde.
Wait until altitude > 70000.
Circularize().
Print "Launch complete.".
Set warp to 0.
SAS on.
