if !([player] call client_utils_isAdmin) exitWith {};

// Map Teleport
((findDisplay 12) displayCtrl 51) ctrlAddEventHandler ["MouseButtonDown", {
	params [
		"_control",
		"_button",
		"_xPos",
		"_yPos",
		"_shift",
		"_ctrl",
		"_alt"
	];

	if !(_alt) exitWith {false};
	
	private _pos = (_control posScreenToWorld [_xPos, _yPos]);

	if (isNull objectParent player) exitWith {
		player setPosATL _pos;
	};

	private _vehicle = objectParent player;
	if (_vehicle isKindOf 'Air') then {
		_pos = [_pos # 0, _pos # 1, (getPosATL _vehicle) # 2];
	};
	_vehicle allowDamage false;
	_vehicle SetVelocity [0,0,1];
	_vehicle setPosATL _pos;
	_vehicle allowDamage true;
}];
// Key Binds
(findDisplay 46) displayAddEventHandler ["KeyDown", {
	params [
		"_ctrl",
		"_code",
		"_shift",
		"_ctrlKey",
		"_alt"
	];

	private _vehicle = vehicle player;
	private _direction = getDir _vehicle;
	private _velocity = velocity _vehicle;
	private _position = getPosATL _vehicle;
	private _target = [objectParent player, cursorObject] select (isNull objectParent player);
	private _handled = false;
	switch (_code) do {
		// Shift + 4 (Admin Jump)
		case 5: {
			if !(_shift) exitWith {};

			private _jumpVelocity = [
				_velocity # 0,
				_velocity # 1,
				6
			];
			_vehicle setVelocity _jumpVelocity;
			_handled = true
		};
		// Shift + 5 (TP 7m forward)
		case 6: {
			if !(_shift) exitWith {};

			private _distance = 7;
			private _moveForvardPos = [
				(_position # 0) + sin _direction * _distance,
				(_position # 1) + cos _direction * _distance,
				_position # 2
			];
			_vehicle setPosATL _moveForvardPos;
			true
		};
		// Repair object (Shift + F)
		case 33 : {
			if !(_shift) exitWith {};
			
			if (isNull _target) then {
				_target = player;
			};
			_target setDamage 0;
			
			[format["Вы починили %1", getText(configFile >> "CfgVehicles" >> typeOf _target >> "displayName")], "done"] call client_gui_hint;
			true
		};
		// Delete (Delete Object)
		case 211 : {
			if ((isNull _target) OR {isPlayer _target OR {_target == objectParent player}}) exitWith {};
				
			deleteVehicle _target;
			[format["Вы удалили %1", getText(configFile >> "CfgVehicles" >> typeOf _target >> "displayName")], "done"] call client_gui_hint;
			true
		};

		default {false};
	};
	_handled
}];