if (!isNull objectParent player) exitWith {objectParent player};
private _nearestContainers = nearestObjects [getPosATL player, [
	"isl_inventory_box", "GroundWeaponHolder",
	"GroundWeaponHolder_scripted",
	"LandVehicle", "Air", "Boat"
], 5];
if (count _nearestContainers > 0) exitWith {_nearestContainers # 0};
// Создаем новый контейнер если рядом ничего нет
private _container	= createVehicle ["isl_inventory_box", [0, 0, 300], [], 0.5, "CAN_COLLIDE"];
_container			setPosATL (getPosATL player);
_container