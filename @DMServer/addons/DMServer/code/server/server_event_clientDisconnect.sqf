//server_event_clientDisconnect
private _unit = param[0, objNull, [objNull]];

if (!isNull _unit) then {
	_unit setDamage 1;
	deleteVehicle _unit;
};