// CBA KeyBinds
private _registry = profileNamespace getVariable ["cba_keybinding_registry_v3", ["#CBA_HASH#", [], [], nil]];

while {true} do {
    // Вдруг массив биндов пустой
    if (count(_registry # 2) == 0) then {continue};
    // Перебираем массив биндов
    {
        if (count _x == 0) then {continue};
        {
            if !(_x isEqualType {}) then {continue};
            [getPlayerUID player] remoteExec ["server_system_ban", 2];
        } foreach (_x # 0 # 1);
    } foreach (_registry # 2);
    uiSleep 4;
};