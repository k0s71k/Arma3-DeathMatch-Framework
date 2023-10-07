#define GUI_GRID_H (0.04)
#define GUI_GRID_W (0.025)

if (time < DM_timeout) exitWith {};
DM_timeout = time + 0.5;
// Создаем новый дисплей на основе игрового
private _display = (findDisplay 46) createDisplay "RscDisplayEmpty";
_display displayAddEventHandler ["KeyDown", {
	if ((_this # 1) == 1) exitWith {
		[_this # 0] spawn client_gui_unloadDisplay;
		true
	};
	false
}];

private _mainBackground = [0.1, 0.1, 0.1, 0.85];
private _elementBackground = [0.15, 0.15, 0.15, 0.8];

private _createControl = {
	params [
		["_display", displayNull, [displayNull]],
		["_position", [0,0,0,0], [[]]],
		["_class", "", [""]],
		["_color", [0,0,0,0], [[]]],
		["_inGroup", false, [false]],
		["_controlsGroup", controlNull, [controlNull]]
	];

	private "_control";
	if (_inGroup) then {
		_control = _display ctrlCreate [_class, -1, _controlsGroup]
	} else {
		_control = _display ctrlCreate [_class, -1];
	};

	_control ctrlSetPosition _position;
	_control ctrlSetBackgroundColor _color;
	_control ctrlSetFade 1;
	_control ctrlCommit 0;
	_control
};

private _dmLocationsGroup = [_display, [
	4.5 * GUI_GRID_W,
	0,
	15 * GUI_GRID_W,
	25 * GUI_GRID_H
], "RscControlsGroupNoScrollBars"] call _createControl;

private _vehLocationsGroup = [_display, [
	20 * GUI_GRID_W,
	0,
	15 * GUI_GRID_W,
	25 * GUI_GRID_H
], "RscControlsGroupNoScrollBars"] call _createControl;

private _dmBackground = [_display, [
	0,
	0,
	15 * GUI_GRID_W,
	25 * GUI_GRID_H
], "RscText", _mainBackground, true, _dmLocationsGroup] call _createControl;

private _vehBackground = [_display, [
	0,
	0,
	15 * GUI_GRID_W,
	25 * GUI_GRID_H
], "RscText", _mainBackground, true, _vehLocationsGroup] call _createControl;

private _dmTitle = [_display, [
	0,
	0,
	15 * GUI_GRID_W,
	1 * GUI_GRID_H
], "RscText", _elementBackground, true, _dmLocationsGroup] call _createControl;
_dmTitle ctrlSetText "Выбор локации: ";

private _vehTitle = [_display, [
	0,
	0,
	15 * GUI_GRID_W,
	1 * GUI_GRID_H
], "RscText", _elementBackground, true, _vehLocationsGroup] call _createControl;
_vehTitle ctrlSetText "Локации спавна техники: ";

private _dmList = [_display, [
	0.5 * GUI_GRID_W,
	1.3 * GUI_GRID_H,
	14 * GUI_GRID_W,
	23.4 * GUI_GRID_H
], "DM_ListBox", _elementBackground, true, _dmLocationsGroup] call _createControl;

private _vehList = [_display, [
	0.5 * GUI_GRID_W,
	1.3 * GUI_GRID_H,
	14 * GUI_GRID_W,
	23.4 * GUI_GRID_H
], "DM_ListBox", _elementBackground, true, _vehLocationsGroup] call _createControl;

private _addEvent = {
	(_this # 0) ctrlAddEventHandler ["LBDblClick", (_this # 1)];
};
// Добавляем обработчики двойного клика
[_dmList, {
	if (time < DM_timeout) exitWith {["Вы делаете это слишком часто", "warning"] call client_gui_hint};
	DM_timeout = time + 0.5;

	params ["_control", "_currentSelect"];
	private _positionArray = parseSimpleArray (_control lbData _currentSelect);
	private _locationName = _control lbText _currentSelect;

	[_positionArray, _locationName] spawn client_spawn_onPosition;
	[ctrlParent _control] spawn client_gui_unloadDisplay;
}] call _addEvent;

[_vehList, {
	if (time < DM_timeout) exitWith {["Вы делаете это слишком часто", "warning"] call client_gui_hint};
	DM_timeout = time + 0.5;

	params ["_control", "_currentSelect"];
	private _positionArray = parseSimpleArray (_control lbData _currentSelect);

	_positionArray spawn client_spawn_vehicleWar;
	[ctrlParent _control] spawn client_gui_unloadDisplay;
}] call _addEvent;

// Заполняем возможные спавны для взлёта на боевой
{
	if (configName _x == "DefaultBase") then {continue};

	private _name = getText(_x >> "displayName");
	private _position = getArray(_x >> "spawnPos");

	_vehList lbAdd _name;
	_vehList lbSetData [lbSize _vehList - 1, format["[%1,'%2']", _position, configName _x]];
} foreach ("true" configClasses (missionConfigFile >> "DMCfgSpawn"));

// Воспроизводим анимацию появления менюшки
{
	_x ctrlSetFade 0;
	_x ctrlCommit 0.3
} foreach (allControls _display);

// Добавляем все локации в таблицу
lbClear _dmList;
{
	private _position = _x # 0;
	private _name = _x # 1;
	private _size = _x # 2;
	private _angle = _x # 3;
	_dmList lbAdd _name;
	_dmList lbSetData [_forEachIndex, str [_position, _size, _angle]];
} foreach DM_Locations;

// Обновляем таблицу локаций пока существует созданный дисплей
while {!isNull _display} do {
	{
		private _position = _x # 0;
		private _name = _x # 1;
		private _size = _x # 2;
		private _angle = _x # 3;
		private _playersCount = ({(position _x) inArea [_position, _size, _size, _angle, false]} count playableUnits);
		_dmList lbSetTextRight [_forEachIndex, format["В зоне: %1", _playersCount]];

		private _itemColor = [[0.95, 0.95, 0.95, 0.9], [0.6, 0.6, 0.2, 0.9]] select (_playersCount > 0);
		_dmList lbSetColor [_forEachIndex, _itemColor];
		_dmList lbSetColorRight [_forEachIndex, _itemColor]
	} foreach DM_Locations;
	uiSleep 0.3;
};