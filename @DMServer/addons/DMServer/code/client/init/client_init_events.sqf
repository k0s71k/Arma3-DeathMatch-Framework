#define GUI_GRID_W    (0.025)
#define GUI_GRID_H    (0.04)

// Бинды для всех игроков
(findDisplay 46) displayAddEventHandler ["KeyDown", {
	params ["_ctrl", "_code", "_shift", "_ctrlKey", "_alt"];
	private _handled = false;
	private _cursorTarget = cursorObject;
	// Не даем открыть чат
	if (_code in (
		actionKeys "NextChannel" +
		actionKeys "PrevChannel" +
		actionKeys "chat"
	)) exitWith {true};
	// Не даем открыть commandingMenu
	if (_code in (
		actionKeys "TacticalView" + 
		actionKeys "SelectAll" + 
		actionKeys "forceCommandingMode" + 
		[11,14,62,63,64,65,66,67,68,36]
	)) exitWith {true};

	switch (_code) do {
		// Основное оружие
		case 2: {
			if ((primaryWeapon player) != "") then {
				player selectWeapon primaryWeapon player;
			};
			_handled = true
		};
		// Гранатомет
		case 3: {
			if ((secondaryWeapon player) != "") then {
				player selectWeapon secondaryWeapon player;
			};
			_handled = true
		};
		// Пистолет
		case 4: {
			if ((handgunWeapon player) != "") then {
				player selectWeapon handgunWeapon player;
			};
			_handled = true
		};
		// +/- Бинды на дистанцию прорисовки
		case 12 : {
			if (time < DM_timeout) exitWith {};
			DM_timeout = time + 0.5;
			if (DM_viewDistance <= 200) exitWith {};
			DM_viewDistance = round(DM_viewDistance - 100);
			profileNamespace setVariable ["DM_viewDistance", DM_viewDistance];
			setViewDistance DM_viewDistance;
			setObjectViewDistance DM_viewDistance - 100;
			[format["Дистанция прорисовки %1м.", DM_viewDistance], "info"] call client_gui_hint;
			_handled = true
		};
		case 13 : {
			if (time < DM_timeout) exitWith {};
			DM_timeout = time + 0.5;
			if (DM_viewDistance >= 12000) exitWith {};
			DM_viewDistance = round(DM_viewDistance + 100);
			profileNamespace setVariable ["DM_viewDistance", DM_viewDistance];
			setViewDistance DM_viewDistance;
			setObjectViewDistance DM_viewDistance - 100;
			[format["Дистанция прорисовки %1м.", DM_viewDistance], "info"] call client_gui_hint;
			_handled = true
		};
		case 15 : {
			if (_alt OR _shift OR _ctrlKey) exitWith {};
			private _group = uiNamespace getVariable ["DM_ScoreGroup", controlNull];
			_group ctrlSetFade 0;
			_group ctrlCommit 0.25;
		};
		// Убрать оружие (Shift + H)
		case 35 : {
			if (_shift AND (currentWeapon player) != "") then {
				player action["SwitchWeapon", player, player, 100];
			} else {
				[] spawn client_utils_healMe
			};
			_handled = true
		};
		// Прыжок (Пробел)
		case 57 : {
			if (isNil "jumpActionTime") then {jumpActionTime = 0};
			if (_shift AND {isTouchingGround player} AND {(stance player) == "STAND"} AND {(speed player) > 2} AND {(time - jumpActionTime) > 1} AND {(getFatigue player) < 0.75}) then {
				jumpActionTime = time;
				[player] remoteExec ["client_actions_jump", -2];
				player setFatigue (getFatigue player + 0.2);
				_handled = true
			};
		};
		// Меню выбора снаряжения (F1)
		case 59 : {
			[] spawn client_loadout_choose;
			_handled = true
		};
		// Меню выбора спавна (F2)
		case 60 : {
			[] spawn client_spawn_chooseCity;
			_handled = true
		};
		// Меню выбора боевой техники (F3)
		case 61 : {
			[] spawn client_vehicle_warChoose;
			_handled = true
		};
		// Приглушить звук (Shift + End) 
		case 207 : {
			if (_shift) then {
				switch (soundVolume) do {
					case 1: {["Громкость 10%", "info"] call client_gui_hint; 1 fadeSound 0.1};
					case 0.1: {["Громкость 100%", "info"] call client_gui_hint; 1 fadeSound 1};
				};
				_handled = true
			};
		};
	};

	_handled;
}];

(findDisplay 46) displayAddEventHandler ["KeyUp", {
	params ["_display", "_code", "_shift", "_ctrl", "_alt"];
	if (_code == 15 AND !_ctrl AND !_shift AND !_alt) then {
		private _group = uiNamespace getVariable ["DM_ScoreGroup", controlNull];
		_group ctrlSetFade 1;
		_group ctrlCommit 0.25;
	};
}];

