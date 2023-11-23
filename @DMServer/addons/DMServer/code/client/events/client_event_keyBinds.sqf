private _setKeybind = {
	params [
		["_actionName", 	"SomeAction",				[""]],
		["_toolTip", 		["Описание", "ToolTip"],	[[]]],
		["_onKeyDown",		{},							[{}]],
		["_onKeyUp", 		{},							[{}]],
		["_pressedKey",		0,							[0]],
		["_keysArray",		[false, false, false],		[[]]]
	];

	["RDM Server", _actionName, _toolTip, _onKeyDown, _onKeyUp, [_pressedKey, _keysArray], false] call cba_fnc_addKeybind;
};

{
	_x call _setKeybind
} foreach [
	["PrimaryWeapon",	["Выбрать основное оружие", ""], {
		if ((primaryWeapon player) == "") exitWith {};
		player selectWeapon primaryWeapon player;
		true
	}, {true}, 2, [false, false, false]],

	["SecondaryWeapon",	["Выбрать вторичное оружие", ""], {
		if ((secondaryWeapon player) == "") exitWith {};
		player selectWeapon secondaryWeapon player;
		true
	}, {true}, 3, [false, false, false]],

	["HandgunWeapon",	["Выбрать пистолет", ""], {
		if ((handgunWeapon player) == "") exitWith {};
		player selectWeapon handgunWeapon player;
		true
	}, {true}, 4, [false, false, false]],

	["HideWeapon", ["Убрать оружие", ""], {
		player action["SwitchWeapon", player, player, 100];
		true
	}, {true}, 35, [true, false, false]],

	["Heal", ["Вылечиться", ""], {
		[] spawn client_utils_healMe;
		true
	}, {true}, 35, [false, false, false]],

	["IncreaseView", ["Увеличить прорисовку", "+100 метров"], {
		[true] call client_utils_changeViewDistance; true
	}, {true}, 13, [false, false, false]],

	["DecreaseView", ["Уменьшить прорисовку", "-100 метров"], {
		[false] call client_utils_changeViewDistance; true
	}, {true}, 12, [false, false, false]],

	["ShowScore", ["Отобразить счет", ""], {
		private _group = uiNamespace getVariable ["DM_ScoreGroup", controlNull];
		_group ctrlSetFade 0;
		_group ctrlCommit 0.25;
		true
	}, {
		private _group = uiNamespace getVariable ["DM_ScoreGroup", controlNull];
		_group ctrlSetFade 1;
		_group ctrlCommit 0.25;
		true
	}, 15, [false, false, false]],

	["JumpAction", ["Прыжок", ""], {
		if !((isTouchingGround player) AND {(stance player) == "STAND"} AND {(speed player) > 2} AND {(time - DM_jumpActionTime) > 1} AND {(getFatigue player) < 0.75}) exitWith {};
		DM_jumpActionTime = time;
		[player] remoteExec ["client_actions_jump", -2];
		player setFatigue (getFatigue player + 0.2);
		true
	}, {true}, 57, [true, false, false]],

	["LoadoutMenu", ["Меню экипировки", ""], {
		[] spawn client_loadout_choose;
		true
	}, {true}, 59, [false, false, false]],

	["LocationMenu", ["Меню локаций", ""], {
		[] spawn client_spawn_chooseCity;
		true
	}, {true}, 60, [false, false, false]],

	["VehicleMenu", ["Меню боевой техники", ""], {
		[] spawn client_vehicle_warChoose;
		true
	}, {true}, 61, [false, false, false]],

	["EarPlugs", ["Беруши", "10% / 100% от установленного звука"], {
		switch (soundVolume) do {
			case 1: {["Громкость 10%", "info"] call client_gui_hint; 1 fadeSound 0.1};
			case 0.1: {["Громкость 100%", "info"] call client_gui_hint; 1 fadeSound 1};
		};
	}, {true}, 207, [true, false, false]]
];