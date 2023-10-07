params [
	["_display",displayNull,[displayNull]],
	["_pos",[0,0,0,0], [[]]],
	["_idc", -1, [-1]]
];

private _group = _display ctrlCreate ["RscControlsGroupNoScrollBars", _idc];
_group ctrlSetPosition _pos;
_group ctrlSetFade 1;
_group ctrlCommit 0;
_group