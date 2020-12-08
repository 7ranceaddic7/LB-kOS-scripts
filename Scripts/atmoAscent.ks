If homeConnection:isConnected {
  Copypath("0:/Functions/gravityTurn","1:").
}.
Run once "gravityTurn".

If homeConnection:isConnected {
  Copypath("0:/Functions/circularize","1:").
}.
Run once "circularize".

Set safeOrbit to body:atm:height + 5000.
gravityTurn(safeOrbit).
Circularize().
