(("true" configClasses (missionConfigFile >> "DMCfgSpawn")) findIf {
	player distance2D getArray(_x >> "spawnPos") < getNumber(_x >> "radius")
}) != -1