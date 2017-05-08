//Built from http://wiki.kerbalspaceprogram.com/wiki/Specific_impulse#Multiple_engines

Function averageIspAt {
  Parameter engineList, targetPressure.
  Local totalVacThrust is 0.
  Local totalActualThrust is 0.
  Local totalFuelFlow is 0.
  For eng in engineList {
    Set totalVacThrust to totalVacThrust + eng:maxthrustat(0).
    Set totalFuelFlow to totalFuelFlow + (eng:maxthrustat(0) / eng:vacuumisp). //replace this with engine:fuelflow
    Set totalActualThrust to totalActualThrust + eng:maxthrustat(targetPressure).
  }.
  Return totalActualThrust / totalFuelFlow.
}.
