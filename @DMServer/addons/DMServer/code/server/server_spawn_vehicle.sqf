//server_spawn_vehicle
params [
	["_className", "", [""]],
	["_position", [0,0,0], [[]]],
	["_direction", 0, [0]]
];

// Создаем технику
private _vehicle = _className createVehicle [0, 0, 300];
_vehicle allowDamage false;
//_vehicle setPosATL _position;
//_vehicle setVectorUp (surfaceNormal _position);
_vehicle setDir 	_direction;
_vehicle setVehiclePosition [_position, [], 0, "CAN_COLLIDE"];
_vehicle setDamage	0;
_vehicle setFuel	1;
_vehicle lock		false;
_vehicle disableTIEquipment	true;
_vehicle enableRopeAttach	false;
_vehicle allowDamage		true;

// Удаляем вещи из транспорта
clearWeaponCargoGlobal		_vehicle;
clearItemCargoGlobal		_vehicle;
clearMagazineCargoGlobal	_vehicle;
clearBackpackCargoGlobal	_vehicle;
// Сообщаем человеку о том, что техника будет удалена, если не сесть в неё
private _vehicleName = getText(configFile >> "CfgVehicles" >> _className >> "displayName");
[
	format[
		"Вы достали <t color='#f5be00'>%1</t>
		<br/>У вас есть 30 секунд чтобы сесть в технику до того как она будет удалена",
	_vehicleName],
"warning"] remoteExecCall ["client_gui_hint", remoteExecutedOwner];

// Не принимаем дамаг в сейф зоне
_vehicle addEventHandler ["HandleDamage", {
	if (call client_utils_inSafeZone) exitWith {0};
}];

_vehicle spawn {
	waitUntil {
		uiSleep 30;
		!alive _this OR
		{count (crew _this) == 0}
	};
	
	deleteVehicle _this
};