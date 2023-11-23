private _unit = param [0,objNull,[objNull]];

if (isNull _unit) exitWith {};
if (animationState _unit == "AovrPercMrunSrasWrflDf") exitWith {};

if (local _unit) then {
	private _direction		= direction _unit;
	private _jumpDistance	= 4.3;
	private _velocity		= [];
	_velocity set[0, sin _direction * _jumpDistance];
	_velocity set[1, cos _direction * _jumpDistance];
	_velocity set[2, _jumpDistance];

	_unit setVelocity _velocity
};

_unit switchMove "AovrPercMrunSrasWrflDf";