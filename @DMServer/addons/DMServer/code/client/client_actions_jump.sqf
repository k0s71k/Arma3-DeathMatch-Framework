private _unit = param [0,objNull,[objNull]];

if (isNull _unit) exitWith {};
if (animationState _unit == "AovrPercMrunSrasWrflDf") exitWith {};

if (local _unit) then {
	private _direction = direction _unit;
	private _jumpDistance = 4.3;
	private _xVelocity = sin _direction * _jumpDistance;
	private _yVelocity = cos _direction * _jumpDistance;
	private _zVelocity = _jumpDistance;

	_unit setVelocity [_xVelocity, _yVelocity, _zVelocity];
};

_unit switchMove "AovrPercMrunSrasWrflDf";