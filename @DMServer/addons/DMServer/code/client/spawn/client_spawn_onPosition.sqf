params [
	["_positionArray", [[0, 0, 0], 200, 0], [[]]],
	["_locationName", "", [""]]
];

if ((player getVariable ["DM_CurrentLocation", ""]) == _locationName) exitWith {["Нельзя телепортироваться в текущую локацию", "warning"] call client_gui_hint};

// Разбиваем полученный массив на переменные
_positionArray params [
	"_position",
	"_size",
	"_angle"
];
// Определяем рандомное направление от центральной точки
private _direction	= random 360;
// Определяем рандомную дистанцию от центральной точки
private _distance	= random (_size * 0.5);
private _newPosition = [
	(_position # 0) + (sin _direction * _distance),
	(_position # 1) + (cos _direction * _distance),
	random 1
];
// Устанавливаем новую позицию
player setPosATL	_newPosition;
// Устанавливаем переменную новой локации
player setVariable	["DM_CurrentLocation", _locationName, true];

waitUntil {
	uiSleep 1;
	!((position player) inArea [_position, _size, _size, _angle, false]) OR
	//(player distance2D _position > _radius) OR
	{call client_utils_inSafeZone}
};

// Выходим из скрипта если на основной базе или в другой локации
if ((player getVariable ["DM_CurrentLocation", ""]) != _locationName) exitWith {};
if (call client_utils_inSafeZone) exitWith {};

// Обрабатываем выход из зоны локации
["Вы вышли за пределы игровой зоны и были телепортированы на основную базу", "warning"] call client_gui_hint;
[] spawn client_spawn_onBase