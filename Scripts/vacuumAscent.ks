Copypath("0:/Functions/circularize","1:").
Run once "circularize".

Runpath("0:/preferences").

Set targetAltitude to minSafeAlt().

SAS off.
Lock steering to heading(90,90) + R(0,0,270).
Print "Launch!".
Lock throttle to 1.
Wait 2.
Lock steering to heading(90,45) + R(0,0,270).
Wait 3.
Until apoapsis > targetAltitude {
  If addons:tr:impactPos:terrainHeight > altitudeAt(time + 60) {
    If addons:tr:impactPos:terrainHeight > altitudeAt(time + 30) {
      Print "Impact height: " + round(addons:tr:impactPos:terrainHeight,0) + "m; Alt in 30s: " + round(altitudeAt(time + 30),0) + "m".
      Lock steering to heading(90,90) + R(0,0,270).
    } else {
      Print "Impact height: " + round(addons:tr:impactPos:terrainHeight,0) + "m; Alt in 60s: " + round(altitudeAt(time + 60),0) + "m".
      Lock steering to heading(90,45) + R(0,0,270).
    }
  }
  else {
    Lock steering to heading(90,0) + R(0,0,270).
  }.
  Wait 0.25.
}.
Lock throttle to 0.
Circularize().

Function minSafeAlt {
  If body:name = "Mun" return 15000.
  If body:name = "Minmus" return 10000.
  If body:name = "Moho" return 15000.
  If body:name = "Gilly" return 10000.
  If body:name = "Ike" return 20000.
  If body:name = "Dres" return 15000.
  If body:name = "Vall" return 15000.
  If body:name = "Tylo" return 20000.
  If body:name = "Bop" return 30000.
  If body:name = "Pol" return 10000.
  If body:name = "Eeloo" return 10000.
}.

Function altitudeAt {
  Parameter someTime.
  Local somePosition is positionat(ship,someTime).
  Local someVector is somePosition - body:position.
  Return someVector:mag - body:radius.
}.
