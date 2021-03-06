//Launch functions
Copypath("0:/Functions/gravityTurn","1:").
Run once "gravityTurn".

Copypath("0:/Functions/circularize","1:").
Run once "circularize".

//Utilities
Copypath("0:/Functions/executeNode","1:").
Run once "executeNode".
Copypath("0:/Scripts/executeNext","1:").

Copypath("0:/Functions/hoverslam","1:").
Run once "hoverslam".
Copypath("0:/Scripts/landNow","1:").

Copypath("0:/Functions/circularize","1:").
Run once "circularize".
Copypath("0:/Scripts/vacuumAscent","1:").

Runpath("0:/preferences").

If status = "PRELAUNCH" {
  Local defaultAltitude is body:atm:height + 5000.
  Local defaultInclination is 0.
  Local launchGUI is GUI(100,0).
  Local launchAltitudeLabel is launchGUI:addlabel("Altitude: ").
  Local launchAltitudeField is launchGUI:addtextfield(defaultAltitude:tostring).
  Local launchInclinationLabel is launchGUI:addlabel("Inclination: ").
  Local launchInclinationField is launchGUI:addtextfield(defaultInclination:tostring).
  Local launchButton is launchGUI:addbutton("Launch!").
  Local launchTime is false.
  function checkLaunchTime {
    set launchtime to true.
  }
  Set launchButton:onclick to checkLaunchTime@.
  launchGUI:show().
  Wait until launchTime.
  Local targetAltitude to launchAltitudeField:text:tonumber().
  Local targetDegreesFromNorth to launchInclinationField:text:tonumber() + 90.
  ClearGUIs().
  gravityTurn(targetAltitude,targetDegreesFromNorth).
  Circularize().
  Print "Launch complete.".
  Set warp to 0.
  SAS on.
}.
