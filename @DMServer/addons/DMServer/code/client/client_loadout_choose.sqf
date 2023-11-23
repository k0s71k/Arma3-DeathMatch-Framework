#define GUI_GRID_H (0.04)
#define GUI_GRID_W (0.025)

if (time < DM_timeout) exitWith {};
DM_timeout = time + 0.5;

if ((player getVariable ["DM_CurrentLocation", ""]) != "MainBase") exitWith {
	["Доступно только на базе", "warning"] call client_gui_hint
};
// Создаем новый дисплей поверх игрового
private _display = (findDisplay 46) createDisplay "RscDisplayEmpty";
_display displayAddEventHandler ["KeyDown", {
	if ((_this # 1) == 1) exitWith {
		[_this # 0] spawn client_gui_unloadDisplay;
		true
	};
	false
}];

// Функция для создания элемента управления и установка ему нужной позиции
private _createControl = {
	params [
		"_display",
		"_class",
		"_position",
		"_backgroundColor"
	];

	private _control = _display ctrlCreate [_class, -1];
	_control ctrlSetPosition _position;
	_control ctrlSetBackgroundColor _backgroundColor;
	_control ctrlSetFade 1;
	_control ctrlCommit 0;
	_control
};
// Определяем цвета фона и элементов
private _mainBackground		= [0.1, 0.1, 0.1, 0.85];
private _elementBackground	= [0.15, 0.15, 0.15, 0.8];

// Задний фон для окон
private _weaponBackground = [_display, "RscText", [
	-1.5 * GUI_GRID_W,
	0,
	14 * GUI_GRID_W,
	25 * GUI_GRID_H
], _mainBackground] call _createControl;

private _ammoBackground = [_display, "RscText", [
	13 * GUI_GRID_W,
	0,
	14 * GUI_GRID_W,
	25 * GUI_GRID_H
], _mainBackground] call _createControl;

private _clothesBackground = [_display, "RscText", [
	28 * GUI_GRID_W,
	0,
	14 * GUI_GRID_W,
	25 * GUI_GRID_H
], _mainBackground] call _createControl;

// Загоолвки окон
private _weaponTitle = [_display, "RscText", [
	-1.5 * GUI_GRID_W,
	0,
	14 * GUI_GRID_W,
	1 * GUI_GRID_H
], _elementBackground] call _createControl;
_weaponTitle ctrlSetText "Выбор оружия:";

private _ammoTitle = [_display, "RscText", [
	13 * GUI_GRID_W,
	0,
	14 * GUI_GRID_W,
	1 * GUI_GRID_H
], _elementBackground] call _createControl;
_ammoTitle ctrlSetText "Выбор магазинов:";

private _clothesTitle = [_display, "RscText", [
	28 * GUI_GRID_W,
	0,
	14 * GUI_GRID_W,
	1 * GUI_GRID_H
], _elementBackground] call _createControl;
_clothesTitle ctrlSetText "Выбор одежды:";

private _weaponList = [_display, "DM_ListBox", [
	-1 * GUI_GRID_W,
	1.3 * GUI_GRID_H,
	13 * GUI_GRID_W,
	23.4 * GUI_GRID_H
], _elementBackground] call _createControl;

private _ammoList = [_display, "DM_ListBox", [
	13.5 * GUI_GRID_W,
	1.3 * GUI_GRID_H,
	13 * GUI_GRID_W,
	11.5 * GUI_GRID_H
], _elementBackground] call _createControl;

private _opticsList = [_display, "DM_ListBox", [
	13.5 * GUI_GRID_W,
	13.2 * GUI_GRID_H,
	13 * GUI_GRID_W,
	11.5 * GUI_GRID_H
], _elementBackground] call _createControl;

private _clothesList = [_display, "DM_ListBox", [
	28.5 * GUI_GRID_W,
	1.3 * GUI_GRID_H,
	13 * GUI_GRID_W,
	23.4 * GUI_GRID_H
], _elementBackground] call _createControl;

// Добавляем обработчики на бвойной клик по елементу списка
private _addEvent = {
	(_this # 0) ctrlAddEventHandler ["LBDblClick", (_this # 1)];
};

[_weaponList, {
	private _class = (_this # 0) lbData (_this # 1);
	player addWeapon _class;
	[format["Вы получили '%1'", (_this # 0) lbText (_this # 1)], "info"] call client_gui_hint
}] call _addEvent;

[_ammoList, {
	private _class = (_this # 0) lbData (_this # 1);
	if !(player canAddItemToBackpack _class) exitWith {["Недостаточно места в рюкзаке", "error"] call client_gui_hint};
	player addItemToBackpack _class;
}] call _addEvent;

[_clothesList, {
	private _class = (_this # 0) lbData (_this # 1);
	private _packConfig = (missionConfigFile >> "DMCfgClothes" >> _class);
	// Получаем классы из конфига
	private _uniformClass 	= getText(_packConfig >> "uniform");
	private _vestClass 		= getText(_packConfig >> "vest");
	private _backClass 		= getText(_packConfig >> "backpack");
	private _headClass 		= getText(_packConfig >> "headgear");
	private _gogglesClass 	= getText(_packConfig >> "goggles");
	private _binocularClass = getText(_packConfig >> "binocular");
	private _gpsClass 		= getText(_packConfig >> "gps");
	private _nvgClass 		= getText(_packConfig >> "nightVision");
	// Выдаем выбранный пак
	player forceAddUniform	_uniformClass;
	player addVest			_vestClass;
	player addBackpack		_backClass;
	player addHeadgear		_headClass;
	player addGoggles		_gogglesClass;
	player addWeapon		_binocularClass;
	player linkItem			_gpsClass;
	player linkItem			_nvgClass;
	// Удаляем вещи из рюкзака
	clearAllItemsFromBackpack player;
	// Уведомление
	[format["Вы получили '%1'", getText(_packConfig >> "displayName")], "info"] call client_gui_hint;
	// Удаляем появившийся лут на земле
	private _groundHolders = nearestObjects[player, ["GroundWeaponHolder"], 10];
	if (count _groundHolders == 0) exitWith {};
	{
		deleteVehicle _x
	} foreach _groundHolders;
}] call _addEvent;

[_opticsList, {
	params ["_control", "_currentSelect"];
	private _class = _control lbData _currentSelect;

	player addWeaponItem [primaryWeapon player, _class];
}] call _addEvent;

// Добавляем оружия из конфига в список
{
	private _class	= configName _x;
	if (!isClass (configFile >> "CfgWeapons" >> _class)) then {continue};
	_weaponList lbAdd getText(configFile >> "CfgWeapons" >> _class >> "displayName");

	private _index	= lbSize _weaponList - 1;
	_weaponList		lbSetPicture [_index, getText(configFile >> "CfgWeapons" >> _class >> "picture")];
	_weaponList		lbSetData [_index, _class];
} foreach ("true" configClasses (missionConfigFile >> "DMCfgWeapons"));

// Добавляем магазины из конфига
{
	private _magClass = configName _x;
	if !(isClass (configFile >> "CfgMagazines" >> _magClass)) then {continue};
	_ammoList lbAdd getText(configFile >> "CfgMagazines" >> _magClass >> "displayName");

	private _index	= lbSize _ammoList - 1;
	_ammoList		lbSetPicture [_index, getText(configFile >> "CfgMagazines" >> _magClass >> "picture")];
	_ammoList		lbSetData [_index, _magClass];
} foreach ("true" configClasses (missionConfigFile >> "DMCfgMagazines"));

// Добавляем пресеты одежды из конфига
{
	private _class = configName _x;
	
	_clothesList lbAdd getText (_x >> "displayName");
	private _picture = getText(_x >> "picture");
	if (_picture == "") then {
		_picture = getText(configFile >> "CfgWeapons" >> getText(_x >> "uniform") >> "picture")
	};
	_clothesList lbSetPicture [_forEachIndex, _picture];
	_clothesList lbSetData [_forEachIndex, _class];
} foreach ("true" configClasses (missionConfigFile >> "DMCfgClothes"));

// Прицелы из конфига
{
	private _opticClass		= configName _x;
	private _opticConfig	= (configFile >> "CfgWeapons" >> _opticClass);
	if !(isClass _opticConfig) then {continue};

	_opticsList	lbAdd getText(_opticConfig >> "displayName");
	_index		= lbSize _opticsList - 1;
	_opticsList	lbSetPicture [_index, getText(_opticConfig >> "picture")];
	_opticsList	lbSetData [_index, _opticClass];
} foreach ("true" configClasses (missionConfigFile >> "DMCfgOptics"));

// Воспроизводим анимацию появления
{
	_x ctrlSetFade 0;
	_x ctrlCommit 0.3
} foreach allControls _display;