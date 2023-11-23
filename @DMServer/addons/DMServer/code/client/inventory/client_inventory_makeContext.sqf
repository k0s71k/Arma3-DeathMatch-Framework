#define GUI_GRID_H (0.04)
#define GUI_GRID_W (0.025)

params ["_ctrlData", "_itemData"];
_ctrlData params ["_ctrl", "_ctrlClass"];
_itemdata params ["_data", "_fromContainer"];
if (isNil {_data}) exitWith {};
_data params [
	["_classname",""],
	"_displayname",
	"_config",
	"_mass",
	["_amount",1],
	"_itemdata"
];

private _txtSizeM		= 1.2;
private _hO				= 0;
private _textWidthMax	= 0;
private _allButtons		= [];
getMousePosition params ["_xPos", "_yPos"];
private _display		= ctrlParent _ctrl;
ctrlDelete (_display getVariable ["contextGroup",controlNull]);
//_ctrl ctrlEnable false;
_display setVariable		["fromContainer", _fromContainer];
private _currentContainer	= _display getVariable ["container", objNull];
private _containerList		= _display getVariable ["containerList", controlNull];
private _backList			= _display getVariable ["backList", controlNull];
private _itemType			= _classname call BIS_fnc_itemType;
_itemType params ["_category","_type"];

private _makeButton = {
	params ["_text", "_data", "_toContainer", ["_fromContainer", objNull], ["_toIDC", -1]];
	private _buttonSizeH	= 1.2 * GUI_GRID_H;
	private _ctrl = _display ctrlCreate ["RscStructuredText", -1, _contextGroup];
	_ctrl ctrlSetPosition [
		0, _hO, _gW, _buttonSizeH
	];
	_ctrl ctrlCommit 0;
	_ctrl ctrlSetStructuredText parseText format[" %1", _text];
	_ctrl ctrlSetBackgroundColor [0.1, 0.1, 0.1, 0.8];
	private _textWidthAprox = (ctrlTextWidth _ctrl) * 1.05;
	if (_textWidthAprox > _textWidthMax) then {_textWidthMax = _textWidthAprox};
	_ctrl ctrlEnable true;
	_ctrl setVariable ["data", _data];
	_ctrl setVariable ["toContainer", _toContainer];
	if !(isNull _fromContainer) then {_ctrl setVariable ["fromContainer", _fromContainer]};
	if !(_toIDC isEqualTo -1) then {_ctrl setVariable ["toIDC", _toIDC]};
	_allButtons pushBack _ctrl;
	_ctrl ctrlAddEventHandler ["MouseEnter",{
		params ["_ctrl"];
		_ctrl ctrlSetBackgroundColor [0.2, 0.2, 0.2, 0.85];
	}];
	_ctrl ctrlAddEventHandler ["MouseExit",{
		params ["_ctrl"];
		_ctrl ctrlSetBackgroundColor [0.1, 0.1, 0.1, 0.9];
	}];
	// Custom code button
	if (_data isEqualType {}) then {
		_ctrl ctrlAddEventHandler ["MouseButtonDown",{
			params ["_ctrl"];
			private _display	= ctrlParent _ctrl;
			private _data		= _ctrl getVariable ["data",{}];
			call _data;
			playSound "readoutClick";
			private _selectedControl = (ctrlParentControlsGroup _ctrl) getVariable ["selectedControl",controlNull];
			_selectedControl ctrlEnable true;
			(ctrlParentControlsGroup _ctrl) spawn {ctrlDelete _this};
		}];
	} else {
		_ctrl ctrlAddEventHandler ["MouseButtonDown", {
			params ["_ctrl"];
			private _display		= ctrlParent _ctrl;
			private _data			= _ctrl getVariable ["data", []];
			private _toContainer	= _ctrl getVariable ["toContainer", objNull];
			private _fromContainer	= _ctrl getVariable ["fromContainer", objNull];
			private _toIDC			= _ctrl getVariable ["toIDC", -1];
			if !(isNull _fromContainer) then {
				_display setVariable ["fromContainer", _fromContainer]
			};
			if !(_toIDC isEqualTo -1) then {
				_display setVariable ["toIDC", _toIDC]
			};
			_display setVariable ["toContainer", _toContainer];
			_data params ["_classname", "_displayname", "_config", "_mass", ["_amount", 1], "_itemdata"];

			[_classname, _displayname, _config, _mass, 1, _itemdata] call client_inventory_moveItem;

			playSound "readoutClick";
			private _selectedControl = (ctrlParentControlsGroup _ctrl) getVariable ["selectedControl",controlNull];
			_selectedControl ctrlEnable true;
			(ctrlParentControlsGroup _ctrl) spawn {ctrlDelete _this};
		}];
	};

	_hO = _hO + _buttonSizeH;
	_contextGroup ctrlSetPositionW (_gW max _textWidthMax);
	_contextGroup ctrlSetPositionH _hO;
	_contextGroup ctrlCommit 0;
};

