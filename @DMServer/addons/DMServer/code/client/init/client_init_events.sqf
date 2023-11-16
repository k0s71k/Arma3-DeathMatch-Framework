#define GUI_GRID_W    (0.025)
#define GUI_GRID_H    (0.04)
call client_event_keyBinds;
// Admin Binds
call client_event_adminBinds;

player addEventHandler ["HandleDamage", client_event_onDamage];
player addEventHandler ["InventoryOpened", client_event_onDamage];

// Отображаем имена игроков
addMissionEventHandler ["Draw3D", client_event_draw3d];