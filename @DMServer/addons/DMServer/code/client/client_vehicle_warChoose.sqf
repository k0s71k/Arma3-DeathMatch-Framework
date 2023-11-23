#define GUI_GRID_W    (0.025)
#define GUI_GRID_H    (0.04)

if (time < DM_timeout) exitWith {};
DM_timeout = time + 0.5;

if !(player getVariable ["DM_WarVehicleMode", false]) exitWith {
	["Нельзя открыть меню боевой техники, не находясь на одной из специальных баз спавна", "error"] call client_gui_hint
};

private _warLocation = player getVariable ["DM_WarVehicleBase", ""];
if (_warLocation == "") exitWith {
	["Ошибка режима боевой техники, сообщите администрации", "error"] call client_gui_hint
};

private _display = (findDisplay 46) createDisplay "RscDisplayEmpty";
_display displayAddEventHandler ["KeyDown", {
	if ((_this # 1) == 1) exitWith {
		[_this # 0] spawn client_gui_unloadDisplay;
		true
	};
	false
}];

// Создаем элементы
private _background = _display ctrlCreate ["RscText", -1];
private _title = _display ctrlCreate ["RscText", -1];
private _vehList = _display ctrlCreate ["DM_ListBox", -1]; 

_background ctrlSetPosition [
	14 * GUI_GRID_W,
	0,
	15 * GUI_GRID_W,
	25 * GUI_GRID_H
];
_title ctrlSetPosition [
	14 * GUI_GRID_W,
	0,
	15 * GUI_GRID_W,
	1 * GUI_GRID_H
];
_vehList ctrlSetPosition [
	14.5 * GUI_GRID_W,
	1.3 * GUI_GRID_H,
	14 * GUI_GRID_W,
	23.4 * GUI_GRID_H
];

_title ctrlSetText "Выбор боевой техники:";

_background ctrlSetBackgroundColor	[0.1, 0.1, 0.1, 0.85];
_title ctrlSetBackgroundColor		[0.15, 0.15, 0.15, 0.8];
_vehList ctrlSetBackgroundColor		[0.15, 0.15, 0.15, 0.8];

{
	_x ctrlSetFade 1;
	_x ctrlCommit 0
} foreach [_background, _title, _vehList];

_vehList ctrlAddEventHandler ["LBDblClick", {
	if (time < DM_timeout) exitWith {["Вы делаете это слишком часто", "warning"] call client_gui_hint};
	DM_timeout = time + 0.5;

	params ["_control", "_currentSelect"];
	private _vehClass		= _control lbData _currentSelect;
	private _locationClass	= player getVariable ["DM_WarVehicleBase", ""];
	private _direction		= getNumber(missionConfigFile >> "DMCfgSpawn" >> _locationClass >> "spawnDirection");
	private _spawnPositions	= getArray(missionConfigFile >> "DMCfgSpawn" >> _locationClass >> "vehicleSpawns");

	{
		if (count (nearestObjects[_x, ["Car", "Air", "Tank"], 10]) == 0) exitWith {
			[_vehClass, _x, _direction] RemoteExecCall ["server_spawn_vehicle", 2]
		};
	} foreach _spawnPositions;
}];

{
	private _vehClass		= configName _x;
	private _displayName	= getText(configFile >> "CfgVehicles" >> _vehClass >> "displayName");
	private _picture		= getText(configFile >> "CfgVehicles" >> _vehClass >> "picture");

	_vehList lbAdd			_displayName;
	_vehList lbSetPicture	[_forEachIndex, _picture];
	_vehList lbSetData		[_forEachIndex, _vehClass];
} foreach ("true" configClasses (missionConfigFile >> "DMCfgWarVehicles"));

{
	_x ctrlSetFade 0;
	_x ctrlCommit 0.25
} foreach [_background, _title, _vehList];