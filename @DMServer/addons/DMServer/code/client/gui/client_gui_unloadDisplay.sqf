params [
	["_display", displayNull]
];

{
	_x ctrlSetFade	1;
	_x ctrlCommit	0.1;
} foreach (allControls _display);
uiSleep 0.15;

_display closeDisplay 0;