params [
	"_unit",
	"_selection",
	"_damage",
	"_shooter",
	"_projectile",
	"_hitPointIndex",
	"_instigator"
];
// Не считаем урон от боевой техники, если игрок пехотинец
_shooter = [_shooter, _instigator] select (!isNull _instigator);

if (
	((driver _shooter)	getVariable ["DM_WarVehicleMode", false]) AND	// Убийца в боевом режиме
	{!(player			getVariable ["DM_WarVehicleMode", false])}		// Игрок не в боевом режиме
) then {
	[] remoteExec		["client_vehicle_punishment", crew vehicle _shooter];
	player setVelocity	[0, 0, 0];
	_damage				= 0
};
// Не считаем урон на спавнах
if (call client_utils_inSafeZone OR 
	{missionNamespace	getVariable ["DM_Killed", false]}) then {_damage = 0};

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
		[player, DM_LastHitFrom] remoteExec ["client_gui_killFeed", -2];
		// Сообщаем стрелку об убийстве
		[format["Вы убили %1", name player], "done"] remoteExecCall ["client_gui_hint", DM_LastHitFrom];
		// Получаем сообщение о том, кто убил
		[format["Вас убил %1", name DM_LastHitFrom], "warning"] call client_gui_hint;
		DM_LastHitFrom	= nil;
	};
	_damage	= 0
};

_damage