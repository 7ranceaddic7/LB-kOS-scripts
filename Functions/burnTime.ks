//Adapted from https://www.reddit.com/r/Kos/comments/3ftcwk/compute_burn_time_with_calculus/

Copypath("0:/Functions/averageIsp","1:").
Run once "averageIsp".
Copypath("0:/Functions/availableEngines","1:").
Run once "availableEngines".

Function burnTime {
  Parameter nodeDV.
  Local availableIsp is averageIspAt(availableEngines(),0).
  Return 9.80665 * mass * availableIsp * (1 - constant:e ^ (-nodeDV / (9.80665 * availableIsp))) / ship:availablethrust.
}.
