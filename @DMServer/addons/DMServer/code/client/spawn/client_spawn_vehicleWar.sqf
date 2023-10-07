//client_spawn_vehicleWar
params [
	["_position", [0,0,0], [[]]],
	["_configName", "", [""]]
];

cutText ["", "BLACK FADED", 0, true];
player setPosATL _position;
player setVelocity [0, 0, 0];
player setVariable ["DM_CurrentLocation", "War Vehicle Base", true];
player setVariable ["DM_WarVehicleBase", _configName];

uiSleep 1;
cutText ["", "BLACK IN", 1, true];

player setVariable ["DM_WarVehicleMode", true, true];
uiSleep 1;

[
	"Управление для режима боевой техники
	<br/><br/>Открыть меню боевой техники <t color='#f5be00'>'F3'</t>",
"info"] call client_gui_hint;