//Launch functions
If homeConnection:isConnected {
  Copypath("0:/Functions/gravityTurn","1:").
}.
Run once "gravityTurn".

If homeConnection:isConnected {
  Copypath("0:/Functions/circularize","1:").
}.
Run once "circularize".

//Utilities
If homeConnection:isConnected {
  Copypath("0:/Functions/executeNode","1:").
}.
Run once "executeNode".
If homeConnection:isConnected {
  Copypath("0:/Scripts/executeNext","1:").
}.

If homeConnection:isConnected {
  Copypath("0:/Functions/hoverslam","1:").
}.
Run once "hoverslam".
If homeConnection:isConnected {
  Copypath("0:/Scripts/landNow","1:").
}.

If homeConnection:isConnected {
  Copypath("0:/Functions/circularize","1:").
}.
Run once "circularize".
If homeConnection:isConnected {
  Copypath("0:/Scripts/vacuumAscent","1:").
}.

If homeConnection:isConnected {
  Runpath("0:/preferences").
}.

If status = "PRELAUNCH" {
  Local defaultAltitude is (body:atm:height + 5000) / 1000.
  Local defaultInclination is 0.
  Local defaultTuningValue is 0.14.
  Local launchGUI is GUI(150,0).
  Local launchAltitudeLabel is launchGUI:addlabel("Altitude (km): ").
  Local launchAltitudeField is launchGUI:addtextfield(defaultAltitude:tostring).
  Local launchInclinationLabel is launchGUI:addlabel("Direction (deg): ").
  Local launchInclinationField is launchGUI:addtextfield(defaultInclination:tostring).
  Local tuningValueLabel is launchGUI:addlabel("Tuning value: ").
  Local tuningValueField is launchGUI:addtextfield(defaultTuningValue:tostring).
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
  Local tuningValue to tuningValueField:text:tonumber().
  ClearGUIs().
  gravityTurn(targetAltitude * 1000,targetDegreesFromNorth,tuningValue).
  Circularize().
  Print "Launch complete.".
  Set warp to 0.
  SAS on.
}.
