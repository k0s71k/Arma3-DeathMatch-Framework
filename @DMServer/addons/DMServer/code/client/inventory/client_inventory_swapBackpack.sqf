params ["_newBackpackClass"];
// Если нет рюкзака
if (backpack player isEqualTo "") exitWith {
	player addBackpack _newBackpackClass;
	false
};
// Проверяем загрузку
private _newBackpackMass		= getNumber (configFile >> "CfgVehicles" >> _newBackpackClass >> "mass");
private _newBackpackMaxLoad		= getNumber (configFile >> "CfgVehicles" >> _newBackpackClass >> "maximumLoad");
private _oldBackpackMass		= getNumber (configFile >> "CfgVehicles" >> backpack player >> "mass");
private _oldBackpackCargoMass	= (loadBackpack player) * (getContainerMaxLoad backpack player);
if ((_oldBackpackCargoMass + _oldBackpackMass - _newBackpackMass) > _newBackpackMaxLoad) exitWith {2};
// Устанавливаем новый рюкзак для игрока
private _loadout				= getUnitLoadout player;
private _oldBackpackArray		= _loadout select 5;
_oldBackpackArray params ["_oldBackpack", "_oldBackpackCargo"];
_oldBackpackArray set [0, _newBackpackClass];
player setUnitLoadout _loadout;
true