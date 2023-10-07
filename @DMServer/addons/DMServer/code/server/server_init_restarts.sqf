diag_log "DMServer >> Restart Init Enabled";

// Функция для оповещения игроков
private _notificationForPlayers = {
	params ["_minutes"];
	[format["До рестарта сервера %1 минут", _minutes], "info"] remoteExecCall ["client_gui_hint", -2];
};

// Ждём 30 минут до первого оповещения
sleep 30 * 60;
// Оповещаем людей за 30, 15 и 5 минут до рестарта
[30] call _notificationForPlayers;
sleep 15 * 60;
[15] call _notificationForPlayers;
sleep 10 * 60;
[5] call _notificationForPlayers;
sleep 5 * 60;

// Кикаем всех игроков, оставшихся на сервере
{
	"2609" serverCommand format ["#kick %1", getPlayerUID _x]
} foreach playableUnits;

// Выключаем сервер
sleep 5;
"2609" serverCommand "#shutdown";