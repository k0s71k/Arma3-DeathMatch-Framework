private _unit = param [0,objNull,[objNull]];

if (isNull _unit) exitWith {};
if (animationState _unit == "AovrPercMrunSrasWrflDf") exitWith {};

if (local _unit) then {
	private _maxVelocity = 4.3;
	private _direction = direction _unit;

	_velz = _maxVelocity;
	_velx = (sin _direction * _maxVelocity) min _maxVelocity;
	_vely = (cos _direction * _maxVelocity) min _maxVelocity;

	switch (true) do {
		case (_velx <= 0): {_velx = _velx max (_maxVelocity * -1)};
		case (_vely <= 0): {_vely = _vely max (_maxVelocity * -1)};
	};

	_unit setVelocity [_velx, _vely, _velz];
};

_unit switchMove "AovrPercMrunSrasWrflDf";