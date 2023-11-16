private _unit = param [0,objNull,[objNull]];

if (isNull _unit) exitWith {};
if (animationState _unit == "AovrPercMrunSrasWrflDf") exitWith {};

if (local _unit) then {
	private _direction = direction _unit;

	_velz = 4.3;
	_velx = sin _direction * _maxVelocity;
	_vely = cos _direction * _maxVelocity;

	_unit setVelocity [_velx, _vely, _velz];
};

_unit switchMove "AovrPercMrunSrasWrflDf";