private _contextGroup = _display ctrlCreate ["RscControlsGroupNoScrollbars", -1];
_contextGroup ctrlSetPosition [_xPos - 0.01, _yPos - 0.01, 10 * GUI_GRID_W, 4.5 * GUI_GRID_H];
_contextGroup ctrlSetFade 1;
_contextGroup ctrlCommit 0;
_contextGroup setVariable	["selectedControl", _ctrl];
_display setVariable		["contextGroup", _contextGroup];
(ctrlPosition _contextGroup) params ["_gX","_gY","_gW","_gH"];
_contextGroup ctrlAddEventHandler ["MouseMoving", {
	params ["_ctrl", "", "", "_mouseOver"];
	if !(_mouseOver) then {
		private _selectedControl = _ctrl getVariable ["selectedControl",controlNull];
		_selectedControl ctrlEnable true;
		_ctrl spawn {ctrlDelete _this};
	};	
}];

// Постоянно обновляем фокус на созданной группе
_contextGroup spawn {
	while {!isNull _this} do {
		ctrlSetFocus _this;
		uiSleep 0.01;
	};
};

// Create buttons
switch (true) do {
	// Player slots
	case (_fromContainer isEqualTo player): {
		// Slot is empty
		if (_classname isEqualTo "") then {
			private _slotType	= _ctrl getVariable ["slotType",""];
			private _slotGroup	= ctrlParentControlsGroup _ctrl;
			private _toIDC		= ctrlIDC _slotGroup;
			private _itemArray	= [_slotType] call client_inventory_findCompatibles;
			if (_itemArray isEqualTo []) exitWith {};
			{
				_x params ["_actionData", "_data", "_fromContainer"];
				_actionData params ["_text","_picture"];
				private _sourceText = if (_fromContainer isEqualTo (backpackContainer player)) then {"Рюкзак"} else {"Контейнер"};
				[format["<img image='%1' size='%3'></img> %2  <t align='right' size='%5'>%4</t>", _picture, _text, _txtSizeM, _sourceText, _txtSizeM * 0.6], _data,player, _fromContainer, _toIDC] call _makeButton;
			} forEach _itemArray;
		} else {
			// Set specific data for subtractor 
			switch (true) do {
				case (_classname isEqualTo primaryWeapon player)	: {_data set [5,getUnitLoadout player select 0]};
				case (_classname isEqualTo secondaryWeapon player)	: {_data set [5,getUnitLoadout player select 1]};
				case (_classname isEqualTo handgunWeapon player)	: {_data set [5,getUnitLoadout player select 2]};
				case (_classname isEqualTo binocular player)		: {_data set [5,getUnitLoadout player select 8]};
				case (_classname in primaryWeaponMagazine player)	: {
					private _MagContainer	= getUnitLoadout player select 0 select 4;
					private _GLContainer	= getUnitLoadout player select 0 select 5;
					private _magazineData = switch (true) do {
						case (_classname in _MagContainer)	: {_MagContainer};
						case (_classname in _GLContainer)	: {_GLContainer};
					};
					_data set [5, _magazineData];
				};					
				case (_classname in secondaryWeaponMagazine player)	: {_data set [5,getUnitLoadout player select 1 select 4]};
				case (_classname in handgunMagazine player)			: {_data set [5,getUnitLoadout player select 2 select 4]};
			};				
			if !(isNull backpackContainer player) then {
				if (_classname isEqualTo backpack player) exitWith {
					private _data = +_data;
					_data set [5,false];
					[format["<img image='\A3\Ui_f\data\igui\cfg\simpletasks\types\box_ca.paa' size='%1'></img> Разгрузить в контейнер", _txtSizeM], _data, _currentContainer] call _makeButton
				};
				[format["<img image='\A3\Ui_f\data\map\vehicleicons\iconbackpack_ca.paa' size='%1'></img> В рюкзак", _txtSizeM], _data,backpackContainer player] call _makeButton;
			};
			[format["<img image='\A3\Ui_f\data\igui\cfg\simpletasks\types\box_ca.paa' size='%1'></img> В контейнер", _txtSizeM], _data, _currentContainer] call _makeButton;
		};
	};
	// Container context
	case (_fromContainer isEqualTo _currentContainer): {
		switch (true) do {
			case (_category isEqualTo "Weapon"): {
				// Equip weapons
				if (_type in ["AssaultRifle","MachineGun","Shotgun","Rifle","SubmachineGun","SniperRifle"]) then {
					private _picture = getText (configFile >> _config >> _classname >> "picture");
					[format["<img image='%1' size='%3'></img> Взять %2", _picture, _displayname, _txtSizeM], _data, player, _fromContainer, 102] call _makeButton;
				};							
				if (_type in ["BombLauncher","Cannon","GrenadeLauncher","MissileLauncher","RocketLauncher","Throw"]) then {
					private _picture = getText (configFile >> _config >> _classname >> "picture");
					[format["<img image='%1' size='%3'></img> Взять %2", _picture, _displayname, _txtSizeM], _data, player, _fromContainer, 103] call _makeButton;
				};					
				if (_type in ["Handgun"]) then {
					private _picture = getText (configFile >> _config >> _classname >> "picture");
					[format["<img image='%1' size='%3'></img> Взять %2", _picture, _displayname, _txtSizeM], _data, player, _fromContainer, 104] call _makeButton;
				};
				// Disassemble weapon
				if !(_itemdata isEqualTo [_classname,"","","",[],[],""]) then {
					private _data = {
						private _containerList		= _display getVariable ["containerList",controlNull];
						private _data				= _containerList lbData (lbCurSel _containerList);
						private _toContainer		= _ctrl getVariable ["toContainer",objNull];
						private _readonly			= _display getVariable ["readonly",false];
						private _remoteContainer	= _display getVariable ["container",objNull];
						if (_readonly AND _remoteContainer isEqualTo _toContainer) exitWith {4 call client_inventory_message};
						_data						= call compile _data;
						_data params ["","","","","","_itemdata"];
						_itemdata params ["_weapon","_muzzle","_laser","_optics","_magazine","_magazineGL","_bipod"];
						private _weaponCargo = weaponsItemsCargo _toContainer;
						private _index = _weaponCargo findIf {_itemdata isEqualTo _x};
						_weaponCargo deleteAt _index;
						clearWeaponCargoGlobal _toContainer;
						{_toContainer addWeaponWithAttachmentsCargoGlobal [_x,1]} forEach _weaponCargo;
						_toContainer addWeaponWithAttachmentsCargoGlobal [[_weapon call BIS_fnc_baseWeapon,"","","",[],[],""],1];
						{_toContainer addItemCargoGlobal [_x,1]} forEach [_muzzle, _laser, _optics, _bipod];
						{
							_x params [["_magazine",""],["_ammocount",0]];
							if !(_magazine isEqualTo "") then {_toContainer addMagazineAmmoCargo [_magazine,1, _ammocount]};
						} forEach [_magazine, _magazineGL];
						[_toContainer, _containerList] call client_inventory_updateContainerList;
					};
					[format["<img image='\A3\Ui_f\data\IGUI\Cfg\simpleTasks\types\use_ca.paa' size='%1'></img> Разобрать оружие", _txtSizeM], _data, _fromContainer] call _makeButton;
				};
			};
			case (_category in ["Item", "Equipment"]): {
				// Equip slots
				if (_type in ["AccessoryMuzzle","AccessoryPointer","AccessorySights","AccessoryBipod"]) then {
					private _primaryCompatibles = ((primaryWeapon player) call BIS_fnc_compatibleItems) apply {toLower _x};
					private _secondaryCompatibles = ((secondaryWeapon player) call BIS_fnc_compatibleItems) apply {toLower _x};
					private _handgunCompatibles = ((handgunWeapon player) call BIS_fnc_compatibleItems) apply {toLower _x};
					switch (true) do {
						case (toLower _classname in _primaryCompatibles): {
							private _picture = getText (configFile >> _config >> _classname >> "picture");
							[format["<img image='%1' size='%3'></img> Установить %2", _picture, _displayname, _txtSizeM], _data, player, _fromContainer, 102] call _makeButton;	
						};
						case (toLower _classname in _secondaryCompatibles): {
							private _picture = getText (configFile >> _config >> _classname >> "picture");
							[format["<img image='%1' size='%3'></img> Установить %2", _picture, _displayname, _txtSizeM], _data,player, _fromContainer, 103] call _makeButton;
						};
						case (toLower _classname in _handgunCompatibles): {
							private _picture = getText (configFile >> _config >> _classname >> "picture");
							[format["<img image='%1' size='%3'></img> Установить %2", _picture, _displayname, _txtSizeM], _data,player, _fromContainer, 104] call _makeButton;
						};
					};
				} else {
					if (_type in ["FirstAidKit","UAVTerminal","Toolkit","Medikit"]) exitWith {};
					private _picture = getText (configFile >> _config >> _classname >> "picture");
					[format["<img image='%1' size='%3'></img> Надеть %2", _picture, _displayname, _txtSizeM], _data, player, _fromContainer, 101] call _makeButton;	
				};
			};
			// Equip magazines
			case (_category in ["Magazine"]): {
				private _hasCompatibles = false;
				private _findCompatibleMagazines = {
					params ["_weaponClass"];
					private _compatibles = getArray (configFile >> "CfgWeapons" >> _weaponClass >> "magazines");
					private _muzzles = (getArray (configFile >> "CfgWeapons" >> _weaponClass >> "muzzles")) - ["this"];
					{_compatibles append (getArray (configFile >> "CfgWeapons" >> _weaponClass >> _x >> "magazines"))} forEach _muzzles;
					_compatibles apply {toLower _x};
				};
				if (primaryWeapon player != "") then {
					private _compatibles = [primaryWeapon player] call _findCompatibleMagazines;
					if (toLower _classname in _compatibles) then {
						private _picture = getText (configFile >> _config >> _classname >> "picture");
						[format["<img image='%1' size='%3'></img> Зарядить %2", _picture, _displayname, _txtSizeM], _data, player, _fromContainer, 102] call _makeButton;
						_hasCompatibles = true;
					};
				};					
				if (secondaryWeapon player != "") then {
					private _compatibles = [secondaryWeapon player] call _findCompatibleMagazines;
					if (toLower _classname in _compatibles) then {
						private _picture = getText (configFile >> _config >> _classname >> "picture");
						[format["<img image='%1' size='%3'></img> Зарядить %2", _picture, _displayname, _txtSizeM], _data, player, _fromContainer, 103] call _makeButton;
						_hasCompatibles = true;
					};
				};					
				if (handgunWeapon player != "") then {
					private _compatibles = [handgunWeapon player] call _findCompatibleMagazines;
					if (toLower _classname in _compatibles) then {
						private _picture = getText (configFile >> _config >> _classname >> "picture");
						[format["<img image='%1' size='%3'></img> Зарядить %2", _picture, _displayname, _txtSizeM], _data, player, _fromContainer, 104] call _makeButton;
						_hasCompatibles = true;
					};
				};
			};
			default {};
		};
	};
	// Backpack context		
	case (_fromContainer isEqualTo (backpackContainer player)): {
		switch (true) do {
			case (_category isEqualTo "Weapon"): {
				// Equip 
				if (_type in ["AssaultRifle","MachineGun","Shotgun","Rifle","SubmachineGun","SniperRifle"]) then {
					private _picture = getText (configFile >> _config >> _classname >> "picture");
					[format["<img image='%1' size='%3'></img> Взять %2", _picture, _displayname, _txtSizeM], _data,player, _fromContainer,102] call _makeButton;
				};							
				if (_type in ["BombLauncher","Cannon","GrenadeLauncher","MissileLauncher","RocketLauncher","Throw"]) then {
					private _picture = getText (configFile >> _config >> _classname >> "picture");
					[format["<img image='%1' size='%3'></img> Взять %2", _picture, _displayname, _txtSizeM], _data,player, _fromContainer,103] call _makeButton;
				};					
				if (_type in ["Handgun"]) then {
					private _picture = getText (configFile >> _config >> _classname >> "picture");
					[format["<img image='%1' size='%3'></img> Взять %2", _picture, _displayname, _txtSizeM], _data,player, _fromContainer,104] call _makeButton;
				};	
				// Disassemble weapon
				if !(_itemdata isEqualTo [_classname,"","","",[],[],""]) then {
					private _data = {
						private _backList		= _display getVariable ["backList", controlNull];
						private _data			= _backList lbData (lbCurSel _backList);
						private _toContainer	= _ctrl getVariable ["toContainer", objNull];
						_data					= call compile _data;
						_data params ["", "", "", "", "", "_itemdata"];
						_itemdata params ["_weapon", "_muzzle", "_laser", "_optics", "_magazine", "_magazineGL", "_bipod"];
						private _weaponCargo	= weaponsItemsCargo _toContainer;
						private _index			= _weaponCargo findIf {_itemdata isEqualTo _x};
						_weaponCargo deleteAt _index;
						clearWeaponCargoGlobal _toContainer;
						{_toContainer addWeaponWithAttachmentsCargoGlobal [_x, 1]} forEach _weaponCargo;
						_toContainer addWeaponWithAttachmentsCargoGlobal [[_weapon call BIS_fnc_baseWeapon, "", "", "", [], [], ""], 1];
						{_toContainer addItemCargoGlobal [_x,1]} forEach [_muzzle, _laser, _optics, _bipod];
						{
							_x params [["_magazine", ""], ["_ammocount", 0]];
							if !(_magazine isEqualTo "") then {_toContainer addMagazineAmmoCargo [_magazine, 1, _ammocount]};
						} forEach [_magazine, _magazineGL];
						[_toContainer, _backList] call client_inventory_updateContainerList;
					};
					[format["<img image='\A3\Ui_f\data\IGUI\Cfg\simpleTasks\types\use_ca.paa' size='%1'></img> Разобрать оружие", _txtSizeM], _data,backpackContainer player] call _makeButton;
				};
			};
			case (_category in ["Item", "Equipment"]): {
				// TODO : Добавить кастомные действия для лайва
				// Equip slots
				if (_type in ["AccessoryMuzzle", "AccessoryPointer", "AccessorySights", "AccessoryBipod"]) then {
					private _primaryCompatibles		= ((primaryWeapon player) call BIS_fnc_compatibleItems) apply {toLower _x};
					private _secondaryCompatibles	= ((secondaryWeapon player) call BIS_fnc_compatibleItems) apply {toLower _x};
					private _handgunCompatibles		= ((handgunWeapon player) call BIS_fnc_compatibleItems) apply {toLower _x};
					switch (true) do {
						case (toLower _classname in _primaryCompatibles): {
							private _picture = getText (configFile >> _config >> _classname >> "picture");
							[format["<img image='%1' size='%3'></img> Установить %2", _picture, _displayname, _txtSizeM], _data,player, _fromContainer,102] call _makeButton;	
						};
						case (toLower _classname in _secondaryCompatibles): {
							private _picture = getText (configFile >> _config >> _classname >> "picture");
							[format["<img image='%1' size='%3'></img> Установить %2", _picture, _displayname, _txtSizeM], _data,player, _fromContainer,103] call _makeButton;
						};
						case (toLower _classname in _handgunCompatibles): {
							private _picture = getText (configFile >> _config >> _classname >> "picture");
							[format["<img image='%1' size='%3'></img> Установить %2", _picture, _displayname, _txtSizeM], _data,player, _fromContainer,104] call _makeButton;
						};
					};
				} else {
					if (_type in ["FirstAidKit","UAVTerminal","Toolkit","Medikit"]) exitWith {};
					private _picture = getText (configFile >> _config >> _classname >> "picture");
					[format["<img image='%1' size='%3'></img> Надеть %2", _picture, _displayname, _txtSizeM], _data, player, _fromContainer, 101] call _makeButton;	
				};
			};
			// Equip magazines
			case (_category in ["Magazine"]): {
				private _hasCompatibles = false;
				private _findCompatibleMagazines = {
					params ["_weaponClass"];
					private _compatibles = getArray (configFile >> "CfgWeapons" >> _weaponClass >> "magazines");
					private _muzzles = (getArray (configFile >> "CfgWeapons" >> _weaponClass >> "muzzles")) - ["this"];
					{_compatibles append (getArray (configFile >> "CfgWeapons" >> _weaponClass >> _x >> "magazines"))} forEach _muzzles;
					_compatibles apply {toLower _x};
				};
				if (primaryWeapon player != "") then {
					private _compatibles = [primaryWeapon player] call _findCompatibleMagazines;
					if (toLower _classname in _compatibles) then {
						private _picture = getText (configFile >> _config >> _classname >> "picture");
						private _weaponName = getText (configFile >> "CfgWeapons" >> primaryWeapon player >> "displayName");
						[format["<img image='%1' size='%3'></img> Зарядить %2", _picture, _displayname, _txtSizeM], _data, player, _fromContainer, 102] call _makeButton;
						_hasCompatibles = true;
					};
				};
				if (secondaryWeapon player != "") then {
					private _compatibles = [secondaryWeapon player] call _findCompatibleMagazines;
					if (toLower _classname in _compatibles) then {
						private _picture = getText (configFile >> _config >> _classname >> "picture");
						private _weaponName = getText (configFile >> "CfgWeapons" >> secondaryWeapon player >> "displayName");
						[format["<img image='%1' size='%3'></img> Зарядить %2", _picture, _displayname, _txtSizeM], _data, player, _fromContainer, 103] call _makeButton;
						_hasCompatibles = true;
					};
				};
				if (handgunWeapon player != "") then {
					private _compatibles = [handgunWeapon player] call _findCompatibleMagazines;
					if (toLower _classname in _compatibles) then {
						private _picture = getText (configFile >> _config >> _classname >> "picture");
						private _weaponName = getText (configFile >> "CfgWeapons" >> handgunWeapon player >> "displayName");
						[format["<img image='%1' size='%3'></img> Зарядить %2", _picture, _displayname, _txtSizeM], _data, player, _fromContainer, 104] call _makeButton;
						_hasCompatibles = true;
					};
				};
			};				
			default {};
		};
	};
};
if (_allButtons isEqualTo []) exitWith {
	ctrlDelete _contextGroup
};

// Устанавливаем ширину кнопок
{
	_x ctrlSetPositionW (((ctrlPosition _x) # 2) max _textWidthMax);
	_x ctrlCommit 0;
} forEach _allButtons;

_contextGroup ctrlSetFade 0;
_contextGroup ctrlCommit 0.1;