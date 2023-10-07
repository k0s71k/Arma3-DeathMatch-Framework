// Параметры текущей карты
private _worldCenter = getArray (
	configFile >> "CfgWorlds" >> worldName >> "centerPosition"
);
private _worldRadius = 	worldSize / 2;

private _locations = [];
{
	private _size = size _x;
	private _averageSize = ((_size # 0) + (_size # 1)) / 2;
	_locations pushBack [locationPosition _x, text _x, _averageSize, direction _x]
} foreach (nearestLocations [_worldCenter, ["NameCity"/*, "NameCityCapital"*/], _worldRadius]); // Все города на карте

// Публичная переменная, доступная любому клиенту
missionNamespace setVariable ["DM_Locations", _locations, true];

// Создаем маркеры для каждой локации
{
	private _locationPosition = _x # 0;

	private _markerEllipse = createMarker [format ["dm_location_ellipse_%1", _forEachIndex], _locationPosition];
	_markerEllipse setMarkerShape "ELLIPSE";
	_markerEllipse setMarkerSize [_x # 2, _x # 2];
	_markerEllipse setMarkerDir (_x # 3);
	_markerEllipse setMarkerColor "ColorBlack";
	_markerEllipse setMarkerBrush "Solid";
	_markerEllipse setMarkerAlpha 0.7;
} foreach _locations;

DM_activeLocations = [];

private _waitLocationEmpty = {
	private _locationArray = param[0, [[0,0,0], "", 0, 0], [[]]];
	_locationArray params [
		"_position",
		"_name",
		"_size",
		"_angle"
	];
	private _index = DM_Locations findIf {_x isEqualTo _locationArray};

	private _markerEllipse = format["dm_location_ellipse_%1", _index];
	// Красный цвет для активного маркера
	_markerEllipse setMarkerColor "ColorOPFOR";

	// Ждём пока в кругу никого не останется
	waitUntil {
		uiSleep 0.5;
		({
			(position _x) inArea [_position, _size, _size, _angle, false]
		} count playableUnits) == 0
	};

	_markerEllipse setMarkerColor "ColorBlack";
	DM_activeLocations deleteAt (DM_activeLocations findIf {_x isEqualTo _locationArray});
};

// Запускаем цикл проверки нахождения людей в 
for "_i" from 0 to 1 step 0 do {
	{
		private _position = _x # 0;
		private _size = _x # 2;
		private _angle = _x # 3;
		// Пропускаем итерацию если в кругу никого нет
		if (
			({
				(position _x) inArea [_position, _size, _size, _angle, false]
			} count playableUnits) == 0
		) then {continue};
		// Пропускаем итерацию если локация уже активна
		if (_x in DM_activeLocations) then {continue};

		DM_activeLocations pushBack _x;
		[_x] spawn _waitLocationEmpty;
	} foreach _locations;
	uiSleep 0.5;
};