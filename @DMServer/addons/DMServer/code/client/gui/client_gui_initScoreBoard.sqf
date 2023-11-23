#define GUI_GRID_W    (0.025)
#define GUI_GRID_H    (0.04)

disableSerialization;
// Создаем новый слой
("DMScore" call BIS_fnc_rscLayer) cutRsc ["DMScore", "PLAIN", 1, false];

// Ждём создания слоя
waitUntil {
	uiSleep 0.3;
	!isNull (uiNamespace getVariable ["DMScore",displayNull])
};
private _display                = uiNamespace getVariable ["DMScore", displayNull];
// Создаем группу элементов
private _scoreControlGroup      = _display ctrlCreate ["RscControlsGroupNoScrollBars", -1];
_scoreControlGroup ctrlSetPosition [
    0,
    0,
    40 * GUI_GRID_W,
    25 * GUI_GRID_H
];
_scoreControlGroup ctrlCommit 0;
// Создаем нужные элементы
private _background             = _display ctrlCreate ["RscText",       -1, _scoreControlGroup];
private _title                  = _display ctrlCreate ["RscText",       -1, _scoreControlGroup];
private _playersListBackground  = _display ctrlCreate ["RscText",       -1, _scoreControlGroup];
private _playersList            = _display ctrlCreate ["RscListNBox",   -1, _scoreControlGroup];
// Записываем controlsGroup в переменную для дальнейших действий с ним
uiNamespace setVariable ["DM_ScoreGroup", _scoreControlGroup];
// Устанавливаем позиции
_background ctrlSetPosition [
    0,
    0,
    40 * GUI_GRID_W,
    25 * GUI_GRID_H
];
_title ctrlSetPosition [
    0,
    0,
    40 * GUI_GRID_W,
    1 * GUI_GRID_H
];
_playersListBackground ctrlSetPosition [
    0.5 * GUI_GRID_W,
    1.3 * GUI_GRID_H,
    39 * GUI_GRID_W,
    23.4 * GUI_GRID_H
];
_playersList ctrlSetPosition [
    0.5 * GUI_GRID_W,
    1.3 * GUI_GRID_H,
    39 * GUI_GRID_W,
    23.4 * GUI_GRID_H
];
// Применяем анимацию
_background             ctrlCommit 0;
_title                  ctrlCommit 0;
_playersListBackground  ctrlCommit 0;
_playersList            ctrlCommit 0;
// Устанавливаем цвет для каждого контрола
_background             ctrlSetBackgroundColor [0.1, 0.1, 0.1, 0.85];
_title                  ctrlSetBackgroundColor [0.15, 0.15, 0.15, 0.8];
_playersListBackground  ctrlSetBackgroundColor [0.15, 0.15, 0.15, 0.8];
// Устанавливаем текст для тайтла
_title ctrlSetText "Таблица игроков";
{
	_x ctrlShow true;
} foreach [_scoreControlGroup, _background, _title, _playersListBackground, _playersList];
// Добавляем столбцы для значений
private _nameColumn     = _playersList lnbAddColumn 0;
private _locationColumn = _playersList lnbAddColumn 0.5;
private _killsColumn    = _playersList lnbAddColumn 0.8;
private _deathsColumn   = _playersList lnbAddColumn 0.9;

_scoreControlGroup ctrlSetFade 1;
_scoreControlGroup ctrlCommit 0;
// Постоянный цикл обновления таблицы
while {!isNull _display} do {
    // Перед обновлением ждём когда будет видна таблица
    waitUntil {
        uiSleep 0.3;
        (ctrlFade _scoreControlGroup != 1) OR 
		{isNull _display}
    };
	// Очищаем таблицу от предыдущих значений
    lnbClear _playersList;
	// Добавляем первую строку
	private _infoRow                = [];
	_infoRow set[_nameColumn,       "Имя игрока: "];
	_infoRow set[_locationColumn,   "Текущая локация:"];
	_infoRow set[_killsColumn,      "Убил: "];
	_infoRow set[_deathsColumn,     "Умер: "];

	_playersList lnbAddRow          _infoRow;
	_playersList lnbSetValue        [[0, _killsColumn], 99999];
	_playersList lnbSetCurSelRow    0;
	// Перебираем всех игроков
    {
        private _row                = [];
        private _name               = name _x;
        // Жёлтый цвет текста если текущий элемент - игрок
        private _textColor          = [[0.9, 0.9, 0.9, 0.95], [0.6, 0.6, 0.2, 0.9]] select (_name == name player);
        // Берем значения с игрока
        private _kills              = str(_x getVariable ["DM_Kills", 0]);
        private _deaths             = str(_x getVariable ["DM_Deaths", 0]);
        private _location           = _x getVariable ["DM_CurrentLocation", "MainBase"];
        // Устанавливаем значения для новой строки
        _row set[_nameColumn,       _name];
        _row set[_locationColumn,   _location];
        _row set[_killsColumn,      _kills];
        _row set[_deathsColumn,     _deaths];
        // Добавляем получившуюся строку
        _playersList lnbAddRow      _row;
        // Устанавливаем цвет текста
        _playersList lnbSetColor    [[_forEachIndex + 1, _nameColumn],     _textColor];
        _playersList lnbSetColor    [[_forEachIndex + 1, _locationColumn], _textColor];
        _playersList lnbSetColor    [[_forEachIndex + 1, _killsColumn],    [0.2, 0.6, 0.2, 0.95]];
        _playersList lnbSetColor    [[_forEachIndex + 1, _deathsColumn],   [0.6, 0.2, 0.2, 0.95]];
        // Устанавливаем значение киллов для дальнейшей сортировки
        _playersList lnbSetValue    [[_forEachIndex + 1, _killsColumn],    parseNumber _kills];
    } foreach (playableUnits select {!isNull _x});
    // Сортируем по значению
    _playersList lnbSortByValue     [_killsColumn, true];
};