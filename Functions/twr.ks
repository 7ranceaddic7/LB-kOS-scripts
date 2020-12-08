If homeConnection:isConnected {
  Copypath("0:/Functions/availableEngines","1:").
}.
Run once "availableEngines".

Function TWR {
  Return TWRguts(ship:availablethrust).
}.

Function angledTWR {
  Return TWRguts(angledThrust()).
}.

Function TWRguts {
  Parameter someThrust.
  Local gravityHere is body:mu / (altitude + body:radius) ^ 2.
  Return someThrust / (mass * gravityHere).
}.

Function angledThrust {
  Local usedEngines is availableEngines().
  Local netThrust is 0.
  For eng in usedEngines {
    If eng:title = "Taurus HCV" or eng:name = "TaurusHCV" {
      set netThrust to netThrust + eng:availableThrust * 0.71.
    } else {
      Set netThrust to netThrust + eng:availableThrust * cos(vectorangle(facing:forevector,eng:facing:forevector)).
    }.
  }.
  Return netThrust.
}.
