#define GUI_GRID_H (0.04)
#define GUI_GRID_W (0.025)

params [
	["_askCount", false],
	["_toContainer", objNull],
	["_fromContainer", objNull],
	["_data", []]
];

_data params [
	"_class",
	"_displayname",
	"_config",
	"_mass",
	"_maxamount",
	"_itemdata"
];

private _containerLoad		= _toContainer getVariable ["currentWeight", 0];
private _containerLoadMax	= _toContainer getVariable ["maximumWeight", 0];

// Выходим если только одна единица предмета
if (_maxamount == 1) exitWith {[_class, _displayname, _config, _mass, 1, _itemdata] call client_inventory_moveItem};
// Переопределяем максимальное количество предмета в зависимости от загрузки контейнера
_maxamount = _maxamount min floor((_containerLoadMax - _containerLoad) / _mass);

// Перемещаем все возможное
if !(_askCount) exitWith {
	[_class, _displayname, _config, _mass, _maxamount, _itemdata] call client_inventory_moveItem;
};

// Создаем новые контрола чтобы спросить сколько нужно переместить
private _group = _display ctrlCreate ["RscControlsGroupNoScrollBars", -1];
_group ctrlSetPosition [
	13 * GUI_GRID_W,
	10 * GUI_GRID_H,
	13 * GUI_GRID_W,
	3 * GUI_GRID_H
];
_group ctrlSetFade 1;
_group ctrlCommit 0;
_group setVariable ["countTransfer", _maxamount];
private _groupPos = ctrlPosition _group;

private _background = [_display, [
	0,
	0,
	_groupPos # 2,
	_groupPos # 3
], "RscText", _group] call client_inventory_createControl;

private _countText = [_display, [
	0,
	0,
	_groupPos # 2,
	(_groupPos # 3) / 3
], "RscStructuredText", _group] call client_inventory_createControl;
_countText ctrlSetStructuredText parseText "<t align='center'>Укажите количество";

private _slider = [_display, [
	0,
	1 * GUI_GRID_H,
	_groupPos # 2,
	(_groupPos # 3) / 3
], "RscXSliderH", _group, false] call client_inventory_createControl;

_slider sliderSetRange [1, _maxamount];
_slider sliderSetSpeed [1, 1];
_slider sliderSetPosition _maxamount;
ctrlSetFocus _slider;
_slider setVariable ["data", [_countText, _displayname, _mass]];
_slider setVariable ["toContainer", _toContainer];

// По нажатию на кнопку удаляем группу контролов
_slider ctrlAddEventHandler ["KillFocus", {
	params ["_ctrl"];
	(ctrlParentControlsGroup _ctrl) spawn {
		_this ctrlEnable false;
		_this ctrlSetFade 1;
		_this ctrlCommit 0.1;
		waitUntil {ctrlCommitted _this};
		ctrlDelete _this;
	};
}];
// Отслеживаем изменения слайдера
_slider ctrlAddEventHandler ["SliderPosChanged",{
	params ["_slider", "_value"];
	private _value			= round _value max 1;
	private _data			= _slider getVariable ["data", []];
	private _toContainer	= _slider getVariable ["toContainer",objNull];
	_data params ["_counter","_displayname","_mass"];

	_counter ctrlSetStructuredText parseText format ["<t align='center'>%1x %2", _value, _displayName];
	(ctrlParentControlsGroup _slider) setVariable ["countTransfer", _value];
}];

private _confirmButton = [_display, [
	0,
	2 * GUI_GRID_H,
	_groupPos # 2,
	(_groupPos # 3) / 3
], "RscStructuredText", _group] call client_inventory_createControl;

_confirmButton ctrlSetStructuredText parseText "<t align='center' underline='1'>Переместить";
_confirmButton ctrlEnable true;
_confirmButton setVariable ["data", _data];
_confirmButton ctrlAddEventHandler ["MouseButtonDown", {
	params ["_ctrl"];
	private _thisGroup = ctrlParentControlsGroup _ctrl;
	private _display = ctrlParent _ctrl;
	private _countTransfer = _thisGroup getVariable ["countTransfer", 1];
	private _data = _ctrl getVariable ["data",[]];
	_thisGroup spawn {
		_this ctrlEnable false;
		_this ctrlSetFade 1;
		_this ctrlCommit 0.1;
		waitUntil {ctrlCommitted _this};
		ctrlDelete _this
	};
	_data params ["_class","_displayname","_config","_mass","","_itemdata"];
	[_class, _displayname, _config, _mass, _countTransfer, _itemdata] call client_inventory_moveItem;
	playSound "readoutClick";
}];

_group ctrlSetFade 0;
_group ctrlCommit 0.1;