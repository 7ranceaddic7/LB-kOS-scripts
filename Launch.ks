Run once burnTime.

Print "Launching in 5 seconds.".
Wait 5.
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
Lock desiredPitch to 45 - (altitude - 10000) * 0.00225.
Until altitude > 30000 {
  Print "Alt: " + round(altitude,0) + "m; Target: " + round(desiredPitch,0) + "; Diff: " + round(pitchDifference,2).
  Wait 1.
}.
Print "Raising apoapsis to 75km...".
Lock steering to heading(90,0) + R(0,0,270).
Wait until apoapsis > 75000.
Print "Suborbit reached.".
Lock throttle to 0.
Print "Switching to prograde.".
Lock steering to prograde:forevector.
Print "Coasting to circularization...".
Wait until altitude > 70000.
Print "Calculating circularization burn.".
Set targetSpeed to sqrt(body:mu / (body:radius + apoapsis)).
Print "Target speed: " + round(targetSpeed,2).
Set suborbitalApoapsisSpeed to velocityat(ship, time:seconds + eta:apoapsis):orbit:mag.
Print "Current speed at apoapsis: " + round(suborbitalApoapsisSpeed,2).
Set circularizationDV to targetspeed - suborbitalApoapsisSpeed.
Print "Circularization dv: " + round(circularizationDV,2).
Set maxAcceleration to maxthrust/mass.
Print "Max acceleration: " + round(maxAcceleration,2).
Set burnLength to circularizationDV/maxAcceleration.
Print "Burn duration (est.):  " + round(burnLength,2).
Set circularizationEngine to ship:partstagged("upperengine")[0].
Set burnLength to burnTime(circularizationDV,circularizationEngine).
Print "Burn duration (exact): " + round(burnLength,2).
Set circularizationNode to node(time:seconds + eta:apoapsis,0,0,circularizationDV).
Add circularizationNode.
Print "Node added.".
Lock steering to circularizationNode:burnvector.
Print "Waiting to circularize...".
Wait until eta:apoapsis < burnLength * 2.
Print "Zeroing warp.".
Set warp to 0.
Wait until eta:apoapsis < (burnLength / 2).
Print "Circularizing.".
Lock throttle to 1.
Wait until velocity:orbit:mag > targetSpeed.
Lock throttle to 0.
Print "Circularization complete.".
Set ship:control:pilotmainthrottle to 0.
Print "Launch complete. Ending program.".
SAS on.
