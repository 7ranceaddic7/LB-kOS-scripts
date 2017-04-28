//Adapted from https://www.reddit.com/r/Kos/comments/3ftcwk/compute_burn_time_with_calculus/

//Arguments:
//nodeDV: scalar
//someEngine: engine

Function burnTime {
  Parameter nodeDV, someEngine.
  Return 9.80665 * mass * someEngine:isp * (1 - constant:e ^ (-nodeDV / (9.80665 * someEngine:isp))) / someEngine:maxthrust.
}.
