Copypath("0:/Functions/hoverslam","1:").
Run once "hoverslam".
Copypath("0:/Functions/availableEngines","1:").
Run once "availableEngines".
Copypath("0:/Functions/averageIsp","1:").
Run once "averageIsp".

Runpath("0:/preferences").

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
reserveTanks:add(boosterEngine).
Print "Waiting 5s for separation.".
Wait 5.
Set landingIsp to averageIspAt(availableEngines(),1).
Set sepDV to landingDV(landingIsp).
Print "Enabling RCS.".
RCS on.
Print "Steering west.".
Set dueWest to heading(270,0) + R(0,0,270).
Lock dueWestNoRoll to r(dueWest:pitch,dueWest:yaw,facing:roll).
Lock steering to dueWestNoRoll.
Set steeringManager:maxStoppingTime to 10.
Set steeringManager:pitchPID:KD to 2.
Set steeringManager:yawPID:KD to 2.
set steeringStartTime to time:seconds.
Print "Waiting for steering...".
Lock differenceFromWest to vectorangle(facing:forevector,dueWestNoRoll:forevector).
Until differenceFromWest < 3 {
  Print "   Difference from west: " + round(differenceFromWest,2).
  Wait 1.
}.
Print "Steering time was " + round(time:seconds - steeringStartTime,2) + "s".
Set steeredDV to landingDV(landingIsp).
Print "Est. impact distance from launch: " + round(impactDistance(),3) + "km".
Print "Preparing to boost back.".
Set targetDistance to -2.5.
Set boostingBack to false.
Set emergencyAbort to false.
Set cancelAbort to false.
When landingDV(landingIsp) < 400 or cancelAbort then {
  If boostingBack {
    Print "Aborting site selection: landing capacity < 400 dv".
    Lock throttle to 0.
    Set boostingBack to false.
    Set emergencyAbort to true.
  }
  Else print "Cancelling abort check.".
}.
Set boostbackStartTime to time:seconds.
Print "Boosting back!".
Set boostingBack to true.
Lock throttle to 1.
Until not boostingBack {
  Set currentImpactDistance to impactDistance().
  Print "   Est. impact distance from launch: " + round(currentImpactDistance,3) + "km".
  If (currentImpactDistance - targetDistance) < 25 and not emergencyAbort {
    Lock throttle to max((currentImpactDistance - targetDistance) / 25, 0.05).
  }.
  If (currentImpactDistance - targetDistance) < 0 {
    Print "Landing target reached.".
    Lock throttle to 0.
    Set boostingBack to false.
  }.
  Wait 0.2.
}.
Set cancelAbort to true.
Print "Boostback time was " + round(time:seconds - boostbackStartTime,2) + "s".
Set boostedDV to landingDV(landingIsp).
Lock throttle to 0.
Print "Releasing control until landing.".
RCS off.
Unlock steering.
Set ship:control:pilotmainthrottle to 0.
Unlock throttle.
Print "Waiting to land...".
Wait until altitude < 15000.
Print "Deploying brakes.".
Brakes on.
Lock steering to R(srfretrograde:pitch,srfretrograde:yaw,facing:roll).
Wait until altitude < 5000.
Print "Enabling RCS.".
RCS on.
Hoverslam(radarOffset/0.75).
Set finalDV to landingDV(landingIsp).
Print "Sea-level delta-V: ".
Print "   Separation: " + round(sepDV,2) + " available".
Print "   Steering:   " + round(sepDV - steeredDV,2) + " consumed".
Print "   Boostback:  " + round(steeredDV - boostedDV,2) + " consumed".
Print "   Landing:    " + round(boostedDV - finalDV,2) + " consumed".
Print "   Final:      " + round(finalDV,2) + " available".
Print "   Total:      " + round(sepDV - finalDV,2) + " consumed".

Function landingDV {
  Parameter myIsp.
  Local propellantMass is 0.
  Local resourceList is list().
  List resources in resourceList.
  For res in resourceList {
    Set propellantMass to propellantMass + res:amount * res:density. //assumes we can burn all resources
  }
  return ln(mass / (mass - propellantMass)) * myIsp * 9.81.
}.

//Impact determination adapted from
// https://www.reddit.com/r/Kos/comments/45axu6/boostback_burn_help/czxoi2f/?st=j245tcd7&sh=86ba30e1

Function impactDistance {
  //Alternate method: calculate from true anomaly.
  Local someTime is time.
  Local somePosition is positionat(ship,someTime).
  Local someVector is somePosition - body:position.
  Local someAltitude is ship:altitude.
  Until someAltitude < 75 {
    Set someTime to someTime + 3.
    Set somePosition to positionat(ship,someTime).
    Set someVector to somePosition - body:position.
    Set someAltitude to someVector:mag - body:radius.
  }.
  Local impactLongitude is body:geopositionof(somePosition):lng - ((someTime:seconds - time:seconds)/60).
  Return (impactLongitude - launchLongitude) * (2 * constant:pi * body:radius / 360 / 1000).
}.
