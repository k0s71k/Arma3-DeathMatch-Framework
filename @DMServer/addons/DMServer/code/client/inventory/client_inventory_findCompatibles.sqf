params [
	["_slotType", ""]
];

private _display		= uiNamespace getVariable ["InventoryDisplay",displayNull];
private _backList		= _display getVariable ["backList",controlNull];
private _containerList	= _display getVariable ["containerList",controlNull];
private _scanListBox = {
	params ["_list", "_typesToFind", ["_compatibleWith", ""]];
	private _dataArray = [];
	for "_x" from 0 to (lbSize _list - 1) do {
		private _lbData = call compile (_list lbData _x);
		_lbData params ["_classname","_displayname","_config","_mass",["_amount",1],"_itemdata"];
		(_classname call BIS_fnc_itemType) params ["_category","_type"];
		if (_type in _typesToFind) then {
			// Specific compatibles
			if !(_compatibleWith isEqualTo "") exitWith {
				private _compatibles	= getArray (configFile >> "CfgWeapons" >> _compatibleWith >> "magazines");
				private _muzzles		= (getArray (configFile >> "CfgWeapons" >> _compatibleWith >> "muzzles")) - ["this"];
				{_compatibles append (getArray (configFile >> "CfgWeapons" >> _compatibleWith >> _x >> "magazines"))} forEach _muzzles;
				private _addons			= _compatibleWith call BIS_fnc_compatibleItems;
				_compatibles append _addons;

				if (toLower _classname in (_compatibles apply {toLower _x})) then {
					private _picture	= getText (configFile >> _config >> _classname >> "picture");
					_dataArray pushBack [[_displayname,_picture],_lbData,(ctrlParentControlsGroup _list) getVariable ["containerObject",objNull]];
				};
			};
			private _picture			= getText (configFile >> _config >> _classname >> "picture");
			if ((_category isEqualTo "Weapon") AND !(_itemdata isEqualTo [_classname,"","","",[],[],""])) then {_displayname = format ["<t color='#00FF00'>%1</t>", _displayname]};
			_dataArray pushBack [[_displayname,_picture],_lbData,(ctrlParentControlsGroup _list) getVariable ["containerObject",objNull]];
		};
	};
	_dataArray
};
private _dataArray = switch (_slotType) do {
	case "Primary": {
		([_containerList,["AssaultRifle","MachineGun","Shotgun","Rifle","SubmachineGun","SniperRifle"]] call _scanListBox) 
		+ 
		([_backList,["AssaultRifle","MachineGun","Shotgun","Rifle","SubmachineGun","SniperRifle"]] call _scanListBox)
	};
	case "PrimaryMuzzle": {
		if (primaryWeapon player == "") exitWith {[]};
		([_containerList,["AccessoryMuzzle"],primaryWeapon player] call _scanListBox) 
		+ 
		([_backList,["AccessoryMuzzle"],primaryWeapon player] call _scanListBox)
	};
	case "PrimaryLaser": {
		if (primaryWeapon player == "") exitWith {[]};
		([_containerList,["AccessoryPointer"],primaryWeapon player] call _scanListBox) 
		+ 
		([_backList,["AccessoryPointer"],primaryWeapon player] call _scanListBox)
	};
	case "PrimaryOptics": {
		if (primaryWeapon player == "") exitWith {[]};
		([_containerList,["AccessorySights"],primaryWeapon player] call _scanListBox) 
		+ 
		([_backList,["AccessorySights"],primaryWeapon player] call _scanListBox)
	};
	case "PrimaryGL": {
		if (primaryWeapon player == "") exitWith {[]};
		([_containerList,["Shell","SmokeShell"],primaryWeapon player] call _scanListBox) 
		+ 
		([_backList,["Shell","SmokeShell"],primaryWeapon player] call _scanListBox)		
	};
	case "PrimaryMag": {
		if (primaryWeapon player == "") exitWith {[]};
		([_containerList,["Bullet"],primaryWeapon player] call _scanListBox) 
		+ 
		([_backList,["Bullet"],primaryWeapon player] call _scanListBox)				
	};
	case "PrimaryBipod": {
		if (primaryWeapon player == "") exitWith {[]};
		([_containerList,["AccessoryBipod"],primaryWeapon player] call _scanListBox) 
		+ 
		([_backList,["AccessoryBipod"],primaryWeapon player] call _scanListBox)
	};
	case "Secondary": {
		([_containerList,["BombLauncher","Cannon","GrenadeLauncher","MissileLauncher","RocketLauncher","Throw"]] call _scanListBox)
		+ 
		([_backList,["BombLauncher","Cannon","GrenadeLauncher","MissileLauncher","RocketLauncher","Throw"]] call _scanListBox)
	};
	case "SecondaryMuzzle": {
		if (secondaryWeapon player == "") exitWith {[]};
		([_containerList,["AccessoryMuzzle"],secondaryWeapon player] call _scanListBox) 
		+ 
		([_backList,["AccessoryMuzzle"],secondaryWeapon player] call _scanListBox)
	};
	case "SecondaryLaser": {
		if (secondaryWeapon player == "") exitWith {[]};
		([_containerList,["AccessoryPointer"],secondaryWeapon player] call _scanListBox) 
		+ 
		([_backList,["AccessoryPointer"],secondaryWeapon player] call _scanListBox)
	};
	case "SecondaryOptics": {
		if (secondaryWeapon player == "") exitWith {[]};
		([_containerList,["AccessorySights"],secondaryWeapon player] call _scanListBox) 
		+ 
		([_backList,["AccessorySights"],secondaryWeapon player] call _scanListBox)
	};
	case "SecondaryMag": {
		if (secondaryWeapon player == "") exitWith {[]};
		([_containerList,["Missile","Rocket","UnknownMagazine"],secondaryWeapon player] call _scanListBox) 
		+ 
		([_backList,["Missile","Rocket","UnknownMagazine"],secondaryWeapon player] call _scanListBox)				
	};
	case "SecondaryBipod": {
		if (secondaryWeapon player == "") exitWith {[]};
		([_containerList,["AccessoryBipod"],secondaryWeapon player] call _scanListBox) 
		+ 
		([_backList,["AccessoryBipod"],secondaryWeapon player] call _scanListBox)
	};
	case "Handgun": {	
		([_containerList,["Handgun"]] call _scanListBox) 
		+ 
		([_backList,["Handgun"]] call _scanListBox)
	};
	case "HandgunMuzzle": {
		if (handgunWeapon player == "") exitWith {[]};
		([_containerList,["AccessoryMuzzle"],handgunWeapon player] call _scanListBox) 
		+ 
		([_backList,["AccessoryMuzzle"],handgunWeapon player] call _scanListBox)
	};
	case "HandgunLaser": {
		if (handgunWeapon player == "") exitWith {[]};
		([_containerList,["AccessoryPointer"],handgunWeapon player] call _scanListBox) 
		+ 
		([_backList,["AccessoryPointer"],handgunWeapon player] call _scanListBox)
	};
	case "HandgunOptics": {
		if (handgunWeapon player == "") exitWith {[]};
		([_containerList,["AccessorySights"],handgunWeapon player] call _scanListBox) 
		+ 
		([_backList,["AccessorySights"],handgunWeapon player] call _scanListBox)
	};
	case "HandgunMag": {
		if (handgunWeapon player == "") exitWith {[]};
		([_containerList,["Bullet"], handgunWeapon player] call _scanListBox) 
		+ 
		([_backList,["Bullet"], handgunWeapon player] call _scanListBox)				
	};
	case "HandgunBipod": {
		if (handgunWeapon player == "") exitWith {[]};
		([_containerList,["AccessoryBipod"],handgunWeapon player] call _scanListBox) 
		+ 
		([_backList,["AccessoryBipod"],handgunWeapon player] call _scanListBox)
	};
	default {([_containerList,_slotType] call _scanListBox) + ([_backList,_slotType] call _scanListBox)}
};
_dataArray