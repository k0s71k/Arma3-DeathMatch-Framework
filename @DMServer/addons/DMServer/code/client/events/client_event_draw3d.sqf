// Берем всех людей в радиусе 15 метров
private _units = nearestObjects [player, ["Man"], 16];
_units = _units - [player];

// Создаем DrawIcon3D для каждого человека
{
	if !(isPlayer AND {!(lineIntersects [eyePos player, eyePos _x, player, _x])}) then {continue};

	private _name = [name _x, format["- %1 -", name _x]] select (_x getVariable ["tf_isSpeaking", false]);
	private _dist = (player distance _x) / 15;
	private _color = [0.9, 0.9, 0.9, 1 - _dist];
	private _pos = ASLToAGL (getPosASL _x);
	// Устанавливаем высоту в зависимости от дистанции до игрока
	_pos set [2, _pos # 2 + ((_x selectionPosition ['Head', "HitPoints"]) # 2) + 0.2 + (0.6 * _dist)];
	drawIcon3D ["", _color, _pos, 1, 1, 0, _name, 2, 0.9 * GUI_GRID_H, "RobotoCondensedBold", "center"];
} forEach _units;