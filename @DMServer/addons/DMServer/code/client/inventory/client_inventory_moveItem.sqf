params [
	"_classname",
	"_displayname",
	"_config",
	"_mass",
	["_amount",1],
	"_data"
];

private _display		= uiNamespace getVariable ["InventoryDisplay",displayNull];
private _fromContainer	= _display getVariable ["fromContainer",objNull];
private _toContainer	= _display getVariable ["toContainer",objNull];
if (isNull _toContainer) exitWith {};
if (_fromContainer isEqualTo _toContainer) exitWith {};
// Вдруг нам нельзя этого делать
if !(call client_inventory_canOperate) exitWith {};
private _backList		= _display getVariable ["backList",controlNull];
private _containerList	= _display getVariable ["containerList",controlNull];	
private _types			= _classname call BIS_fnc_itemType;
_types params ["_category","_type"];

// Считаем массу перемещаемых предметов (для оружий считаем обвесы)
private _toContainerWeight		= _toContainer getVariable ["currentWeight",0];
private _toContainerWeightMax	= _toContainer getVariable ["maximumWeight",0];
private _movedItemMass			= _amount * _mass;
if ((_fromContainer isEqualTo player) AND (_category isEqualTo "Weapon")) then {
	_data params ["","_muzzle","_pointer","_optics","_magArray","_secMagArray","_bipod"];
	_magArray params [["_mag",""]];
	_secMagArray params [["_secMag",""]];
	private _weaponMassAttachments = 0;
	{
		private _mass = if (isClass (configFile >> "CfgWeapons" >> _x >> "WeaponSlotsInfo")) then {
			getNumber (configFile >> "CfgWeapons" >> _x >> "WeaponSlotsInfo" >> "mass")
		} else {
			getNumber (configFile >> "CfgWeapons" >> _x >> "ItemInfo" >> "mass")
		};
		_weaponMassAttachments = _weaponMassAttachments + _mass;
	} forEach [_muzzle,_pointer,_optics,_bipod];
	{_weaponMassAttachments = _weaponMassAttachments +  (getNumber (configFile >> "CfgMagazines" >> _x >> "mass"))} forEach [_mag,_secMag]; 
	_movedItemMass = _movedItemMass + _weaponMassAttachments;
};	

// Удаляем вещь из контейнера
private _subtractThisContainer = {
	params ["_container"];
	// wrap for setUnitLoadout shifting backpacks.
	if (_container isKindOf "Bag_Base" AND !(_container isEqualTo backpackContainer player)) then {_container = backpackContainer player};
	switch (true) do {
		case ((_category in ["Weapon"]) OR (_type in ["Binocular","LaserDesignator"])): {
			private _weaponCargo	= weaponsItemsCargo _container;
			private _index			= _weaponCargo findIf {_data isEqualTo _x};
			_weaponCargo deleteAt _index;
			clearWeaponCargoGlobal _container;
			{_container addWeaponWithAttachmentsCargoGlobal [_x,1]} forEach _weaponCargo;
		};			
		case ((_category in ["Item"]) OR (_type in ["Glasses","Vest","Uniform","Headgear"])): {
			private _itemCargo		= getItemCargo _container;
			_itemCargo params ["_itemArray","_itemCountArray"];
			private _index			= _itemArray findIf {_classname isEqualTo _x};
			_itemCountArray set [_index,((_itemCountArray select _index) - _amount) max 0];
			clearItemCargoGlobal _container;
			{_container addItemCargoGlobal [_x,_itemCountArray select _forEachIndex]} forEach _itemArray;
		};			
		case (_category in ["Magazine","Mine"]): {
			private _magazinesAmmoCargo = magazinesAmmoCargo _container;
			clearMagazineCargoGlobal _container;
			private _magazinesCargo = [];
			{
				private _thisItem	= _x;
				private _index		= _magazinesCargo findIf {_x isEqualTo _thisItem};
				if (_index isEqualTo -1) then {
					_magazinesCargo pushBack _thisItem;
					_magazinesCargo pushBack 1;
				} else {
					private _amount	= _magazinesCargo select (_index + 1);
					_magazinesCargo set [_index + 1,_amount + 1];
				};
			} forEach _magazinesAmmoCargo;
			private _index			= _magazinesCargo findIf {_data isEqualTo _x};
			private _currentAmount	= _magazinesCargo select (_index + 1);
			_magazinesCargo set [_index + 1,(_currentAmount - _amount) max 0];
			{
				if (_forEachIndex % 2 == 1) then {continue}; // Костыль
				_x params ["_class", "_ammocount"];
				private _count		= _magazinesCargo select (_forEachIndex + 1);
				//hint str[_magazinesCargo, _class, _count, _ammocount];
				_container addMagazineAmmoCargo [_class, _count, _ammocount];
			} forEach _magazinesCargo;
		};
		case (_type in ["Backpack"]): {
			private _backpackCargo	= getBackpackCargo _container;
			_backpackCargo params ["_bpArray","_bpCountArray"];
			private _index			= _bpArray findIf {_classname isEqualTo _x};
			_bpCountArray set [_index,((_bpCountArray select _index) - _amount) max 0];
			clearBackpackCargoGlobal _container;
			{_container addBackpackCargoGlobal [_x,_bpCountArray select _forEachIndex]} forEach _bpArray;
		};
	};
	private _containerList = switch (true) do {
		case (_container isEqualTo (backpackContainer player)): {
			[backpackContainer player,_backList] call client_inventory_updateContainerList;
		};
		default {
			[_container,_containerList] call client_inventory_updateContainerList;
		};	
	};
};

