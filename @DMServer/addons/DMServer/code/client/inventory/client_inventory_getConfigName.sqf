private _class = param[0, "", [""]];

private _configs = [
	(configFile >> "CfgMagazines"),
	(configFile >> "CfgWeapons"),
	(configFile >> "CfgVehicles"),
	(configFile >> "CfgGlasses")
];
// Возвращаем нужный конфиг
_configs # (_configs findIf {isClass (_x >> _class)});