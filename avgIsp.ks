//Built from http://wiki.kerbalspaceprogram.com/wiki/Specific_impulse#Multiple_engines

Function averageIsp {
  Parameter engineList.
  Local totalThrust is 0.
  Local totalFuelFlow is 0.
  For eng in engineList {
    Set totalThrust to totalThrust + eng:maxthrust.
    Set totalFuelFlow to totalFuelFlow + (eng:maxthrust / eng:isp).
  }.
  Return totalThrust / totalFuelFlow.
}.