// Добавляем в контейнер
private _addThisContainer = {
	params ["_container"];
	// wrap for setUnitLoadout shifting backpacks.
	if (_container isKindOf "Bag_Base" AND !(_container isEqualTo backpackContainer player)) then {_container = backpackContainer player};
	switch (true) do {
		case (_category in ["Weapon"]): {
			_container addWeaponWithAttachmentsCargoGlobal [_data,_amount]
		};			
		case ((_category in ["Item"]) OR (_type in ["Glasses","Vest","Uniform","Headgear"])): {
			_container addItemCargoGlobal [_classname,_amount]
		};			
		case (_category in ["Magazine","Mine"]): {
			if ((_data select 1) == 0) exitWith {};
			_container addMagazineAmmoCargo [_classname,_amount,_data select 1]
		};
		case (_type in ["Backpack"]): {
			_container addBackpackCargoGlobal [_classname call BIS_fnc_basicBackpack,_amount]
		};
	};

	private _containerList = switch (true) do {
		case (_container isEqualTo (backpackContainer player)): {
			[backpackContainer player, _backList] call client_inventory_updateContainerList;
		};
		default {
			[_container,_containerList] call client_inventory_updateContainerList;
		};	
	};			
};

// Удаляем из снаряжения
private _subtractThisLoadout = {
	params ["_container"];
	private _itemTypes = _classname call BIS_fnc_itemType;
	_itemTypes params ["_category","_type"];
	private _return = switch (true) do {
		case (_type isEqualTo "Uniform")	: {removeUniform player};
		case (_type isEqualTo "Vest")		: {removeVest player};
		case (_type isEqualTo "Backpack")	: {
			private _currentContainer = _display getVariable ["container",objNull];
			if ([_currentContainer] call client_inventory_unloadBackpack) exitWith {
				removeBackpack player;
				if !(_data isEqualTo false) exitWith {
					[backpackContainer player, _backList] call client_inventory_updateContainerList;
					true
				};
				player addBackpack (_classname call BIS_fnc_basicBackpack);
				[backpackContainer player, _backList] call client_inventory_updateContainerList;
				[_currentContainer, _containerList] call client_inventory_updateContainerList;
				false
			};
			false
		};
		case (_type in ["Binocular","LaserDesignator"])		: {player removeWeapon _classname};
		case (_classname in primaryWeaponItems player)		: {player removePrimaryWeaponItem _classname};
		case (_classname in secondaryWeaponItems player)	: {player removeSecondaryWeaponItem _classname};
		case (_classname in handgunItems player)			: {player removeHandgunItem _classname};
		case (_classname in [primaryWeapon player,secondaryWeapon player,handgunWeapon player]): {player removeWeapon _classname};			
		case (_classname in primaryWeaponMagazine player)	: {player removePrimaryWeaponItem _classname};
		case (_classname in secondaryWeaponMagazine player)	: {player removeSecondaryWeaponItem _classname};
		case (_classname in handgunMagazine player)			: {player removeHandgunItem _classname};	
		case (_category in ["Item","Equipment"])			: {player unlinkItem _classname};
	};
	_return
};

