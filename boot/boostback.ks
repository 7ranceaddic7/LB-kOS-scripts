//Impact determination adapted from
// https://www.reddit.com/r/Kos/comments/45axu6/boostback_burn_help/czxoi2f/?st=j245tcd7&sh=86ba30e1
//Hoverslam adapted from https://github.com/mrbradleyjh/kOS-Hoverslam

Runpath("0:/preferences").

Print "Setting up.".
Set launchLongitude to geoposition:lng.
Set radarOffset to alt:radar.
Print "Radar offset: " + round(radarOffset,2) + "m".
Set boosterTag to core:part:tag + "booster".
Set boosterEngine to ship:partstagged(boosterTag)[0].
Print "Waiting to stage...".
Wait until boosterEngine:flameout.
Print "Staging.".
Stage.
Wait 0.1.
Set reserveTanks to ship:partstagged("reservefuel").
reserveTanks:add(boosterEngine).
Print "Zeroing throttle.".
Lock throttle to 0.
Print "Enabling reserve propellants.".
For eachTank in reserveTanks {
  For eachResource in eachTank:resources {
    Set eachResource:enabled to true.
  }.
}.
For eachTank in reserveTanks {
  For eachResource in eachTank:resources {
    For boosterResource in boosterEngine:resources {
      If boosterResource:name = eachResource:name {
        Set transferAttempt to transferall(eachResource:name,eachTank,boosterEngine).
        Set transferAttempt:active to true.
        Print "Transferring propellant to booster: " + transferAttempt:resource.
      }.
    }.
  }.
}.
Print "Waiting 5s for separation.".
Wait 5.
Print "Enabling RCS.".
RCS on.
Print "Steering west.".
Set dueWest to heading(270,0) + R(0,0,270).
Lock dueWestNoRoll to r(dueWest:pitch,dueWest:yaw,facing:roll).
Lock steering to dueWestNoRoll.
set steeringStartTime to time:seconds.
Print "Waiting for steering...".
Lock differenceFromWest to vectorangle(facing:forevector,dueWestNoRoll:forevector).
Until differenceFromWest < 2 {
  Print "   Difference from west: " + round(differenceFromWest,2).
  Wait 1.
}.
Print "Steering time was " + round(time:seconds - steeringStartTime,2) + "s".
Print "Est. impact distance from launch: " + round(impactDistance(),3) + "km".
Print "Preparing to boost back.".
Set boostingBack to false.
Set overshooting to false.
Set emergencyAbort to false.
Set cancelAbort to false.
When landingDV(boosterEngine, reserveTanks) < 350 or cancelAbort then {
  If boostingBack or overshooting {
    Print "Aborting site selection: landing capacity < 350 dv".
    Lock throttle to 0.
    Set boostingBack to false.
    Set overshooting to false.
    Set emergencyAbort to true.
  }
  Else print "Cancelling abort check.".
}.
Print "Boosting back!".
Set boostingBack to true.
Lock throttle to 1.
Until not boostingBack {
  Set currentImpactDistance to impactDistance().
  Print "   Est. impact distance from launch: " + round(currentImpactDistance,3) + "km".
  If currentImpactDistance < 50 and not emergencyAbort {
    Lock throttle to max(currentImpactDistance / 50, 0.05).
    Print "   Setting throttle to " + round(throttle * 100,0) + "%".
  }.
  If currentImpactDistance < 1 {
    Print "Est. impact distance from launch < 1km!".
    Lock throttle to 0.
    Set boostingBack to false.
  }.
}.
If not emergencyAbort {
  Print "Intentionally overshooting.".
  Set overshooting to true.
  Lock throttle to 0.05.
  Until not overshooting {
    Set currentImpactDistance to impactDistance().
    Print "   Est. impact distance from launch: " + round(currentImpactDistance,3) + "km".
    If currentImpactDistance > 2 {
      Print "Overshoot complete.".
      Lock throttle to 0.
      Set overshooting to false.
    }.
  }.
}.
Set cancelAbort to true.
Lock throttle to 0.
Print "Releasing control until landing.".
RCS off.
Unlock steering.
Set ship:control:pilotmainthrottle to 0.
Unlock throttle.
Print "Est. dv available for landing: " + round(landingDV(boosterEngine,reserveTanks),2).
Print "Waiting to land...".
Wait until altitude < 15000.
Print "Deploying brakes.".
Brakes on.
Print "Steering to retrograde.".
Lock steering to R(srfretrograde:pitch,srfretrograde:yaw,facing:roll).
Wait until altitude < 5000.
Print "Enabling RCS.".
RCS on.
Print "Calculating landing.".
Lock maxAcceleration to ship:availablethrust / ship:mass - 9.81.
Lock stoppingDistance to verticalspeed ^ 2 / (2 * maxAcceleration).
Lock idealThrottle to stoppingDistance / (alt:radar - radarOffset).
Wait until alt:radar - radarOffset < stoppingDistance.
Print "Performing hoverslam.".
Lock throttle to idealThrottle.
Gear on.
Wait until verticalspeed > -5.
Print "Touching down.".
Lock throttle to 5 / maxAcceleration.
Print "Setting throttle to " + round(throttle * 100,2) + "%".
Wait until status = "LANDED" or status = "SPLASHED".
Set ship:control:pilotmainthrottle to 0.
Unlock throttle.
Unlock steering.
Print "Enabling SAS.".
SAS on.
Print "Situation: " + status.

Function impactLongitude {
  Local someTime is time.
  Local somePosition is positionat(ship, someTime).
  Local someVector is somePosition - body:position.
  Local someAltitude is ship:altitude.
  Until someAltitude < 75 {
    Set someTime to someTime + 1.
    Set somePosition to positionat(ship, someTime).
    Set someVector to somePosition - body:position.
    Set someAltitude to someVector:mag - body:radius.
  }.
  return body:geopositionof(somePosition):lng - ((someTime:seconds - time:seconds)/60).
  //Alternate method: calculate from true anomaly.
}.

Function impactDistance {
  return abs(impactLongitude() - launchLongitude) * (2 * constant:pi * body:radius / 360 / 1000).
}.

Function landingDV {
  //Assumes we're landing with only one kind of engine.
  Parameter landingEngine, availableTanks.
  Local propellantMass to 0.
  For landingTank in availableTanks {
    For landingResource in landingTank:resources {
      Set propellantMass to propellantMass + (landingResource:amount * landingResource:density).
    }.
  }.
  return ln(mass / (mass - propellantMass)) * landingEngine:sealevelisp * 9.81.
}.
