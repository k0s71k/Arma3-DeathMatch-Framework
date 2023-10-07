#define GUI_GRID_H (0.04)
#define GUI_GRID_W (0.025)

params [
	["_container", objNull, [objNull]],
	["_readonly", false, [false]]
];

// Ищем контейнер если он не передался через параметры
if (isNull _container) then {
	_container = call client_inventory_createContainer
};
private _usedBy = _container getVariable ["usedBy",objNull];

if (isNull _usedBy OR {_usedBy == player}) then {
	_container setVariable ["usedBy", player, true]
} else {
	_readonly = true
};

if (!isNull (uiNamespace getVariable ["InventoryDisplay",displayNull])) exitWith {};

if (isNull objectParent player) then {
	waitUntil {uiSleep 0.1; animationState player select [0,4] == "ainv"};
};

private _display = (findDisplay 46) createDisplay "RscDisplayEmpty";
uiNamespace setVariable ["InventoryDisplay", _display];
[_display] call client_inventory_initDisplay;
private _elementBackground = [0.15, 0.15, 0.15, 0.8];

private _containerBackground = _display ctrlCreate ["RscText", -1];
_containerBackground ctrlSetPosition [
	-2 * GUI_GRID_W,
	0,
	14 * GUI_GRID_W,
	22 * GUI_GRID_H
];
_containerBackground ctrlSetBackgroundColor _elementBackground;
_containerBackground ctrlSetFade 1;
_containerBackground ctrlCommit 0;

private _playerBackground = _display ctrlCreate ["RscText", -1];
_playerBackground ctrlSetPosition [
	12.5 * GUI_GRID_W,
	0,
	29 * GUI_GRID_W,
	22 * GUI_GRID_H
];
_playerBackground ctrlSetBackgroundColor _elementBackground;
_playerBackground ctrlSetFade 1;
_playerBackground ctrlCommit 0;

private _containerTitle = _display ctrlCreate ["RscStructuredText", -1];
_containerTitle ctrlSetPosition [
	-2 * GUI_GRID_W,
	0,
	14 * GUI_GRID_W,
	1 * GUI_GRID_H
];
_containerTitle ctrlSetBackgroundColor _elementBackground;
_containerTitle ctrlSetFade 1;
_containerTitle ctrlCommit 0;

private _playerTitle = _display ctrlCreate ["RscStructuredText", -1];
_playerTitle ctrlSetPosition [
	12.5 * GUI_GRID_W,
	0,
	29 * GUI_GRID_W,
	1 * GUI_GRID_H
];
_playerTitle ctrlSetBackgroundColor _elementBackground;
_playerTitle ctrlSetFade 1;
_playerTitle ctrlCommit 0;
_playerTitle ctrlSetStructuredText parseText format["<t align='center'>%1", (player getVariable ["realname", name player])];

// Контейнеры
private _groundContainerGroup = [_display, [
	-1.5 * GUI_GRID_W,
	1.3 * GUI_GRID_H,
	13 * GUI_GRID_W,
	20.4 * GUI_GRID_H
], 100] call client_inventory_createControlsGroup;

private _containerList = [_display, [
	0,
	0,
	13 * GUI_GRID_W,
	19 * GUI_GRID_H
], "DM_ListBoxDrag", _groundContainerGroup, true, 1001] call client_inventory_createControl;

private _containerLoad = [_display, [
	0,
	19.3 * GUI_GRID_H,
	13 * GUI_GRID_W,
	1 * GUI_GRID_H
], "RscStructuredText", _groundContainerGroup, false] call client_inventory_createControl;

_groundContainerGroup ctrlAddEventHandler ["LBDrop", client_inventory_lbDrop];
_containerList ctrlAddEventHandler ["LBDrag", client_inventory_lbDrag];
_containerList ctrlAddEventHandler ["LBDblClick", client_inventory_lbDblClick];
_containerList ctrlSetTooltipColorBox [0.6, 0.6, 0.6, 1];
_containerList ctrlSetTooltipColorShade [0.1, 0.1, 0.1, 0.9];
_groundContainerGroup setVariable ["weightCtrl", _containerLoad];
_groundContainerGroup setVariable ["containerObject", _container];
_display setVariable ["containerList", _containerList];

private _playerContainerGroup = [_display, [
	13 * GUI_GRID_W,
	4.6 * GUI_GRID_H,
	13 * GUI_GRID_W,
	17.1 * GUI_GRID_H
], 105] call client_inventory_createControlsGroup;

