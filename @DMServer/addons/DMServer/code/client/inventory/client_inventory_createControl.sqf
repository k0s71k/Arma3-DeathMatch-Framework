params [
	["_display",displayNull,[displayNull]],
	["_pos", [0,0,0,0], [[]]],
	["_class", "", [""]],
	["_group",controlNull,[controlNull]],
	["_createBackground", true, [true]],
	["_idc", -1, [-1]]
];

//private _backgroundColor = [
//	profileNamespace getVariable ["GUI_V3_BG_R", 0.1],
//	profileNamespace getVariable ["GUI_V3_BG_G", 0.1],
//	profileNamespace getVariable ["GUI_V3_BG_B", 0.1],
//	profileNamespace getVariable ["GUI_V3_BG_A", 0.8]
//];
private _elementBackground = [0.15, 0.15, 0.15, 0.8];

if (_createBackground) then {
	private _backgroundControl = _display ctrlCreate ["RscText", -1, _group];
	_backgroundControl ctrlSetPosition _pos;
	_backgroundControl ctrlCommit 0;
	//_backgroundControl ctrlSetBackgroundColor _backgroundColor;
	_backgroundControl ctrlSetBackgroundColor _elementBackground;
};

private _control = _display ctrlCreate [_class, _idc, _group];
_control ctrlSetPosition _pos;
_control ctrlCommit 0;
if !(_class in ["RscText", "RscStructuredText"]) then {
	_control ctrlEnable true;
};
_control ctrlSetBackgroundColor [0, 0, 0, 0];

_control