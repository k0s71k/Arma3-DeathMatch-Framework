private _uid = param[0, "", [""]];
if (_uid == "") exitWith {};

"2609" serverCommand format['#exec ban "%1"', _uid];