private _playerContainerList = [_display, [
	0,
	0,
	13 * GUI_GRID_W,
	15.8 * GUI_GRID_H
], "DM_ListBoxDrag", _playerContainerGroup, true, 1002] call client_inventory_createControl;

private _playerContainerLoad = [_display, [
	0,
	16.1 * GUI_GRID_H,
	13 * GUI_GRID_W,
	1 * GUI_GRID_H
], "RscStructuredText", _playerContainerGroup, false] call client_inventory_createControl;
_playerContainerGroup ctrlAddEventHandler ["LBDrop", client_inventory_lbDrop];
_playerContainerList ctrlAddEventHandler ["LBDrag", client_inventory_lbDrag];
_playerContainerList ctrlAddEventHandler ["LBDblClick", client_inventory_lbDblClick];
_playerContainerList ctrlSetTooltipColorBox [0.6, 0.6, 0.6, 1];
_playerContainerList ctrlSetTooltipColorShade [0.1, 0.1, 0.1, 0.9];
_playerContainerGroup setVariable ["weightCtrl", _playerContainerLoad];
_playerContainerGroup setVariable ["containerObject", backpackContainer player];
_display setVariable ["backList", _playerContainerList];

// Одежда игрока
private _uniformGroup = [_display, [
	13 * GUI_GRID_W,
	1.3 * GUI_GRID_H,
	13 * GUI_GRID_W,
	3 * GUI_GRID_H
], 106] call client_inventory_createControlsGroup;
_uniformGroup ctrlAddEventHandler ["LBDrop", client_inventory_lbDrop];
_uniformGroup setVariable ["containerObject", player];

private _playerUniform = [_display, [
	0,
	0,
	4 * GUI_GRID_W,
	3 * GUI_GRID_H	
], "RscPictureKeepAspect", _uniformGroup] call client_inventory_createControl;

private _playerVest = [_display, [
	4.5 * GUI_GRID_W,
	0,
	4 * GUI_GRID_W,
	3 * GUI_GRID_H
], "RscPictureKeepAspect", _uniformGroup] call client_inventory_createControl;

private _playerBack = [_display, [
	9 * GUI_GRID_W,
	0,
	4 * GUI_GRID_W,
	3 * GUI_GRID_H
], "RscPictureKeepAspect", _uniformGroup] call client_inventory_createControl;

// Экипировка игрока
private _equipmentGroup = [_display, [
	26.5 * GUI_GRID_W,
	1.3 * GUI_GRID_H,
	14.5 * GUI_GRID_W,
	5.3 * GUI_GRID_H
], 101] call client_inventory_createControlsGroup;
_equipmentGroup ctrlAddEventHandler ["LBDrop", client_inventory_lbDrop];
_equipmentGroup setVariable ["containerObject", player];

private _playerHeadgear = [_display, [
	0,
	0,
	3.5 * GUI_GRID_W,
	2.8 * GUI_GRID_H
], "RscPictureKeepAspect", _equipmentGroup] call client_inventory_createControl;

private _playerGoggles = [_display, [
	3.7 * GUI_GRID_W,
	0,
	3.5 * GUI_GRID_W,
	2.8 * GUI_GRID_H
], "RscPictureKeepAspect", _equipmentGroup] call client_inventory_createControl;

private _playerNvg = [_display, [
	7.4 * GUI_GRID_W,
	0,
	3.5 * GUI_GRID_W,
	2.8 * GUI_GRID_H
], "RscPictureKeepAspect", _equipmentGroup] call client_inventory_createControl;

private _playerBinocular = [_display, [
	11.1 * GUI_GRID_W,
	0,
	3.5 * GUI_GRID_W,
	2.8 * GUI_GRID_H
], "RscPictureKeepAspect", _equipmentGroup] call client_inventory_createControl;

private _playerMap = [_display, [
	0,
	3 * GUI_GRID_H,
	2.8 * GUI_GRID_W,
	2.3 * GUI_GRID_H
], "RscPictureKeepAspect", _equipmentGroup] call client_inventory_createControl;

private _playerGps = [_display, [
	3 * GUI_GRID_W,
	3 * GUI_GRID_H,
	2.8 * GUI_GRID_W,
	2.3 * GUI_GRID_H
], "RscPictureKeepAspect", _equipmentGroup] call client_inventory_createControl;

