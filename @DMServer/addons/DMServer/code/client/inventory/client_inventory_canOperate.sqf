private _display = uiNamespace getVariable ["InventoryDisplay",displayNull];
private _readonly = _display getVariable ["readonly",false];
private _fromContainer = _display getVariable ["fromContainer",objNull];
private _toContainer = _display getVariable ["toContainer",objNull];
private _remoteContainer = _display getVariable ["container",objNull];
private _usedBy = _remoteContainer getVariable ["usedBy",objNull];
private _remoteInUse = _remoteContainer in [_toContainer, _fromContainer];
private _return = switch (true) do {
	case (_readonly AND _remoteInUse): {false};
	case (!(_usedBy isEqualTo player) AND _remoteInUse): {false};
	default {true}
};
if (_return) then {_remoteContainer setVariable ["usedBy", player, true]} else {4 call client_inventory_message};
_return