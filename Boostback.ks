Print "Setting up.".
set launchLongitude to geoposition:lng.
//To do: accept booster engine tag name as argument, for multi-stage boostbacks.
Set boosterEngine to ship:partstagged("booster")[0].
Print "Waiting to stage...".
Wait until boosterEngine:flameout.
Print "Staging.".
Stage.
Print "Est. impact distance from launch: " + round(impactDistance(),3) + "km".
Set reserveTank to ship:partstagged("reservefuel")[0].
Print "Zeroing throttle.".
Lock throttle to 0.
Print "Disabling SAS.".
SAS off.
Print "Waiting five seconds for separation.".
Wait 5.
Print "Est. impact distance from launch: " + round(impactDistance(),3) + "km".
Print "Enabling reserve fuel.".
For var in reserveTank:resources {
  Set var:enabled to true.
}.
Print "Enabling RCS.".
RCS on.
Print "Steering west.".
Lock steering to heading(270,0) + R(0,0,270).
Print "Waiting for steering...".
Set dueWest to heading(270,0) + R(0,0,270).
Until vectorangle(facing:forevector,dueWest:forevector) < 2 {
  Print "Difference from west: " + round(vectorangle(facing:forevector,dueWest:forevector),2).
  Wait 1.
}.
Print "Est. impact distance from launch: " + round(impactDistance(),3) + "km".
Print "Prepping abort conditions.".
Set boostingBack to false.
Set overshooting to false.
Set emergencyAbort to false.
When boostingBack or overshooting then {
  When landingDV(boosterEngine, reserveTank:resources) < 350 then {
    Print "Landing capacity < 350 dv!".
    Lock throttle to 0.
    Set boostingBack to false.
    Set overshooting to false.
    Set emergencyAbort to true.
  }.
}.
Print "Boosting back!".
Set boostingBack to true.
Lock throttle to 1.
Until not boostingBack {
  Set currentImpactDistance to impactDistance().
  Print "Est. impact distance from launch: " + round(currentImpactDistance,3) + "km".
  If currentImpactDistance < 50 and not emergencyAbort {
    Lock throttle to max(currentImpactDistance / 50, 0.05).
    Print "Setting throttle to " + round(throttle * 100,2) + "%".
  }.
  If currentImpactDistance < 1 {
    Print "Est. impact distance from launch < 1km!".
    Lock throttle to 0.
    Set boostingBack to false.
  }.
}.
If not emergencyAbort {
  Print "Intentionally overshooting.". //Better to be on land than fall short on water.
  Set overshooting to true.
  Lock throttle to 0.05.
  Until not overshooting {
    Set currentImpactDistance to impactDistance().
    Print "Est. impact distance from launch: " + round(currentImpactDistance,3) + "km".
    If currentImpactDistance > 2 { //Determined experimentally.
      Print "Overshoot complete.".
      Lock throttle to 0.
      Set overshooting to false.
    }.
  }.
}.
Print "Releasing control.".
Lock throttle to 0.
Print "Est. dv available for landing: " + round(landingDV(boosterEngine, reserveTank:resources),2).
RCS off.
Unlock steering.
Unlock throttle.
Set surfaceReached to false.
When altitude < 15000 then {
  Print "Deploying brakes.".
  Brakes on.
  When altitude < 10000 then {
    Print "Deploying landing gear.".
    Gear on.
    When altitude < 5000 then {
      Print "Enabling RCS.".
      RCS on.
      When status = "LANDED" or status = "SPLASHED" then {
        Set surfaceReached to true.
        Print "Enabling SAS.".
        SAS on.
      }.
    }.
  }.
}.
Until surfaceReached {
  Print "Est. impact distance from launch: " + round(impactDistance(),3) + "km".
  Wait 5.
}.
Print "Surface reached. Program ending.".

Function impactLongitude {
  Set someTime to time.
  set somePosition to positionat(ship, someTime).
  Set someVector to somePosition - body:position.
  Set someAltitude to ship:altitude.
  Until someAltitude < 75 {
    Set someTime to someTime + 1.
    Set somePosition to positionat(ship, someTime).
    Set someVector to somePosition - body:position.
    Set someAltitude to someVector:mag - body:radius.
  }.
  return body:geopositionof(somePosition):lng - ((someTime:seconds - time:seconds)/60).
  //Alternate method: calculate from true anomaly at time of impact.
  //Better method: just get the Trajectories mod.
}.

Function impactDistance {
  return abs(impactLongitude() - launchLongitude) * (2 * constant:pi * body:radius / 360 / 1000).
}.

Function landingDV {
  Parameter landingEngine, availablePropellants.
  Set propellantMass to 0.
  For var in availablePropellants {
    Set propellantMass to propellantMass + (var:amount * var:density).
  }.
  return ln(mass / (mass - propellantMass)) * landingEngine:sealevelisp * 9.81.
}.
