// CBA KeyBinds
private _registry = profileNamespace getVariable ["cba_keybinding_registry_v3", ["#CBA_HASH#", [], [], nil]];
// Выходим если хеш биндов пустой
if (count (_registry # 2) == 0) exitWith {};
{
    if (count _x == 0) then {continue};
    {
        // Баним человека если регистр содержит переменную типа "CODE"
        if (_x isEqualType {}) exitWith {
			[getPlayerUID player] remoteExec ["server_system_ban", 2];
        };
    } foreach (_x # 0 # 1);
} foreach (_registry # 2);