private _playerRadio = [_display, [
	5.9 * GUI_GRID_W,
	3 * GUI_GRID_H,
	2.8 * GUI_GRID_W,
	2.3 * GUI_GRID_H
], "RscPictureKeepAspect", _equipmentGroup] call client_inventory_createControl;

private _playerCompass = [_display, [
	8.9 * GUI_GRID_W,
	3 * GUI_GRID_H,
	2.8 * GUI_GRID_W,
	2.3 * GUI_GRID_H
], "RscPictureKeepAspect", _equipmentGroup] call client_inventory_createControl;

private _playerWatch = [_display, [
	11.8 * GUI_GRID_W,
	3 * GUI_GRID_H,
	2.8 * GUI_GRID_W,
	2.3 * GUI_GRID_H
], "RscPictureKeepAspect", _equipmentGroup] call client_inventory_createControl;
// Оружия
private _primaryWeaponGroup = [_display, [
	26.5 * GUI_GRID_W,
	7 * GUI_GRID_H,
	14.5 * GUI_GRID_W,
	4.6 * GUI_GRID_H
], 102] call client_inventory_createControlsGroup;
_primaryWeaponGroup ctrlAddEventHandler ["LBDrop", client_inventory_lbDrop];
_primaryWeaponGroup setVariable ["containerObject", player];

private _secondaryWeaponGroup = [_display, [
	26.5 * GUI_GRID_W,
	12 * GUI_GRID_H,
	14.5 * GUI_GRID_W,
	4.6 * GUI_GRID_H
], 103] call client_inventory_createControlsGroup;
_secondaryWeaponGroup ctrlAddEventHandler ["LBDrop", client_inventory_lbDrop];
_secondaryWeaponGroup setVariable ["containerObject", player];

private _handgunWeaponGroup = [_display, [
	26.5 * GUI_GRID_W,
	17 * GUI_GRID_H,
	14.5 * GUI_GRID_W,
	4.6 * GUI_GRID_H
], 104] call client_inventory_createControlsGroup;
_handgunWeaponGroup ctrlAddEventHandler ["LBDrop", client_inventory_lbDrop];
_handgunWeaponGroup setVariable ["containerObject", player];

private _primaryWeaponControls 		= [_display, _primaryWeaponGroup, 6] call client_inventory_initWeapon;
private _secondaryWeaponControls 	= [_display, _secondaryWeaponGroup, 5] call client_inventory_initWeapon;
private _handgunWeaponControls 		= [_display, _handgunWeaponGroup, 5] call client_inventory_initWeapon;

private _primaryPicture 	= _primaryWeaponControls 	# 0;
private _secondaryPicture 	= _secondaryWeaponControls 	# 0;
private _handgunPicture 	= _handgunWeaponControls 	# 0;

private _primaryMuzzle 		= _primaryWeaponControls 	# 1;
private _secondaryMuzzle 	= _secondaryWeaponControls 	# 1;
private _handgunMuzzle 		= _handgunWeaponControls 	# 1;

private _primaryBipod		= _primaryWeaponControls 	# 2;
private _secondaryBipod		= _secondaryWeaponControls 	# 2;
private _handgunBipod		= _handgunWeaponControls 	# 2;

private _primaryRail		= _primaryWeaponControls 	# 3;
private _secondaryRail		= _secondaryWeaponControls 	# 3;
private _handgunRail		= _handgunWeaponControls 	# 3;

private _primaryOptic		= _primaryWeaponControls 	# 4;
private _secondaryOptic		= _secondaryWeaponControls 	# 4;
private _handgunOptic		= _handgunWeaponControls 	# 4;

private _primarySecondMag	= _primaryWeaponControls 	# 5;

private _primaryMag			= _primaryWeaponControls 	# 6;
private _secondaryMag		= _secondaryWeaponControls 	# 5;
private _handgunMag			= _handgunWeaponControls 	# 5;

private _primaryMagAmmo		= _primaryWeaponControls 	# 7;
private _secondaryMagAmmo	= _secondaryWeaponControls 	# 6;
private _handgunMagAmmo		= _handgunWeaponControls 	# 6;

