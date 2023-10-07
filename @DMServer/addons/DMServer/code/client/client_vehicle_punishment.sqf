// Наказываем человека на боевой технике, который стрелял по городам с пехами
if (isNull objectParent player) exitWith {};

private _vehicle = objectParent player;
player allowDamage false;
_vehicle setDamage 1;
player allowDamage true;
["Вы были наказаны за стрельбу по пехоте с боевой техники", "warning"] call client_gui_hint;
uiSleep 1;
deleteVehicle _vehicle;
[] spawn client_spawn_onBase