// Admin Binds
if (getPlayerUID player in [/* "1UID", "2UID" */]) then {
	// Map Teleport
	((findDisplay 12) displayCtrl 51) ctrlAddEventHandler ["MouseButtonDown", {
		params ["_control", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
		if (_alt) then {
			_pos = (_control posScreenToWorld [_xPos, _yPos]);
			_veh = vehicle player;
			if (_veh == player) then {
				_veh setPosATL _pos;
			} else {
				if (_veh isKindOf 'Air') then {
					_posObj = getPosATL _veh;
					_pos = [_pos # 0, _pos # 1, _posObj # 2];
				};
				_veh allowDamage false;
				_veh SetVelocity [0,0,1];
				_veh setPosATL _pos;
				_veh allowDamage true;
			};
		};
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
		switch (_code) do {
			// Shift + 4 (Admin Jump)
			case 5: {
				if (_shift) then {
					private _jumpVelocity = [
						_velocity # 0,
						_velocity # 1,
						6
					];
					_vehicle setVelocity _jumpVelocity;
					true
				};
			};
			// Shift + 5 (TP 7m forward)
			case 6: {
				if (_shift) then {
					private _distance = 7;
					private _moveForvardPos = [
						(_position # 0) + sin _direction * _distance,
						(_position # 1) + cos _direction * _distance,
						_position # 2
					];
					_vehicle setPosATL _moveForvardPos;
					true
				};
			};
			// Repair object (Shift + F)
			case 33 : {
				if (_shift) exitWith {
					if (isNull _target) then {
						_target = player;
					};
					_target setDamage 0;
					
					[format["Вы починили %1", getText(configFile >> "CfgVehicles" >> typeOf _target >> "displayName")], "done"] call client_gui_hint;
					true
				};
			};
			// Delete (Delete Object)
			case 211 : {
				if (!(isNull _target) AND !(isPlayer _target) AND (_target != objectParent player)) exitWith {
					deleteVehicle _target;
					[format["Вы удалили %1", getText(configFile >> "CfgVehicles" >> typeOf _target >> "displayName")], "done"] call client_gui_hint;
					true
				};
			};

			default {false};
		};
	}];
};
// TODO: использовать _instigator или _shooter в отдельных случаях для определения стрелка
player addEventHandler ["HandleDamage", {
	params ["_unit", "_selection", "_damage", "_shooter", "_projectile", "_hitPointIndex", "_instigator"];
	// Не считаем урон от боевой техники, если игрок пехотинец
	if (
		((driver _shooter) getVariable ["DM_WarVehicleMode", false]) AND	// Убийца в боевом режиме
		{!(player getVariable ["DM_WarVehicleMode", false])}				// Игрок не в боевом режиме
	) then {
		[] remoteExec ["client_vehicle_punishment", crew vehicle _shooter];
		player setVelocity [0, 0, 0];
		_damage = 0
	};
	// Не считаем урон на спавнах
	if (call client_utils_inSafeZone) then {_damage = 0};
	if (missionNamespace getVariable ["DM_Killed", false]) then {_damage = 0};

	// Никогда не убиваем человека
	_damage = _damage min 0.89;
	// Определяем последнего человека, который попал по нам (должен быть !isNull)
	if ((vehicle _shooter != vehicle player) AND !isNull _shooter) then {
		DM_LastHitFrom = _shooter;
	};
	// При дамаге в 0.89 респавним человека на главной базе
	if (_damage == 0.89) then {
		DM_Killed = true;
		[] spawn client_spawn_onBase;
		// Если были попадания по человеку не от него самого
		if (!isNil "DM_LastHitFrom") then {
			// Отправляем информацию остальным клиентам
			[player, DM_LastHitFrom] remoteExec ["client_event_killed", -2];
			// Сообщаем стрелку об убийстве
			[format["Вы убили %1", name player], "done"] remoteExecCall ["client_gui_hint", DM_LastHitFrom];
			// Получаем сообщение о том, кто убил
			[format["Вас убил %1", name DM_LastHitFrom], "warning"] call client_gui_hint;
			DM_LastHitFrom = nil;
		};
		_damage = 0
	};

	_damage
}];

player addEventHandler ["InventoryOpened", {
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
}];

player addEventHandler ["InventoryClosed", {
	// При закрытии инвентаря, удаляем контейнер
	deleteVehicle (_this # 1);
}];

// Отображаем имена игроков
addMissionEventHandler ["Draw3D", {
	// Берем всех людей в радиусе 15 метров
	private _units = nearestObjects [player, ["Man"], 16];
	_units = _units - [player];

	// Создаем DrawIcon3D для каждого человека
	{
		if !(isPlayer AND {!(lineIntersects [eyePos player, eyePos _x, player, _x])}) then {continue};

		private _name = [name _x, format["- %1 -", name _x]] select (_x getVariable ["tf_isSpeaking", false]);
		private _dist = (player distance _x) / 15;
		private _color = [0.9, 0.9, 0.9, 1 - _dist];
		private _pos = ASLToAGL (getPosASL _x);
		// Устанавливаем высоту в зависимости от дистанции до игрока
		_pos set [2, _pos # 2 + ((_x selectionPosition ['Head', "HitPoints"]) # 2) + 0.2 + (0.6 * _dist)];
		drawIcon3D ["", _color, _pos, 1, 1, 0, _name, 2, 0.9 * GUI_GRID_H, "RobotoCondensedBold", "center"];
	} forEach _units;
}];