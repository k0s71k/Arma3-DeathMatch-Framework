#define GUI_GRID_H (0.04)
#define GUI_GRID_W (0.025)

disableSerialization;
// Создаем подготовленный слой худа
("DMHud" call BIS_fnc_rscLayer) cutRsc ["DMHud", "PLAIN", 1, false];

// Ждём создания слоя
waitUntil {
	uiSleep 0.3;
	!isNull (uiNamespace getVariable ["DMHud",displayNull])
};
private _layer = uiNamespace getVariable ["DMHud",displayNull];

private _controlGroup = _layer ctrlCreate ["RscControlsGroup", -1];
_controlGroup ctrlSetPosition [
	safeZoneX + 0.5 * GUI_GRID_W,
	safeZoneY + safeZoneH - 1.5 * GUI_GRID_H,
	15 * GUI_GRID_W,
	1 * GUI_GRID_H
];
_controlGroup ctrlCommit 0;
// Добавляем фон для прогресс бара
private _background = _layer ctrlCreate ["RscStructuredText", -1, _controlGroup];
_background ctrlSetPosition [
	0,
	0,
	15 * GUI_GRID_W,
	1 * GUI_GRID_H
];
_background ctrlSetBackgroundColor [0.1, 0.1, 0.1, 0.9];
_background ctrlCommit 0;

private _backgroundPos = ctrlPosition _background;

// Добавляем прогресс бар 
private _healthBar = _layer ctrlCreate ["RscStructuredText", -1, _controlGroup];
_healthBar ctrlSetPosition [
	0.35 * GUI_GRID_W,
	((_backgroundPos # 3) / 2) - 0.15 * GUI_GRID_H,
	14.3 * GUI_GRID_W,
	0.3 * GUI_GRID_H 
];
_healthBar ctrlSetBackgroundColor [0.9, 0.9, 0.9, 0.8];
_healthBar ctrlCommit 0;

// Цикл обновления худа
_healthBar spawn {
	private _control = _this;
	private _controlPos = ctrlPosition _control;
	private _maxWidth = _controlPos # 2;

	while {!isNull (ctrlParent _control)} do {
		_control ctrlSetPositionW (_maxWidth * (1 - damage player));
		_control ctrlCommit 0.2;
		uiSleep 0.2;
	};
};

/* 			OPEN BETA			 */

private _betaTestText = _layer ctrlCreate ["RscStructuredText", -1];
_betaTestText ctrlSetPosition [
	safeZoneX,
	safeZoneY - 2 * GUI_GRID_H,
	safeZoneW,
	1.5 * GUI_GRID_H
];
_betaTestText ctrlSetStructuredText parseText "<t align='center' size='1.5' font='RobotoCondensedBold'>OPEN BETA";
_betaTestText ctrlCommit 0;