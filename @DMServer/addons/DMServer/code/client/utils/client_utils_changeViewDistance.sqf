params ["_increase"];

if (time < DM_timeout) exitWith {};
DM_timeout = time + 0.5;
if (DM_viewDistance <= 200 OR DM_viewDistance >= 12000) exitWith {};


DM_viewDistance = [round(DM_viewDistance - 100), round(DM_viewDistance + 100)] select _increase;
profileNamespace setVariable ["DM_viewDistance", DM_viewDistance];
setViewDistance DM_viewDistance;
setObjectViewDistance DM_viewDistance - 100;
[format["Дистанция прорисовки %1м.", DM_viewDistance], "info"] call client_gui_hint;