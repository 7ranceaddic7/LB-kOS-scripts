//Adapted from https://www.reddit.com/r/Kos/comments/3ftcwk/compute_burn_time_with_calculus/

Copypath("0:/avgIsp","1:").
Run once "avgIsp".

Function burnTime {
  Parameter nodeDV.
  List engines in allEngines.
  Local availableEngines to list().
  For eng in allEngines {
    If eng:ignition {
      availableEngines:add(eng).
    }
  }.
  //Print availableEngines:length + " engines available for burn out of " + allEngines:length + " total.".
  Local availableIsp = averageIsp(availableEngines).
  Return 9.80665 * mass * availableIsp * (1 - constant:e ^ (-nodeDV / (9.80665 * availableIsp))) / ship:availablethrust.
}.