// Анимация появления контролов
{
	_x ctrlSetFade 0;
	_x ctrlCommit 0.2;
} foreach [
	_playerTitle,
	_containerTitle,
	_playerBackground,
	_containerBackground,
	_groundContainerGroup,
	_playerContainerGroup,
	_uniformGroup,
	_equipmentGroup,
	_primaryWeaponGroup,
	_secondaryWeaponGroup,
	_handgunWeaponGroup
];
// Устанавливаем тип слота для каждого элемента
_playerUniform		setVariable ["slotType", "Uniform"];
_playerVest			setVariable ["slotType", "Vest"];
_playerBack			setVariable ["slotType", "Backpack"];
_playerHeadgear		setVariable ["slotType", "Headgear"];
_playerGoggles		setVariable ["slotType", "Glasses"];
_playerNvg			setVariable ["slotType", "NVGoggles"];
_playerBinocular	setVariable ["slotType", "Binocular"];
_playerMap			setVariable ["slotType", "Map"];
_playerGps			setVariable ["slotType", "GPS"];
_playerRadio		setVariable ["slotType", "Radio"];
_playerCompass		setVariable ["slotType", "Compass"];
_playerWatch		setVariable ["slotType", "Watch"];

_primaryPicture		setVariable ["slotType", "Primary"];
_primaryMuzzle		setVariable ["slotType", "PrimaryMuzzle"];
_primaryRail		setVariable ["slotType", "PrimaryLaser"];
_primaryOptic		setVariable ["slotType", "PrimaryOptics"];
_primaryBipod		setVariable ["slotType", "PrimaryBipod"];
_primarySecondMag	setVariable ["slotType", "PrimaryGL"];
_primaryMag			setVariable ["slotType", "PrimaryMag"];

_secondaryPicture	setVariable ["slotType", "Secondary"];
_secondaryMuzzle	setVariable ["slotType", "SecondaryMuzzle"];
_secondaryRail		setVariable ["slotType", "SecondaryLaser"];
_secondaryOptic		setVariable ["slotType", "SecondaryOptics"];
_secondaryBipod		setVariable ["slotType", "SecondaryBipod"];
_secondaryMag		setVariable ["slotType", "SecondaryMag"];

_handgunPicture		setVariable ["slotType", "Handgun"];
_handgunMuzzle 		setVariable ["slotType", "HandgunMuzzle"];
_handgunRail		setVariable ["slotType", "HandgunLaser"];
_handgunOptic		setVariable ["slotType", "HandgunOptics"];
_handgunBipod		setVariable ["slotType", "HandgunBipod"];
_handgunMag			setVariable ["slotType", "HandgunMag"];

// Обрабатываем нажатие мышкой по элементу
{
	_x ctrlAddEventHandler ["MouseButtonDown", client_inventory_mouseButtonDown]
} forEach [
	_containerList,
	_playerContainerList,
	_playerUniform, _playerVest, _playerBack, _playerHeadgear, _playerGoggles, _playerNvg, _playerBinocular, _playerMap, _playerGps, _playerRadio, _playerCompass, _playerWatch,
	_primaryPicture, _primaryMuzzle, _primaryRail, _primaryOptic, _primaryBipod, _primarySecondMag, _primaryMag,
	_secondaryPicture, _secondaryMuzzle, _secondaryRail, _secondaryOptic, _secondaryBipod, _secondaryMag,
	_handgunPicture, _handgunMuzzle, _handgunRail, _handgunOptic, _handgunBipod, _handgunMag
];