// Добавляем в снаряжение
private _addThisLoadout = {
	private _groupIDC =_display getVariable ["toIDC",-1];
	if (_groupIDC isEqualTo -1) exitWith {-1};
	private _loadout = getUnitLoadout player;
	private _destination = switch (_groupIDC) do {
		case 106; case 101	: {"Gear"};
		case 102			: {"Primary"};
		case 103			: {"Secondary"};
		case 104			: {"Handgun"};
		default				{""}
	};
	if (_destination isEqualTo "") exitWith {-1};

	private _swapGear = {
		params ["_currentArray","_newArray","_container"];
		_currentArray	params ["_currentClass","_currentConfig"];
		_newArray		params ["_newClass","_newConfig","_newMass","_newWeaponData"];
		private _currentMass = switch (true) do {
			case (_currentClass isEqualTo "")				: {0};
			case (_currentConfig isEqualTo "CfgVehicles")	: {0};
			case (isClass (configFile >> _currentConfig >> _currentClass >> "WeaponSlotsInfo")): {
				getNumber (configFile >> _currentConfig >> _currentClass >> "WeaponSlotsInfo" >> "mass")
			};
			case (_currentConfig isEqualTo "CfgGlasses")	: {
				getNumber (configFile >> _currentConfig >> _currentClass  >> "mass")
			};
			default {
				getNumber (configFile >> _currentConfig >>_currentClass >> "ItemInfo" >> "mass")
			};
		};
		private _fromContainerWeight		= _container getVariable ["currentWeight", 0];
		private _fromContainerWeightMax 	= _container getVariable ["maximumWeight", 0];
		if (((_currentMass - _newMass + _fromContainerWeight) > _fromContainerWeightMax) AND !(_currentClass isEqualTo "")) exitWith {1};
		private _return = if (_destination isEqualTo "Gear") then {
			switch (_type) do {
				case "Uniform": {
					player unlinkItem _currentClass;
					player forceAddUniform _newClass;
					private _classname = _currentClass;
					[_container] call _addThisContainer;						
					true
				};					
				case "Vest": {
					player unlinkItem _currentClass;
					player addVest _newClass;
					private _classname = _currentClass;
					[_container] call _addThisContainer;							
					true
				};					
				case "Backpack": {
					private _canSwap = [_newClass call BIS_fnc_basicBackpack] call client_inventory_swapBackpack;
					if (_canSwap isEqualType 0) exitWith {_canSwap};
					if (_canSwap isEqualTo true) then {
						private _classname = _currentClass;
						[_container] call _addThisContainer;	
					};
					true
				};
				case "Binocular": {
					private _loadout = getUnitLoadout player;
					_loadout set [8,[_newClass, "", "", "", [], [], ""]];
					player setUnitLoadout _loadout;
					private _classname = _currentClass;
					[_container] call _addThisContainer;						
					true						
				};					
				case "LaserDesignator": {
					private _loadout = getUnitLoadout player;
					_loadout set [8,[_newClass, "", "", "", [], [], ""]];
					player setUnitLoadout _loadout;
					private _classname = _currentClass;
					[_container] call _addThisContainer;						
					true						
				};
				default {
					player linkItem _newClass;
					private _classname = _currentClass;
					[_container] call _addThisContainer;
					true
				};
			};
		} else {
			private _return = switch (true) do {
				case (_category isEqualTo "Weapon"): {
					_loadout set [_loadoutIndex,_newWeaponData];
					player setUnitLoadout _loadout;
					if !(_currentWeaponData isEqualTo []) then {
						private _data = _currentWeaponData;
						[_container] call _addThisContainer;
					};						
					true
				};
				case (_type in ["AccessoryMuzzle"]): {
					if (_weaponClassCurrent isEqualTo "") exitWith {0};
					private _compatibles = _weaponClassCurrent call BIS_fnc_compatibleItems;
					if !(toLower _newClass in (_compatibles apply {toLower _x})) exitWith {0};
					_currentWeaponData set [1,_newClass];
					player setUnitLoadout _loadout;
					if !(_muzzleCurrent isEqualTo "") then {
						private _classname = _muzzleCurrent;
						[_container] call _addThisContainer;
					};						
					true
				};
				case (_type in ["AccessoryPointer"]): {
					if (_weaponClassCurrent isEqualTo "") exitWith {0};
					private _compatibles = _weaponClassCurrent call BIS_fnc_compatibleItems;
					if !(toLower _newClass in (_compatibles apply {toLower _x})) exitWith {0};
					_currentWeaponData set [2,_newClass];
					player setUnitLoadout _loadout;
					if !(_pointerCurrent isEqualTo "") then {
						private _classname = _pointerCurrent;
						[_container] call _addThisContainer;
					};						
					true													
				};
				case (_type in ["AccessorySights"]): {
					if (_weaponClassCurrent isEqualTo "") exitWith {0};
					private _compatibles = _weaponClassCurrent call BIS_fnc_compatibleItems;
					diag_log str [_newClass,_compatibles,_newClass in _compatibles];
					if !(toLower _newClass in (_compatibles apply {toLower _x})) exitWith {0};
					_currentWeaponData set [3,_newClass];
					player setUnitLoadout _loadout;
					if !(_opticsCurrent isEqualTo "") then {
						private _classname = _opticsCurrent;
						[_container] call _addThisContainer;
					};						
					true							
				};
				case (_type in ["AccessoryBipod"]): {
					if (_weaponClassCurrent isEqualTo "") exitWith {0};
					private _compatibles = _weaponClassCurrent call BIS_fnc_compatibleItems;
					if !(toLower _newClass in (_compatibles apply {toLower _x})) exitWith {0};
					_currentWeaponData set [6,_newClass];
					player setUnitLoadout _loadout;
					if !(_bipodCurrent isEqualTo "") then {
						private _classname = _bipodCurrent;
						[_container] call _addThisContainer;
					};						
					true													
				};					
				case (_category isEqualTo "Magazine"): {
					if (_weaponClassCurrent isEqualTo "") exitWith {0};
					private _compatibles = getArray (configFile >> "CfgWeapons" >> _weaponClassCurrent >> "magazines");
					private _muzzles = (getArray (configFile >> "CfgWeapons" >> _weaponClassCurrent >> "muzzles")) - ["this"];
					{_compatibles append (getArray (configFile >> "CfgWeapons" >> _weaponClassCurrent >> _x >> "magazines"))} forEach _muzzles;
					if !(toLower _newClass in (_compatibles apply {toLower _x})) exitWith {0};

					switch (true) do {				
						case (_type in ["Shell","SmokeShell"]): {
							private _secMagArrayCurrentSaved = +_secMagArrayCurrent;
							_secMagArrayCurrent set [0,_data select 0];
							_secMagArrayCurrent set [1,_data select 1];
							player setUnitLoadout _loadout;	

							_secMagArrayCurrentSaved params [["_classname",""],"_count"];							
							if (_classname != "" AND _count != 0) then {
								private _data = _secMagArrayCurrentSaved;
								private _amount = 1;
								[_container] call _addThisContainer;
							};
						};
						default {
							private _magArrayCurrentSaved = +_magArrayCurrent;
							_magArrayCurrent set [0,_data select 0];
							_magArrayCurrent set [1,_data select 1];
							player setUnitLoadout _loadout;	

							_magArrayCurrentSaved params [["_classname",""],"_count"];							
							if (_classname != "" AND _count != 0) then {
								private _data = _magArrayCurrentSaved;
								private _amount = 1;
								[_container] call _addThisContainer;
							};							
						};
					};
					true							
				};
				default {0}
			};
			_return
		};
		_return
	};
	private _return = switch (_destination)	do {
		case "Gear": {
			if !(_type in ["Headgear","Glasses","Uniform","Vest","Backpack","NVGoggles","Binocular","Watch","Compass","GPS","Map","Radio","LaserDesignator"]) exitWith {0};
			(_loadout select 9) params ["_mapSlot","_gpsSlot","_radioSlot","_compassSlot","_watchSlot","_nvgSlot"];

			private _return = switch (_type) do {
				case "Headgear"		: {[[headgear player,"CfgWeapons"],[_classname,_config,_mass],_fromContainer] call _swapGear}; 
				case "Glasses"		: {[[goggles player,"CfgGlasses"],[_classname,_config,_mass],_fromContainer] call _swapGear}; 
				case "Uniform"		: {[[uniform player,"CfgWeapons"],[_classname,_config,_mass],_fromContainer] call _swapGear}; 
				case "Vest"			: {[[vest player,"CfgWeapons"],[_classname,_config,_mass],_fromContainer] call _swapGear}; 
				case "Backpack"		: {[[backpack player,"CfgVehicles"],[_classname,_config,_mass],_fromContainer] call _swapGear}; 
				case "NVGoggles"	: {[[hmd player,"CfgWeapons"],[_classname,_config,_mass],_fromContainer] call _swapGear}; 
				case "Binocular"	: {[[binocular player,"CfgWeapons"],[_classname,_config,_mass],_fromContainer] call _swapGear}; 
				case "LaserDesignator": {[[binocular player,"CfgWeapons"],[_classname,_config,_mass],_fromContainer] call _swapGear}; 
				case "Watch"		: {[[_watchSlot,"CfgWeapons"],[_classname,_config,_mass],_fromContainer] call _swapGear}; 
				case "Compass"		: {[[_compassSlot,"CfgWeapons"],[_classname,_config,_mass],_fromContainer] call _swapGear}; 
				case "GPS"			: {[[_gpsSlot,"CfgWeapons"],[_classname,_config,_mass],_fromContainer] call _swapGear}; 
				case "Map"			: {[[_mapSlot,"CfgWeapons"],[_classname,_config,_mass],_fromContainer] call _swapGear}; 
				case "Radio"		: {[[_radioSlot,"CfgWeapons"],[_classname,_config,_mass],_fromContainer] call _swapGear}; 
				default {0};
			};
			_return
		};
		case "Primary": {
			private _loadoutIndex = 0;
			private _currentWeaponData = _loadout select _loadoutIndex;
			_currentWeaponData params [["_weaponClassCurrent",""],["_muzzleCurrent",""],["_pointerCurrent",""],["_opticsCurrent",""],["_magArrayCurrent",[""]],["_secMagArrayCurrent",[""]],["_bipodCurrent",""]];
			private _return = switch (true) do {
				case (_type in ["AssaultRifle","MachineGun","Shotgun","Rifle","SubmachineGun","SniperRifle"]): {[[primaryWeapon player,"CfgWeapons"],[_classname,_config,_mass,_data],_fromContainer] call _swapGear};
				case (_type in ["AccessoryMuzzle"])	: {[[_muzzleCurrent,"CfgWeapons"],[_classname,_config,_mass],_fromContainer] call _swapGear};
				case (_type in ["AccessoryPointer"]): {[[_pointerCurrent,"CfgWeapons"],[_classname,_config,_mass],_fromContainer] call _swapGear};
				case (_type in ["AccessorySights"])	: {[[_opticsCurrent,"CfgWeapons"],[_classname,_config,_mass],_fromContainer] call _swapGear};
				case (_type in ["AccessoryBipod"])	: {[[_bipodCurrent,"CfgWeapons"],[_classname,_config,_mass],_fromContainer] call _swapGear};
				case (_category in ["Magazine"])	: {
					private _selected = if (_type in ["Shell","SmokeShell"]) then {_secMagArrayCurrent select 0} else {_magArrayCurrent select 0};
					[[_selected,"CfgMagazines"],[_classname,_config,_mass,_data],_fromContainer] call _swapGear
				};
				default {0}
			};
			_return
		};
		case "Secondary": {
			private _loadoutIndex = 1;
			private _currentWeaponData = _loadout select _loadoutIndex;
			_currentWeaponData params [["_weaponClassCurrent",""],["_muzzleCurrent",""],["_pointerCurrent",""],["_opticsCurrent",""],["_magArrayCurrent",[""]],["_secMagArrayCurrent",[""]],["_bipodCurrent",""]];			
			private _return = switch (true) do {
				case (_type in ["BombLauncher","Cannon","GrenadeLauncher","MissileLauncher","RocketLauncher","Throw"]): {[[secondaryWeapon player,"CfgWeapons"],[_classname,_config,_mass,_data],_fromContainer] call _swapGear};
				case (_type in ["AccessoryMuzzle"])	: {[[_muzzleCurrent,"CfgWeapons"],[_classname,_config,_mass],_fromContainer] call _swapGear};
				case (_type in ["AccessoryPointer"]): {[[_pointerCurrent,"CfgWeapons"],[_classname,_config,_mass],_fromContainer] call _swapGear};
				case (_type in ["AccessorySights"])	: {[[_opticsCurrent,"CfgWeapons"],[_classname,_config,_mass],_fromContainer] call _swapGear};
				case (_type in ["AccessoryBipod"])	: {[[_bipodCurrent,"CfgWeapons"],[_classname,_config,_mass],_fromContainer] call _swapGear};
				case (_category in ["Magazine"])	: {[[_magArrayCurrent select 0,"CfgMagazines"],[_classname,_config,_mass,_data],_fromContainer] call _swapGear};
				default {0}
			};
			_return
		};
		case "Handgun": {
			private _loadoutIndex = 2;
			private _currentWeaponData = _loadout select _loadoutIndex;
			_currentWeaponData params [["_weaponClassCurrent",""],["_muzzleCurrent",""],["_pointerCurrent",""],["_opticsCurrent",""],["_magArrayCurrent",[""]],["_secMagArrayCurrent",[""]],["_bipodCurrent",""]];			
			private _return = switch (true) do {
				case (_type in ["Handgun"]): {[[handgunWeapon player,"CfgWeapons"],[_classname,_config,_mass,_data],_fromContainer] call _swapGear};
				case (_type in ["AccessoryMuzzle"])	: {[[_muzzleCurrent,"CfgWeapons"],[_classname,_config,_mass],_fromContainer] call _swapGear};
				case (_type in ["AccessoryPointer"]): {[[_pointerCurrent,"CfgWeapons"],[_classname,_config,_mass],_fromContainer] call _swapGear};
				case (_type in ["AccessorySights"])	: {[[_opticsCurrent,"CfgWeapons"],[_classname,_config,_mass],_fromContainer] call _swapGear};
				case (_type in ["AccessoryBipod"])	: {[[_bipodCurrent,"CfgWeapons"],[_classname,_config,_mass],_fromContainer] call _swapGear};
				case (_category in ["Magazine"])	: {[[_magArrayCurrent select 0,"CfgMagazines"],[_classname,_config,_mass,_data],_fromContainer] call _swapGear};
				default {0}
			};
			_return
		};						
		default {0};
	};

	_return
};
switch (true) do {
	// Из рюкзака на игрока
	case ((_toContainer isEqualTo player) AND (_fromContainer isEqualTo backpackContainer player)): {
		private _canAddLoadout = [_fromContainer] call _addThisLoadout;
		if (_canAddLoadout isEqualTo true) then {[_fromContainer] call _subtractThisContainer} else {[_canAddLoadout] call client_inventory_message};
	};
	// Из контейнера на игрока
	case ((_toContainer isEqualTo player) AND !(_fromContainer isEqualTo backpackContainer player)): {
		private _canAddLoadout = [_fromContainer] call _addThisLoadout;
		if (_canAddLoadout isEqualTo true) then {[_fromContainer] call _subtractThisContainer} else {[_canAddLoadout] call client_inventory_message};
	};
	// В контейнер со снаряжения игрока
	case (_fromContainer isEqualTo player): {
		if ((_movedItemMass + _toContainerWeight) > _toContainerWeightMax) exitWith {3 call client_inventory_message};
		private _return = [_fromContainer] call _subtractThisLoadout;
		if (_return isEqualTo false) exitWith {};
		[_toContainer] call _addThisContainer;
	};
	// Между контейнерами
	case (!(player in [_fromContainer, _toContainer])): {
		if ((_movedItemMass + _toContainerWeight) > _toContainerWeightMax) exitWith {3 call client_inventory_message};
		[_fromContainer] call _subtractThisContainer;
		[_toContainer] call _addThisContainer;
	};
	default {
		-1 call client_inventory_message;
	};
};