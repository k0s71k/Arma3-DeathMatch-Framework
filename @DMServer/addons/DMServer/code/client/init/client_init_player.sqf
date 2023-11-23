// Ожидаем готовности игрока
waitUntil {uiSleep 0.3; !isNull player AND {player == player}};
// Ожидаем появления игрового дисплея
waitUntil {uiSleep 0.3; !isNull (findDisplay 46)};

// Второстепенные настройки
disableRemoteSensors	true;
enableSaving			[false, false];
showChat				false;
enableEnvironment		false;
enableRadio				false;
enableSentences			false;

// Убираем стандартную отрисовку карты
((findDisplay 12) displayCtrl 51) ctrlRemoveAllEventHandlers "draw";
// Затемняем экран
cutText ["Настройка клиента...", "BLACK FADED", 999, true];
// Убираем траву
setTerrainGrid 50;
// CBA Эксплойты
[] spawn client_init_anticheat;
// Обработчики событий
[] call client_init_events;
// Инит переменных
[] call client_init_variables;
// Светлая ночь
[] call client_init_moon;
// Худ игрока
[] spawn client_init_hud;
// Цикл проверки уведомлений
[] spawn client_gui_hintThread;
// Инит таблицы игроков
[] spawn client_gui_initScoreBoard;

// Ждём готовности сервера
waitUntil {uiSleep 0.3; missionNamespace getVariable ["server_isReady", false]};

// Ставим игрока на начальную позицию
player setPosATL		getArray(missionConfigFile >> "DMCfgSpawn" >> "DefaultBase" >> "spawnPos");
player enableFatigue	false;
player addRating		99999999;

uiSleep 1;
// Убираем затемнение
cutText ["", "BLACK IN", 1, true];

// Бисовский текст миссии 
[ 
	[ 
		["DeathMatch Server V1.0","align='center' size='0.8' font='RobotoCondensedBold'"], 
		["", "<br/>"], 
		["by Island Project", "align='center' size='0.5' font='RobotoCondensedBold'", "#CCCCCC"] 
	],
	safeZoneX,
	safeZoneY + 0.1 * safeZoneH 
] spawn BIS_fnc_typeText2;

uiSleep 10;

// Начальное управление
[
	"Добро пожаловать на сервер.
	<br/><br/>Управление:
	<br/><t align='left'>Выбор снаряжения <t color='#f5be00'>'F1'</t>
	<br/>Выбор точки появления <t color='#f5be00'>'F2'</t>
	<br/>Приглушить звук <t color='#f5be00'>'Shift + End'</t>
	<br/>Прыжок <t color='#f5be00'>'Shift + Space'</t>
	<br/>Вылечиться <t color='#f5be00'>'H'</t>
	<br/>Таблица игроков <t color='#f5be00'>'Tab'</t>
	<br/>Дальность прорисовки <t color='#f5be00'>'+ / -'</t>",
"info"] call client_gui_hint;