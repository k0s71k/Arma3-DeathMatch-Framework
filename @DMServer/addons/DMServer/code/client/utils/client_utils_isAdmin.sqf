params [
	["_unit", objNull, [objNull]]
];

if (isNull _unit) exitWith {};
private _admins = (missionConfigFile >> "enableDebugConsole");

if (isArray(_admins)) exitWith {
	getPlayerUID _unit in getArray(_admins)
};
getPlayerUID _unit == getText(_admins);