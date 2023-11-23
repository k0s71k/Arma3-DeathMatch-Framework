params ["_ctrl", "_listboxInfo"];

private _display		= ctrlParent _ctrl;
if !(call client_inventory_canOperate) exitWith {};
// Запоминаем начальный контрол
private _fromContainer	= (ctrlParentControlsGroup _ctrl) getVariable ["containerObject",objNull];
_display setVariable	["fromContainer", _fromContainer];
_display setVariable	["toIDC", -1];