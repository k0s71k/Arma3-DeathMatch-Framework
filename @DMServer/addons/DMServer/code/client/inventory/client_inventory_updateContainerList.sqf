params ["_container","_list"];
private _containerWeight = (ctrlParentControlsGroup _list) getVariable ["weightCtrl",controlNull];
private _filter = ["Gear", "Weapons", "Magazines", "Items"]; 

if (isNull _container) exitWith {
	lbClear _list;
	_containerWeight ctrlSetStructuredText parseText "<t align='center'>Рюкзак отсутствует";
};
private _currentWeight = 0;
private _maximumWeight = getNumber (configFile >> "CfgVehicles" >> typeOf _container >> "maximumLoad");
private _weaponsItemsCargo = weaponsItemsCargo _container;
private _weaponsCargo = [];
private _magazinesAmmoCargo = magazinesAmmoCargo _container;
private _magazinesCargo = [];
{
	private _thisItem = _x;
	private _index = _magazinesCargo findIf {_x isEqualTo _thisItem};
	if (_index isEqualTo -1) then {
		_magazinesCargo pushBack _thisItem;
		_magazinesCargo pushBack 1;
	} else {
		private _amount = _magazinesCargo select (_index + 1);
		_magazinesCargo set [_index + 1,_amount + 1];
	};
} forEach _magazinesAmmoCargo;
private _backpackCargo = getBackpackCargo _container;
_backpackCargo params ["_backpackArray","_backpackCountArray"];
private _itemCargo = getItemCargo _container;
_itemCargo params ["_itemArray","_itemCountArray"];
lbClear _list;
{
	_x params ["_weaponClass","_muzzle","_pointer","_optics","_magArray","_secMagArray","_bipod"];
	if (_x isEqualTo [_weaponClass,"","","",[],[],""]) then {
		private _index = _weaponsCargo findIf {_x isEqualTo _weaponClass};
		if (_index isEqualTo -1) exitWith {
			_weaponsCargo pushBack _weaponClass;
			_weaponsCargo pushBack 1;
		};
		private _amount = _weaponsCargo select (_index + 1);
		_weaponsCargo set [_index + 1,_amount + 1];
	} else {
		_magArray params [["_mag",""]];
		_secMagArray params [["_secMag",""]];
		private _picture = getText (configFile >> "CfgWeapons" >> _weaponClass >> "picture");
		private _displayName = getText (configFile >> "CfgWeapons" >> _weaponClass >> "displayName");
		private _weaponMassAttachments = 0;
		{
			private _mass = if (isClass (configFile >> "CfgWeapons" >> _x >> "WeaponSlotsInfo")) then {
				getNumber (configFile >> "CfgWeapons" >> _x >> "WeaponSlotsInfo" >> "mass")
			} else {
				getNumber (configFile >> "CfgWeapons" >> _x >> "ItemInfo" >> "mass")
			};
			_weaponMassAttachments = _weaponMassAttachments + _mass;
		} forEach [_weaponClass,_muzzle,_pointer,_optics,_bipod]; 
		{_weaponMassAttachments = _weaponMassAttachments +  (getNumber (configFile >> "CfgMagazines" >> _x >> "mass"))} forEach [_mag,_secMag]; 

		_list lbAdd format["%1",_displayName];
		_list lbSetPicture [lbSize _list -1,_picture];
		_list lbSetColor [lbSize _list -1,[0,1,0,0.75]];
		_list lbSetTextRight [lbSize _list -1,format["%1 кг ",_weaponMassAttachments / 20 toFixed 1]];
		_list lbSetData [lbSize _list -1,str [_weaponClass,_displayName,"CfgWeapons",_weaponMassAttachments,1,_x]];
		[_list,lbSize _list -1] call client_inventory_setToolTipLB;
		_currentWeight = _currentWeight + _weaponMassAttachments;
	};
} forEach _weaponsItemsCargo;
{
	
	if (_x isEqualType "") then {
		private _amount = _weaponsCargo select (_forEachIndex + 1);
		private _massUnit = if (isClass (configFile >> "CfgWeapons" >> _x >> "WeaponSlotsInfo")) then {
			getNumber (configFile >> "CfgWeapons" >> _x >> "WeaponSlotsInfo" >> "mass")
		} else {
			getNumber (configFile >> "CfgWeapons" >> _x >> "ItemInfo" >> "mass")
		};	
		_mass = _massUnit * _amount;
		private _picture = getText (configFile >> "CfgWeapons" >> _x >> "picture");
		private _displayName = getText (configFile >> "CfgWeapons" >> _x >> "displayName");

		_list lbAdd format["%1x %2",_amount,_displayName];
		_list lbSetPicture [lbSize _list -1,_picture];
		_list lbSetTextRight [lbSize _list -1,format["%1 кг", _mass / 20 toFixed 1]];		
		_list lbSetData [lbSize _list -1,str [_x,_displayName,"CfgWeapons",_massUnit,_amount,[_x,"","","",[],[],""]]];
		[_list,lbSize _list -1] call client_inventory_setToolTipLB;					
		_currentWeight = _currentWeight + _mass;
	};
} forEach _weaponsCargo;
{
	if (_x isEqualType []) then {
		_x params ["_magazine","_ammocount"];
		private _amount = _magazinesCargo select (_forEachIndex + 1);
		private _picture = getText (configFile >> "CfgMagazines" >> _magazine >> "picture");
		private _displayName = getText (configFile >> "CfgMagazines" >> _magazine >> "displayName");
		private _massUnit = getNumber (configFile >> "CfgMagazines" >> _magazine >> "mass");
		_mass = _massUnit * _amount;

		if (_ammocount > 1) then {
			_list lbAdd format["%1x [%2 пат] %3",_amount,_ammocount,_displayName];
		} else {
			_list lbAdd format["%1x %2",_amount,_displayName];
		};				
		_list lbSetPicture [lbSize _list -1,_picture];
		_list lbSetTextRight [lbSize _list -1,format["%1 кг ",_mass / 20 toFixed 1]];
		_list lbSetData [lbSize _list -1,str [_magazine,_displayName,"CfgMagazines",_massUnit,_amount,_x]];
		[_list,lbSize _list -1] call client_inventory_setToolTipLB;	
		_currentWeight = _currentWeight + _mass;			
	};
} forEach _magazinesCargo;
{
	private _amount = _backpackCountArray select _forEachIndex;
	private _picture = getText (configFile >> "CfgVehicles" >> _x >> "picture");
	private _displayName = getText (configFile >> "CfgVehicles" >> _x >> "displayName");		
	private _massUnit = getNumber (configFile >> "CfgVehicles" >> _x >> "mass");
	_mass = _massUnit * _amount;

	_list lbAdd format["%1x %2",_amount,_displayName];
	_list lbSetPicture [lbSize _list -1,_picture];
	_list lbSetTextRight [lbSize _list -1,format["%1 кг ",_mass / 20 toFixed 1]];	
	_list lbSetData [lbSize _list -1,str [_x,_displayName,"CfgVehicles",_massUnit,_amount,[]]];
	[_list,lbSize _list -1] call client_inventory_setToolTipLB;	
	_currentWeight = _currentWeight + _mass; 
} forEach _backpackArray;
{
	private _itemTypes = _x call BIS_fnc_itemType;
	_itemTypes params ["_cat","_type"];
	private _configType = switch (_type) do {
		case "Glasses": {"CfgGlasses"};
		default {"CfgWeapons"};
	};
	private _amount = _itemCountArray select _forEachIndex;
	private _picture = getText (configFile >> _configType >> _x >> "picture");
	private _displayName = getText (configFile >> _configType >> _x >> "displayName");		
	private _massUnit = switch (true) do {
		case (isClass (configFile >> "CfgWeapons" >> _x >> "WeaponSlotsInfo")): {getNumber (configFile >> "CfgWeapons" >> _x >> "WeaponSlotsInfo" >> "mass")};
		case (_configType isEqualTo "CfgGlasses"): {getNumber (configFile >> "CfgGlasses" >> _x  >> "mass")};
		default {getNumber (configFile >> "CfgWeapons" >> _x >> "ItemInfo" >> "mass")};
	};
	_mass = _massUnit * _amount;

	_list lbAdd format["%1x %2",_amount,_displayName];
	_list lbSetPicture [lbSize _list -1,_picture];
	_list lbSetTextRight [lbSize _list -1,format["%1 кг ",_mass / 20 toFixed 1]];
	_list lbSetData [lbSize _list -1,str [_x,_displayName,_configType,_massUnit,_amount,[]]];
	[_list,lbSize _list -1] call client_inventory_setToolTipLB;

	_currentWeight = _currentWeight + _mass; 
} forEach _itemArray;	
private _textFormat = format["<t align='center'>%1 / %2 кг", _currentWeight / 20 toFixed 1, _maximumWeight / 20 toFixed 1];
_containerWeight ctrlSetStructuredText parseText _textFormat;
_container setVariable ["currentWeight", _currentWeight];
_container setVariable ["maximumWeight", _maximumWeight];