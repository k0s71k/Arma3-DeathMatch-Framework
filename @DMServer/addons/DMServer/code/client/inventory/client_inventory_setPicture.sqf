private _ctrlSetToolTip = {
	params ["_control", ["_classname",""], "_config"];

	_control ctrlSetTooltipColorBox [0.6, 0.6, 0.6, 1];
	_control ctrlSetTooltipColorShade [0.1, 0.1, 0.1, 0.9];

	if (_item isEqualTo "") exitWith {
		private _text = "Пустой слот\n\nНажмите ПКМ для списка действий";
		_control ctrlSetTooltip _text;
		_control setVariable ["data", []];
	};
	private _displayName = getText (configFile >> _config >> _classname >> "displayName");
	private _massUnit = switch (true) do {
		case (isClass (configFile >> _config >> _classname >> "WeaponSlotsInfo")): {getNumber (configFile >> _config >> _classname >> "WeaponSlotsInfo" >> "mass")};
		case (_config isEqualTo "CfgGlasses")	: {getNumber (configFile >> "CfgGlasses" >> _classname >> "mass")};
		case (_config isEqualTo "CfgMagazines")	: {getNumber (configFile >> "CfgMagazines" >> _classname  >> "mass")};
		case (_config isEqualTo "CfgVehicles")	: {getNumber (configFile >> "CfgVehicles" >> _classname >> "mass")};
		default {getNumber (configFile >> _config >> _classname >> "ItemInfo" >> "mass")};
	};	
	private _text = format["%1\nВес: %2 кг",_displayName,_massUnit / 20 toFixed 1];
	private _descriptionShort = ((getText (configFile >> _config >> _classname >> "descriptionShort") splitString "<>") - ["br /","br/"]) joinString "\n";
	if !(_descriptionShort isEqualTo "") then {
		_text = _text + format["\n%1",_descriptionShort];
	};
	if (_config isEqualTo "CfgVehicles") then {
		private _maxLoad = getNumber (configFile >> "CfgVehicles" >> _classname >> "maximumLoad");
		_text = _text + format["\nПереносимый вес: %1 кг", _maxLoad / 20 toFixed 1];
	};

	_text = _text + "\n\nНажмите ПКМ для списка действий";
	_control ctrlSetTooltip _text;
	_control setVariable ["data", [_classname, _displayName, _config, _massUnit, 1]];
};

params [
	["_control",		controlNull,	[controlNull]],
	["_item",			"",				[""]],
	["_configClass",	"",				[""]],
	["_defaultPicture",	"",				[""]]
];
// Устанавливаем подсказку
[_control, _item, _configClass] call _ctrlSetToolTip;
if (_item == "") exitWith {
	_control ctrlSetText _defaultPicture
};
// Устанавливаем полученную картинку
_control ctrlSetText getText(configFile >> _configClass >> _item >> "picture");
