params ["_list","_index"];
private _data = call compile (_list lbData _index);
_data params ["_classname","_displayName","_config","_mass","_count","_data"];
private _text = format["%1\nВес: %2 кг",_displayName,_mass / 20 toFixed 1];
private _descriptionShort = ((getText (configFile >> _config >> _classname >> "descriptionShort") splitString "<>") - ["br /","br/"]) joinString "\n";
if !(_descriptionShort isEqualTo "") then {
	_text = _text + format["\n%1",_descriptionShort];
};
switch (_config) do {
	case "CfgWeapons": {
		if (_data isEqualTo []) exitWith {};
		_data params ["_weaponClass","_muzzle","_pointer","_optics","_magArray","_secMagArray","_bipod"];
		_text = _text + "\n";
		if !(_muzzle isEqualTo "") then {_text = _text + "\nИмеет глушитель"};
		if !(_pointer isEqualTo "") then {_text = _text + "\nИмеет указатель"};
		if !(_optics isEqualTo "") then {_text = _text + "\nИмеет оптику"};
		if !(_bipod isEqualTo "") then {_text = _text + "\nИмеет сошки"};
		if (!(_magArray isEqualTo []) OR !(_secMagArray isEqualTo [])) then {_text = _text + "\nОружие заряжено"};
	};
	case "CfgVehicles": {
		private _maxLoad = getNumber (configFile >> "CfgVehicles" >> _classname >> "maximumLoad");
		_text = _text + format["\nПереносимый вес: %1 кг",_maxLoad / 20 toFixed 1];
	};
	default {};
};
_text = _text + "\n\nНажмите ПКМ для списка действий";
_list lbSetTooltip [_index, _text];