#define GUI_GRID_W    (0.025)
#define GUI_GRID_H    (0.04)

private _pushHint = {
    private _positionY                  = safeZoneY + 4.5 * GUI_GRID_H;
    {
        private _control                = _x # 0;
        private _controlPosition        = ctrlPosition _control;
        private _status                 = 0;
        private _statusChangeAt         = (_x # 2) max (diag_tickTime + 2);

        // Выставляем Y позицию в зависимости от высоты контрола
        if (_foreachIndex == 0) then {
            _control ctrlSetPositionX   (safeZoneX + safeZoneW - 15.75 * GUI_GRID_W), // Нужное положение хинта
            _control ctrlSetFade        0;
        };
        // Убираем контрол если он 3 и более по счету
        if (_forEachIndex > 2) then {
            _control ctrlSetFade        1;
            _status                     = 1;
            _statusChangeAt             = diag_tickTime + 2;
        };
        // Выставляем новую позицию для контрола
        _control ctrlSetPositionY       _positionY;
        // Добавляем анимацию
        _control ctrlCommit             0.25;
        _positionY                      = _positionY + (_controlPosition # 3) + (0.2 * GUI_GRID_H);
        // Сохраняем полученные параметры
        DM_hintData set [_forEachIndex, [_control, _status, _statusChangeAt]];
    } foreach DM_hintData;
};

params [
    ["_text",   "TestMessage",  [""]],
    ["_type",   "info",         [""]]
];

private _color = switch (_type) do {
    case "info"         : {[0.514,  0.518,  0.541,  0.75]};
	case "warning"      : {[0.98,   0.604,  0,      0.75]};
	case "news"         : {[0.369,  0.969,  0.941,  0.75]};
	case "done"         : {[0.584,  0.871,  0.384,  0.75]};
	case "error"        : {[0.678,  0.102,  0.102,  0.75]};
	case "money"        : {[0.969,  0.949,  0.369,  0.75]};
	case "police"       : {[0.173,  0.306,  0.961,  0.75]};
};
// Используем существующий слой худа для оповещений
private _layer          = uiNameSpace getVariable ["DMHud", displayNull];
// Создаем необходимые элементы управления
private _controlGroup 	= _layer ctrlCreate ["RscControlsGroupNoScrollbars", -1];
private _background 	= _layer ctrlCreate ["RscText", -1, _controlGroup];
private _stripe 		= _layer ctrlCreate ["RscText", -1, _controlGroup];
private _textControl 	= _layer ctrlCreate ["RscStructuredText", -1, _controlGroup];
// Сначала работаем с текстом, чтобы потом выровнять остальное под него
_textControl ctrlSetPosition [
    0.3 * GUI_GRID_W,
    0.3 * GUI_GRID_H,
    14.2 * GUI_GRID_W,
    0
];
_textControl    ctrlCommit 0;
_textControl    ctrlSetStructuredText parseText format ["<t align='center' font='RobotoCondensedBold'>%1</t>", _text];
_textControl    ctrlSetPositionH (ctrlTextHeight _textControl);
_textControl    ctrlCommit 0;
// Определяем высоту группы элементов
private _groupHeight    = (ctrlTextHeight _textControl) + 0.6 * GUI_GRID_H;
// Выставляем остальные позиции
_controlGroup ctrlSetPosition [
    safeZoneX + safeZoneW + 15 * GUI_GRID_W, // Начальное положение за пределами экрана
    safeZoneY + 4.7 * GUI_GRID_H,
    15 * GUI_GRID_W,
    _groupHeight
];
_background ctrlSetPosition [
    0,
    0,
    15 * GUI_GRID_W,
    _groupHeight
];
_stripe ctrlSetPosition [
    14.7 * GUI_GRID_W,
    0,
    0.3 * GUI_GRID_W,
    _groupHeight
];
// Применяем анимацию для всех элементов
_controlGroup   ctrlCommit 0;
_background     ctrlCommit 0;
_stripe         ctrlCommit 0;
_textControl    ctrlCommit 0;
// Задаем цвета
_stripe         ctrlSetBackgroundColor _color;
_background     ctrlSetBackgroundColor [0.1, 0.1, 0.1, 0.85];
// Делаем группу прозрачной
_controlGroup   ctrlSetFade 1;
_controlGroup   ctrlCommit 0;
// Добавляем полученные элементы в существующий массив уведомлений 
reverse DM_HintData;
DM_HintData pushBack [_controlGroup, 0, diag_tickTime + 20];
reverse DM_HintData;
playsound "HintExpand";

call _pushHint;