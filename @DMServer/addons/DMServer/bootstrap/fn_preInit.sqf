#define CLIENT true
#define SERVER false

private _scriptHeader = '
	private _fnc_scriptNameParent = if (isNil "_fnc_scriptName") then {"%1"} else {_fnc_scriptName};
	private _fnc_scriptName = "%1";
	scriptName _fnc_scriptName;
';

{
	private _debugMode = serverName == "[RU] RDM Server Test";
	private _scriptName = _x # 0;
	private _codeString = format[_scriptHeader, _scriptName] + preprocessFileLineNumbers (_x # 1);
	private _code = if (_debugMode) then {
		compile _codeString
	} else {
		compileFinal _codeString
	};
	missionNamespace setVariable [_scriptName, _code, _x # 2];
} forEach [
	// Серверные скрипты
	// Основной инит сервера
	["server_init_main", 						"DMServer\code\server\server_init_main.sqf", 								SERVER],
	["server_init_locations", 					"DMServer\code\server\server_init_locations.sqf", 							SERVER],
	["server_init_restarts", 					"DMServer\code\server\server_init_restarts.sqf", 							SERVER],
	// Серверные события
	["server_event_clientDisconnect", 			"DMServer\code\server\server_event_clientDisconnect.sqf", 					SERVER],
	// Серверные системы
	["server_system_ban", 						"DMServer\code\server\server_system_ban.sqf", 								SERVER],
	// Спавн транспорта
	["server_spawn_vehicle", 					"DMServer\code\server\server_spawn_vehicle.sqf",							SERVER],
	// Клиентские скрипты
	// Основной инит клиента
	["client_init_player", 						"DMServer\code\client\init\client_init_player.sqf", 						CLIENT],
	["client_init_events", 						"DMServer\code\client\init\client_init_events.sqf", 						CLIENT],
	["client_init_variables",					"DMServer\code\client\init\client_init_variables.sqf",						CLIENT],
	["client_init_hud", 						"DMServer\code\client\init\client_init_hud.sqf", 							CLIENT],
	["client_init_moon", 						"DMServer\code\client\init\client_init_moon.sqf", 							CLIENT],
	["client_init_anticheat", 					"DMServer\code\client\init\client_init_anticheat.sqf", 						CLIENT],
	// События
	["client_event_adminBinds",					"DMServer\code\client\events\client_event_adminBinds.sqf", 					CLIENT],
	["client_event_draw3D",						"DMServer\code\client\events\client_event_draw3D.sqf", 						CLIENT],
	["client_event_inventoryOpened",			"DMServer\code\client\events\client_event_inventoryOpened.sqf", 			CLIENT],
	["client_event_keyBinds",					"DMServer\code\client\events\client_event_keyBinds.sqf", 					CLIENT],
	["client_event_onDamage",					"DMServer\code\client\events\client_event_onDamage.sqf", 					CLIENT],
	// Скрипты спавна
	["client_spawn_onBase", 					"DMServer\code\client\spawn\client_spawn_onBase.sqf",						CLIENT],
	["client_spawn_onPosition", 				"DMServer\code\client\spawn\client_spawn_onPosition.sqf",					CLIENT],
	["client_spawn_vehicleWar", 				"DMServer\code\client\spawn\client_spawn_vehicleWar.sqf",					CLIENT],
	["client_spawn_chooseCity", 				"DMServer\code\client\spawn\client_spawn_chooseCity.sqf",					CLIENT],
	// Вспомогательные скрипты
	["client_utils_changeViewDistance",			"DMServer\code\client\utils\client_utils_changeViewDistance.sqf",			CLIENT],
	["client_utils_inSafeZone", 				"DMServer\code\client\utils\client_utils_inSafeZone.sqf", 					CLIENT],
	["client_utils_healMe", 					"DMServer\code\client\utils\client_utils_healMe.sqf", 						CLIENT],
	// Скрипты действий
	["client_actions_jump",						"DMServer\code\client\client_actions_jump.sqf", 							CLIENT],
	// Уведомления
	["client_gui_hint", 						"DMServer\code\client\gui\client_gui_hint.sqf", 							CLIENT],
	["client_gui_hintThread", 					"DMServer\code\client\gui\client_gui_hintThread.sqf", 						CLIENT],
	["client_gui_unloadDisplay",				"DMServer\code\client\gui\client_gui_unloadDisplay.sqf", 					CLIENT],
	["client_gui_initScoreBoard", 				"DMServer\code\client\gui\client_gui_initScoreBoard.sqf", 					CLIENT],
	["client_gui_killFeed", 					"DMServer\code\client\gui\client_gui_killFeed.sqf", 						CLIENT],
	// Боевая техника
	["client_vehicle_warChoose", 				"DMServer\code\client\client_vehicle_warChoose.sqf", 						CLIENT],
	["client_vehicle_punishment", 				"DMServer\code\client\client_vehicle_punishment.sqf", 						CLIENT],
	// Инвентарь
	["client_inventory_canOperate", 			"DMServer\code\client\inventory\client_inventory_canOperate.sqf", 			CLIENT],
	["client_inventory_createContainer", 		"DMServer\code\client\inventory\client_inventory_createContainer.sqf",		CLIENT],
	["client_inventory_createControl", 			"DMServer\code\client\inventory\client_inventory_createControl.sqf",		CLIENT],
	["client_inventory_createControlsGroup", 	"DMServer\code\client\inventory\client_inventory_createControlsGroup.sqf",	CLIENT],
	["client_inventory_deleteContainer", 		"DMServer\code\client\inventory\client_inventory_deleteContainer.sqf",		CLIENT],
	["client_inventory_findCompatibles", 		"DMServer\code\client\inventory\client_inventory_findCompatibles.sqf",		CLIENT],
	["client_inventory_getConfigName", 			"DMServer\code\client\inventory\client_inventory_getConfigName.sqf",		CLIENT],
	["client_inventory_initWeapon", 			"DMServer\code\client\inventory\client_inventory_initWeapon.sqf",			CLIENT],
	["client_inventory_initDisplay", 			"DMServer\code\client\inventory\client_inventory_initDisplay.sqf", 			CLIENT],
	["client_inventory_lbDblClick", 			"DMServer\code\client\inventory\client_inventory_lbDblClick.sqf",			CLIENT],
	["client_inventory_lbDrag", 				"DMServer\code\client\inventory\client_inventory_lbDrag.sqf",				CLIENT],
	["client_inventory_lbDrop", 				"DMServer\code\client\inventory\client_inventory_lbDrop.sqf",				CLIENT],
	["client_inventory_makeContext", 			"DMServer\code\client\inventory\client_inventory_makeContext.sqf",			CLIENT],
	["client_inventory_message", 				"DMServer\code\client\inventory\client_inventory_message.sqf",				CLIENT],
	["client_inventory_moveItem", 				"DMServer\code\client\inventory\client_inventory_moveItem.sqf",				CLIENT],
	["client_inventory_mouseButtonDown", 		"DMServer\code\client\inventory\client_inventory_mouseButtonDown.sqf", 		CLIENT],
	["client_inventory_open", 					"DMServer\code\client\inventory\client_inventory_open.sqf",					CLIENT],
	["client_inventory_setPicture", 			"DMServer\code\client\inventory\client_inventory_setPicture.sqf",			CLIENT],
	["client_inventory_setTooltipLB", 			"DMServer\code\client\inventory\client_inventory_setTooltipLB.sqf",			CLIENT],
	["client_inventory_swapBackpack", 			"DMServer\code\client\inventory\client_inventory_swapBackpack.sqf",			CLIENT],
	["client_inventory_unloadBackpack", 		"DMServer\code\client\inventory\client_inventory_unloadBackpack.sqf",		CLIENT],
	["client_inventory_updateContainerList", 	"DMServer\code\client\inventory\client_inventory_updateContainerList.sqf",	CLIENT],
	["client_inventory_makeCounter", 			"DMServer\code\client\inventory\client_inventory_makeCounter.sqf", 			CLIENT],
	// Экипировка
	["client_loadout_choose", 					"DMServer\code\client\client_loadout_choose.sqf",							CLIENT]
];

call server_init_main;