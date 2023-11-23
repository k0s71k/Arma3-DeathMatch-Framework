params ["_ctrl", "_selectedIndex"];
private _display = ctrlParent _ctrl;
private _data = call compile (_ctrl lbData _selectedIndex);
private _fromContainer = (ctrlParentControlsGroup _ctrl) getVariable ["containerObject",objNull];
_display setVariable ["fromContainer", _fromContainer];
private _toIDC = switch (ctrlIDC (ctrlParentControlsGroup _ctrl)) do {
	case 100: {105};
	case 105: {100};
};
_display setVariable	["toIDC", _toIDC];
private _toCtrl			= _display displayCtrl _toIDC;
private _toContainer	= _toCtrl getVariable ["containerObject",objNull];
_display setVariable	["toContainer", _toContainer];
_data params ["_class", "_displayname", "_config", "_mass", "_amount", "_itemdata"];
[_class, _displayname, _config, _mass, 1, _itemdata] call client_inventory_moveItem;