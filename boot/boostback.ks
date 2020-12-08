If homeConnection:isConnected {
  Copypath("0:/Functions/hoverslam","1:").
}.
Run once "hoverslam".
If homeConnection:isConnected {
  Copypath("0:/Functions/availableEngines","1:").
}.
Run once "availableEngines".
If homeConnection:isConnected {
  Copypath("0:/Functions/averageIsp","1:").
}.
Run once "averageIsp".

Runpath("0:/preferences").
// ====================
// 1. SETUP
// ====================
Set launchLongitude to geoposition:lng.
Set launchpad to geoposition.
Set radarOffset to alt:radar.
Print "Radar offset: " + round(radarOffset,2) + "m".
Set engineTag to core:part:tag + "engine".
Set boosterEngine to ship:partstagged(engineTag)[0].
Print "Waiting to stage...".
// ====================
// 2. STAGING & SEPARATION
// ====================
Wait until boosterEngine:flameout.
Print "Staging.".
Stage.
Wait 0.1.
SAS off.
Set reserveTanks to ship:partstagged("reservefuel").
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
Wait 0.9.
Set separatorCount to 0.
For somePart in ship:parts {
  If somePart:name = "sepMotor1" {
    Set separatorCount to separatorCount + 1.
  }.
}.
If separatorCount > 0 {
  Print "Waiting for separation.".
  Wait 4.
}.
Lock throttle to 0.01. //or else thrust will read 0 due to prior flameout
Wait 0.1.
Set landingIsp to averageIspAt(availableEngines(),1).
Lock throttle to 0.
Set sepDV to landingDV(landingIsp).
// ====================
// 3. STEER BACK
// ====================
//CALCULATE LAUNCHPAD HEADING N/S OFFSET HERE
//Need to get impact distance that works with latitude (ugh)
//then lock offset value: 1 km = 3 degrees?
Lock boostbackHeading to heading(launchpad:heading,45) + R(0,0,270).
Lock boostbackHeadingNoRoll to r(boostbackHeading:pitch,boostbackHeading:yaw,facing:roll).
Lock differenceFromBBH to vectorangle(facing:forevector,boostbackHeadingNoRoll:forevector).
Set steeringManager:maxStoppingTime to 10.
Set STEERINGMANAGER:PITCHPID:KD to 1.
Set STEERINGMANAGER:YAWPID:KD to 1.
Print "Steering.".
RCS on.
set steeringStartTime to time:seconds.
Lock steering to boostbackHeadingNoRoll.
Print "Waiting for steering...".
Until differenceFromBBH < 5 {
  Print "   Difference from heading: " + round(differenceFromBBH,2).
  Wait 1.
}.
Print "Steering time was " + round(time:seconds - steeringStartTime,2) + "s".
Set steeredDV to landingDV(landingIsp).
// ====================
// 4. BOOSTBACK
// ====================
Print "Est. impact distance from launch: " + round(impactDistance(),3) + "km".
Print "Preparing to boost back.".
Set targetDistance to -1.
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
RCS off.
Unlock steering.
// ====================
// 5. LANDING
// ====================
Print "Waiting to land...".
Wait until altitude < 15000.
Lock steering to R(srfretrograde:pitch,srfretrograde:yaw,facing:roll).
Print "Deploying gridfins.".
Brakes on.
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
// ====================
// HELPER FUNCTIONS
// ====================
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
