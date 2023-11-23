params [
    ["_display",displayNull,[displayNull]]
];

_display setVariable ["container", _container];
_display setVariable ["readonly", _readonly];
// Mouse Moving для перемещения картинки
_display displayAddEventHandler ["MouseMoving", {
	params ["_display"];
	private _ghostCtrl = _display displayCtrl 1000;
	if (!isNull _ghostCtrl) then {
		getMousePosition params ["_mouseX","_mouseY"];
		_ghostPos = ctrlPosition _ghostCtrl;
		_ghostCtrl ctrlSetPosition [
			_mouseX - ((_ghostPos # 2) / 2),
			_mouseY - ((_ghostPos # 3) / 2),
			_ghostPos # 2,
			_ghostPos # 3];
		_ghostCtrl ctrlCommit 0;
		ctrlSetFocus _ghostCtrl;
	};
}];
// При отпускании мыши перетаскиваем предмет в нужный слот
_display displayAddEventHandler ["MouseButtonUp", {
	params ["_display"];
	private _ghostCtrl = _display displayCtrl 1000;
	private _data = _ghostCtrl getVariable ["data", []];
	private _readonly = _display getVariable ["readonly", false];
	ctrlDelete _ghostCtrl;
	_data params [
		["_classname",""],
		"_displayname",
		"_config",
		"_mass",
		["_amount", 1],
		"_itemdata"
	];
	if (_classname isEqualTo "") exitWith {};
	// Set specific data for subtractor 
	switch (true) do {
		case (_classname isEqualTo primaryWeapon player)	: {_data set [5, getUnitLoadout player # 0]};
		case (_classname isEqualTo secondaryWeapon player)	: {_data set [5, getUnitLoadout player # 1]};
		case (_classname isEqualTo handgunWeapon player)	: {_data set [5, getUnitLoadout player # 2]};
		case (_classname isEqualTo binocular player)		: {_data set [5, getUnitLoadout player # 8]};
		case (_classname in primaryWeaponMagazine player)	: {
			private _MagContainer	= getUnitLoadout player # 0 # 4;
			private _GLContainer	= getUnitLoadout player # 0 # 5;
			private _magazineData	= switch (true) do {
				case (_classname in _MagContainer): {_MagContainer};
				case (_classname in _GLContainer): {_GLContainer};
			};
			_data set [5,_magazineData];
		};					
		case (_classname in secondaryWeaponMagazine player)	: {_data set [5, getUnitLoadout player # 1 # 4]};
		case (_classname in handgunMagazine player)			: {_data set [5, getUnitLoadout player # 2 # 4]};
	};	
	private _dropCtrl = controlNull;
	private _mousePosition = getMousePosition + [0];
	// Если курсор находится на одном из списков
	[_display displayCtrl 100,_display displayCtrl 105] findIf {
		(ctrlPosition _x) params ["_posX", "_posY", "_posW", "_posH"];
		if (_mousePosition inPolygon [
			[_posX, _posY, 0],
			[_posX + _posW, _posY, 0],
			[_posX + _posW, _posY + _posH, 0],
			[_posX, _posY + _posH, 0]
		]) exitWith {_dropCtrl = _x};
	};
	if (!isNull _dropCtrl) then {
		private _toContainer = _dropCtrl getVariable ["containerObject", objNull];
		if (isNull _toContainer) exitWith {};
		if (_readonly AND !(_toContainer isEqualTo backpackContainer player)) exitWith {4 call client_inventory_message};
		if ((_config isEqualTo "CfgVehicles") AND (_toContainer isEqualTo backpackContainer player)) exitWith {}; // Stop self-anihilation.
		_display setVariable ["fromContainer",	player];
		_display setVariable ["toContainer",	_toContainer];
		_display setVariable ["toIDC",			ctrlIDC _dropCtrl];
		_data call client_inventory_moveItem;
	};
}];
// Фиксируем нажатия на клавиатуру
_display displayAddEventHandler ["KeyDown",{
	params ["_display", "_code", "_shift", "_ctrlKey", "_alt"];
	private _handled = false;
	
	if (inputAction "gear" > 0) then {
		[_display] spawn client_gui_unloadDisplay;
		_handled = true
	};
	if (inputAction "reloadMagazine" > 0) then {
		[_display] spawn client_gui_unloadDisplay;
		if (!isNull objectParent player) exitWith {};
		missionNamespace setVariable ["actionInProgress",true];
	};
	if (inputAction "throw" > 0) then {
		[_display] spawn client_gui_unloadDisplay;
		_handled = true
	};
	if (_code == 1) then {
		[_display] spawn client_gui_unloadDisplay;
		_handled = true
	};
	_display setVariable ["shiftKey", _shift];
	_display setVariable ["altKey", _alt];
	_handled
}];
// Фиксируем отжатие кнопки
_display displayAddEventHandler ["KeyUp", {
	private _display = _this # 0;
	_display setVariable ["shiftKey", false];
	_display setVariable ["altKey", false];
}];
// Проверяем на закрытие инвентаря
_display spawn {
	params ["_display"];
	private _currentPlayerPos = getPosATL player;
	private _container = _display getVariable ["container",objNull];
	private _readonly = _display getVariable ["readonly",false];
	private _usedBy = _container getVariable ["usedBy",objNull];


	waitUntil {uiSleep 0.1; (
		(isNull _display) OR
		{isNull _container} OR
		{player distance _container > 8} OR
		{isNull objectParent player AND {player distance _currentPlayerPos > 2}} OR
		{!alive player} OR 
		{!(_display getVariable ["readonly",false]) AND {(_container getVariable ["usedBy",objNull]) != player}}
	)};
	
	[_display] spawn client_gui_unloadDisplay;
};