private _readonlyCargo = [];
// Обновляем инвентарь пока существует наш дисплей
while {!isNull _display} do {
	_playerContainerGroup setVariable ["containerObject", backpackContainer player];
	[_container, _containerList] call client_inventory_updateContainerList;
	[backpackContainer player, _playerContainerList] call client_inventory_updateContainerList;

	private _loadout 				= getUnitLoadout player;
	
	private _primaryWeaponArray 	= _loadout # 0;
	private _secondaryWeaponArray 	= _loadout # 1;
	private _handgunWeaponArray 	= _loadout # 2;
	private _uniform 				= uniform player;
	private _vest 					= vest player;
	private _backpack 				= backpack player;
	private _backpackArray 			= _loadout # 5;
	private _headgear 				= headgear player;
	private _goggles 				= goggles player;
	private _binocular 				= binocular player;
	private _map					= _loadout # 9 # 0;
	private _gps					= _loadout # 9 # 1;
	private _radio 					= _loadout # 9 # 2;
	private _compass 				= _loadout # 9 # 3;
	private _watch 					= _loadout # 9 # 4;
	private _nvg					= _loadout # 9 # 5;
	
	// Устанавливаем картинки для существующих контролов
	// Player Equipment 
	[_playerHeadgear, 	_headgear, 	"CfgWeapons", "A3\ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_helmet_gs.paa"	] call client_inventory_setPicture;
	[_playerGoggles, 	_goggles, 	"CfgGlasses", "A3\ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_glasses_gs.paa"	] call client_inventory_setPicture;
	[_playerNvg, 		_nvg, 		"CfgWeapons", "A3\ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_nvg_gs.paa"		] call client_inventory_setPicture;
	[_playerBinocular,	_binocular, "CfgWeapons", "A3\ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_binocular_gs.paa"] call client_inventory_setPicture;
	[_playerMap, 		_map, 		"CfgWeapons", "A3\ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_map_gs.paa"		] call client_inventory_setPicture;
	[_playerGps, 		_gps, 		"CfgWeapons", "A3\ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_gps_gs.paa"		] call client_inventory_setPicture;
	[_playerRadio, 		_radio, 	"CfgWeapons", "A3\ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_radio_gs.paa"	] call client_inventory_setPicture;
	[_playerCompass, 	_compass, 	"CfgWeapons", "A3\ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_compass_gs.paa"	] call client_inventory_setPicture;
	[_playerWatch, 		_watch, 	"CfgWeapons", "A3\ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_watch_gs.paa"	] call client_inventory_setPicture;

	// Player Uniform
	[_playerUniform,	_uniform,	"CfgWeapons","A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_uniform_gs.paa"	] call client_inventory_setPicture;
	[_playerVest,		_vest,		"CfgWeapons","A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_vest_gs.paa"		] call client_inventory_setPicture;
	[_playerBack, 		_backpack,	"CfgVehicles","A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_backpack_gs.paa"	] call client_inventory_setPicture;
	
	// PrimaryWeapon
	_primaryWeaponArray params [
		["_weapon", ""],
		["_muzzle", ""],
		["_rail", ""],
		["_optic", ""],
		["_mag", []],
		["_secondMag", []],
		["_bipod", ""]
	];

	[_primaryPicture, 	_weapon, 	"CfgWeapons", "A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_primary_gs.paa"	] call client_inventory_setPicture;
	[_primaryMuzzle,	_muzzle,	"CfgWeapons", "A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_muzzle_gs.paa"	] call client_inventory_setPicture;
	[_primaryRail,		_rail,		"CfgWeapons", "A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_side_gs.paa"		] call client_inventory_setPicture;
	[_primaryOptic,		_optic,		"CfgWeapons", "A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_top_gs.paa"		] call client_inventory_setPicture;
	[_primaryBipod, 	_bipod, 	"CfgWeapons", "A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_bipod_gs.paa"	] call client_inventory_setPicture;
	if (_secondMag isEqualTo []) then {
		[_primarySecondMag, "", "CfgMagazines", "A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_magazineGL_gs.paa"] call client_inventory_setPicture
	} else {
		[_primarySecondMag, _secondMag # 0, "CfgMagazines", "A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_magazineGL_gs.paa", _secondMag # 1] call client_inventory_setPicture
	};
	if (_mag isEqualTo []) then {
		[_primaryMag, "", "CfgMagazines", "A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_magazine_gs.paa"] call client_inventory_setPicture;
	} else {
		[_primaryMag, _mag # 0, "CfgMagazines", "A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_magazine_gs.paa", _mag # 1] call client_inventory_setPicture;
	};

	// SecondaryWeapon
	_secondaryWeaponArray params [
		["_weapon", ""],
		["_muzzle", ""],
		["_rail", ""],
		["_optic", ""],
		["_mag", []],
		["_secondMag", []],
		["_bipod", ""]
	];

	[_secondaryPicture, _weapon, 	"CfgWeapons", "A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_secondary_gs.paa"] call client_inventory_setPicture;
	[_secondaryMuzzle,	_muzzle,	"CfgWeapons", "A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_muzzle_gs.paa"	] call client_inventory_setPicture;
	[_secondaryRail,	_rail,		"CfgWeapons", "A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_side_gs.paa"		] call client_inventory_setPicture;
	[_secondaryOptic,	_optic,		"CfgWeapons", "A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_top_gs.paa"		] call client_inventory_setPicture;
	[_secondaryBipod, 	_bipod, 	"CfgWeapons", "A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_bipod_gs.paa"	] call client_inventory_setPicture;
	if (_mag isEqualTo []) then {
		[_secondaryMag, "", "CfgMagazines", "A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_magazine_gs.paa"] call client_inventory_setPicture;
	} else {
		[_secondaryMag, _mag # 0, "CfgMagazines", "A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_magazine_gs.paa", _mag # 1] call client_inventory_setPicture;
	};
	
	// HandgunWeapon 
	_handgunWeaponArray params [
		["_weapon", ""],
		["_muzzle", ""],
		["_rail", ""],
		["_optic", ""],
		["_mag", []],
		["_secondMag", []],
		["_bipod", ""]
	];

	[_handgunPicture, 	_weapon, 	"CfgWeapons", "A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_hgun_gs.paa"		] call client_inventory_setPicture;
	[_handgunMuzzle,	_muzzle,	"CfgWeapons", "A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_muzzle_gs.paa"	] call client_inventory_setPicture;
	[_handgunRail,		_rail,		"CfgWeapons", "A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_side_gs.paa"		] call client_inventory_setPicture;
	[_handgunOptic,		_optic,		"CfgWeapons", "A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_top_gs.paa"		] call client_inventory_setPicture;
	[_handgunBipod, 	_bipod, 	"CfgWeapons", "A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_bipod_gs.paa"	] call client_inventory_setPicture;
	if (_mag isEqualTo []) then {
		[_handgunMag, "", "CfgMagazines", "A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_magazine_gs.paa"] call client_inventory_setPicture;
	} else {
		[_handgunMag, _mag # 0, "CfgMagazines", "A3\Ui_f\data\GUI\Rsc\RscDisplayGear\ui_gear_magazine_gs.paa", _mag # 1] call client_inventory_setPicture;
	};


	// Устанавливаем название контейнера
	_containerTitle ctrlSetStructuredText parseText ("<t align='center'>" + getText(
		([typeOf _container] call client_inventory_getConfigName) >> typeOf _container >> "displayName"
	));

	// Устанавливаем текст с патронами для каждого из оружий
	_primaryMagAmmo ctrlSetStructuredText parseText "";
	_secondaryMagAmmo ctrlSetStructuredText parseText "";
	_handgunMagAmmo ctrlSetStructuredText parseText "";

	if (primaryWeapon player != "") then {
		_ammo = player ammo primaryWeapon player;
		if (_ammo > 1) then {
			_primaryMagAmmo ctrlSetStructuredText parseText format["<t align='right'>%1", _ammo]
		};
	};
	if (secondaryWeapon player != "") then {
		_ammo = player ammo secondaryWeapon player;
		if (_ammo > 1) then {
			_secondaryMagAmmo ctrlSetStructuredText parseText format["<t align='right'>%1", _ammo]
		};
	};
	if (handgunWeapon player != "") then {
		_ammo = player ammo handgunWeapon player;
		if (_ammo > 1) then {
			_handgunMagAmmo ctrlSetStructuredText parseText format["<t align='right'>%1", _ammo]
		};
	};
	// Затемняем список контейнера если ReadOnly
	if (_readonly) then {
		if !([getWeaponCargo _container, getItemCargo _container, getMagazineCargo _container] isEqualTo _readonlyCargo) then {
			_readonlyCargo = [getWeaponCargo _container, getItemCargo _container, getMagazineCargo _container];
			[_container, _containerList] call client_inventory_updateContainerList;
		};
		_containerList ctrlSetFade 0.4;
		_containerList ctrlCommit 0;
	} else {
		_containerList ctrlSetFade 0;
		_containerList ctrlCommit 0;
	};

	// Ждём условий обновления инвентаря
	waitUntil {
		uiSleep 0.03;
		(
			isNull _display OR
			{(_playerContainerGroup getVariable ["containerObject",objNull]) != backpackContainer player} OR
			{!(getUnitLoadout player isEqualTo _loadout)} OR
			{_readonly}
		)
	};
};

private _usedBy = _container getVariable ["usedBy", objNull];
if (_usedBy isEqualTo player) then {
	_container setVariable ["usedBy", objNull, true];
};

// Удаляем пустой контейнер
if (typeOf _container in ["GroundWeaponHolder_Scripted", "GroundWeaponHolder", "isl_inventory_box"]) then {
	private _loot = (
		(getWeaponCargo _container) + 
		(getMagazineCargo _container) + 
		(getItemCargo _container) + 
		(getBackpackCargo _container)
	);
	
	_loot = _loot - [[]];
	if (_loot isEqualTo []) exitWith {
		_container call client_inventory_deleteContainer
	};
};