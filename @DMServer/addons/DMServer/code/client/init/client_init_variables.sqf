//client_init_variables
DM_killFeed = [];
DM_hintData = [];
DM_timeout = time;
DM_viewDistance = (profileNamespace getVariable ["DM_viewDistance", 400]) max 200;
setViewDistance DM_viewDistance;
setObjectViewDistance DM_viewDistance - 100;
DM_lastHitFrom = nil;

player setVariable ["DM_Kills", 0, true];
player setVariable ["DM_Deaths", 0, true];
player setVariable ["DM_CurrentLocation", "MainBase", true];
player setVariable ["DM_WarVehicleBase", "", true];
player setVariable ["DM_WarVehicleMode", false, true];
player setVariable ["DM_InDuelLobby", false, true];
player setVariable ["DM_InDuel", false, true];