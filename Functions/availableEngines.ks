Function availableEngines {
  Local allEngines to list().
  List engines in allEngines.
  Local usableEngines to list().
  For eng in allEngines {
    If eng:ignition {
      usableEngines:add(eng).
    }.
  }.
  Return usableEngines.
}.
