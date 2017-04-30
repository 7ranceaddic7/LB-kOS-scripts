//Built from http://wiki.kerbalspaceprogram.com/wiki/Specific_impulse#Multiple_engines

Function averageIsp {
  Parameter engineList.
  Local totalThrust = 0.
  Local totalFuelFlow = 0.
  For eng in engineList {
    totalThrust = totalThrust + eng:maxthrust.
    totalFuelFlow = totalFuelFlow + (eng:maxthrust / eng:isp).
  }.
  Return totalThrust / totalFuelFlow.
}.
