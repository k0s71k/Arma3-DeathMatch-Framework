#define GUI_GRID_W    (0.025)
#define GUI_GRID_H    (0.04)

// Функция, сдвигающая остальные оповещения вниз
private _pushKill = {
	private _startPosition			= safeZoneY + 0.5 * GUI_GRID_H;
	{
		private	_control			= _x;
		private	_controlPosition	= ctrlPosition _control;
		_control ctrlSetFade 0;
		_control ctrlSetPositionY	_startPosition;
		_control ctrlCommit 0.25;
		_startPosition				= _startPosition + (_controlPosition # 3) + 0.3 * GUI_GRID_H;
	} foreach DM_killFeed;
};

params [
	["_unit",		objNull,	[objNull]],
	["_shooter",	objNull,	[objNull]]
];

private _shooterWeapon	= [vehicle _shooter, currentWeapon _shooter] select (isPlayer _shooter);
private _weaponPicture	= [
	getText(configFile >> "CfgVehicles" >> _shooterWeapon >> "picture"),
	getText(configFile >> "CfgWeapons" >> _shooterWeapon >> "picture")
] select (isPlayer _shooter);

if (!isPlayer _shooter) then {
	_shooter = driver _shooter
};

private "_backgroundColor";
switch (player) do {
	case _unit : {
		player setVariable	["DM_Deaths", (player getVariable ["DM_Deaths", 0]) + 1, true];
		_backgroundColor	= [0.28, 0.19, 0.19, 0.9]
	};
	case _shooter : {
		player setVariable	["DM_Kills", (player getVariable ["DM_Kills", 0]) + 1, true];
		_backgroundColor	= [0.22, 0.28, 0.19, 0.9]
	};
	default {
		_backgroundColor	= [0.1, 0.1, 0.1, 0.55]
	};
};

// Используем слой основного худа
private _layer			= uiNamespace getVariable ["DMHud", displayNull];
private _textControl	= _layer ctrlCreate ["RscStructuredText", -1];
_textControl ctrlSetPosition [
	safeZoneX + 0.5 * GUI_GRID_W,
	safeZoneY + 0.5 * GUI_GRID_H,
	0,
	1 * GUI_GRID_H
];
_textControl ctrlSetBackgroundColor _backgroundColor;
_textControl ctrlSetFade 1;
_textControl ctrlCommit 0;
_textControl ctrlSetStructuredText parseText format[
	"<t align='center'>%1 <img image='%2'/> %3",
	name _unit,
	_weaponPicture,
	name _shooter
];
// Устанавливаем ширину в зависимости от длины текста
_textControl ctrlSetPositionW ((ctrlTextWidth _textControl) + 2 * GUI_GRID_W);
_textControl ctrlCommit 0;

// Добавляем новый контрол в начало массива
reverse DM_killFeed;
DM_killFeed pushBack _textControl;
reverse DM_killFeed;

// Сдвигаем остальные киллы
call _pushKill;
// Ожидаем 10 секунд перед удалением контрола
_textControl spawn {
	private _control	= _this;
	private _position	= ctrlPosition _control;
	uiSleep	10;
	_control ctrlSetFade 1;
	_control ctrlCommit 0.25;
	uiSleep 0.5;
	DM_killFeed deleteAt (DM_killFeed findIf {_x isEqualTo _control});
	ctrlDelete _control;
};

