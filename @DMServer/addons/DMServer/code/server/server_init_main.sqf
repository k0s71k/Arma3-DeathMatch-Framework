//server_init_main

diag_log "---------------------------------- Starting DM Server Init ----------------------------------";
diag_log "----------------------------------------- Version 1 -----------------------------------------";

addMissionEventHandler ["HandleDisconnect", {_this call server_event_clientDisconnect; false}];

[] spawn server_init_locations;

[] spawn server_init_restarts;

missionNamespace setVariable ["server_isReady", true, true];

"2609" serverCommand "#monitords 10";
