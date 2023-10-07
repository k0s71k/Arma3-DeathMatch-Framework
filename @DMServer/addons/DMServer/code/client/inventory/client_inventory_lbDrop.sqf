params ["_ctrl", "_xPos", "_yPos", "_listboxIDC", "_listboxInfo"];
(_listboxInfo # 0) params [
	"_lbText",
	"_lbValue",
	"_lbData"
];

private _display = ctrlParent _ctrl;
private _fromContainer = _display getVariable ["fromContainer",objNull];
private _toContainer = _ctrl getVariable ["containerObject",objNull];
// Пропускаем одинаковые контейнеры
if (_fromContainer isEqualTo _toContainer) exitWith {};

_display setVariable ["toContainer", _toContainer];
_display setVariable ["toIDC",ctrlIDC _ctrl];
private _data = call compile _lbData;
_data params ["_class", "_displayname", "_config", "_mass", "_amount", "_itemdata"];

// Контейнер - контейнер
if (!(player in [_toContainer, _fromContainer])) exitWith {
	private _altKey = _display getVariable ["altKey", false];
	private _shiftKey = _display getVariable ["shiftKey", false];
	switch (true) do {
		// Перемещаем всё
		case _altKey: {[false, _toContainer, _fromContainer, _data] call client_inventory_makeCounter};
		// Спрашиваем количество
		case _shiftKey : {[true, _toContainer, _fromContainer, _data] call client_inventory_makeCounter};
		// Перемещаем одну вещь
		default {[_class, _displayname, _config, _mass, 1, _itemdata] call client_inventory_moveItem};
	};
};

[_class, _displayname, _config, _mass, 1, _itemdata] call client_inventory_moveItem;