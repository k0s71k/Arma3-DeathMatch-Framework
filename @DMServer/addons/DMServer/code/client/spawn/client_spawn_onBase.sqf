cutText ["", "BLACK FADED", 0, true];
player setDamage 0;
player setPosATL getArray(missionConfigFile >> "DMCfgSpawn" >> "DefaultBase" >> "spawnPos");
player setVelocity [0, 0, 0];
player setVariable ["DM_CurrentLocation", "MainBase", true];
player setVariable ["DM_WarVehicleMode", false, true];
player setVariable ["DM_WarVehicleBase", ""];
uiSleep 1;
DM_Killed = false;
cutText ["", "BLACK IN", 1, true];