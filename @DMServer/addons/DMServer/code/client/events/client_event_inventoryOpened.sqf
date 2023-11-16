if (time < DM_timeout) exitWith {true};
DM_timeout = time + 0.5;
params ["_unit", "_container"];

private _allowToUseContainer = {
	private _container = param[0,objNull]; 
	private _usedBy = _container getVariable ["usedBy", objNull];
	// Контейнер не человек
	if (
		_container isKindOf "Man"
	) exitWith {false};
	// Проврека на использующего
	if (
		isNull _usedBy OR
		{_usedBy == player} OR
		{_usedBy distance _container > 10}
	) exitWith {true};
	false
};
// Проверяем доступность контейнера
private _allowed = [_container] call _allowToUseContainer;
[_container, !(_allowed)] spawn client_inventory_open;
if (_allowed) then {
	_container setVariable ["usedBy", player, true];
};

true