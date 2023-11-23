call client_event_keyBinds;
call client_event_adminBinds;

player addEventHandler ["HandleDamage",		client_event_onDamage];
player addEventHandler ["InventoryOpened",	client_event_inventoryOpened];

// Отображаем имена игроков
addMissionEventHandler ["Draw3D",			client_event_draw3D];