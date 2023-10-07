params ["_container"];
if (backpack player isEqualTo "") exitWith {};
if !(call client_inventory_canOperate) exitWith {};		
private _backpackCargo = getUnitLoadout player # 5 # 1;
private _containerWeight = _container getVariable ["currentWeight",-1];
if (_containerWeight isEqualTo -1) exitWith {};
private _containerWeightMax = _container getVariable ["maximumWeight",-1];
if (_containerWeight isEqualTo -1) exitWith {};
private _backpackLoad = (loadBackpack player) * (getContainerMaxLoad backpack player);
if ((_backpackLoad + _containerWeight) > _containerWeightMax) exitWith {3 call client_inventory_message; false};
{
	_x params ["_class"];
	if (_class isEqualType []) then {
		_class params ["_subclass"];
		_container addWeaponWithAttachmentsCargoGlobal [_class, 1];
	} else {
		_x params ["","_count",["_ammocount",1]];
		if (_count isEqualType false) then {_count = 1};
		private _types = _class call BIS_fnc_itemType;
		_types params ["_category","_type"];
		switch (true) do {
			case ((_category in ["Item"]) OR (_type in ["Glasses", "Vest", "Uniform", "Headgear"])): {_container addItemCargoGlobal [_class,_count]};			
			case (_category in ["Magazine", "Mine"]): {_container addMagazineAmmoCargo [_class,_count,_ammocount]};
			case (_type in ["Backpack"]): {_container addBackpackCargoGlobal [_class, 1]};
		};
	};
} forEach _backpackCargo;
true