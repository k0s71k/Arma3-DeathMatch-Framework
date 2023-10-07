//client_inventory_mouseButtonDown
params ["_ctrl", "_button", "_xPos", "_yPos", "_shift", "_ctrlKey", "_alt"];
private _display = ctrlParent _ctrl;
switch (_button) do {
    case 0: {
        private _ghostCtrl = _display displayCtrl 1000;
        ctrlDelete _ghostCtrl;
        if (ctrlClassName _ctrl in ["RscPicture", "RscPictureKeepAspect"]) then {
            private _data = _ctrl getVariable ["data", []];
            _data params [["_classname", ""]];
            if (_classname isEqualTo "") exitWith {};
            private _ghostCtrl = _display ctrlCreate ["RscPictureKeepAspect", 1000];
            getMousePosition params ["_mouseX", "_mouseY"];
            private _controlPos = ctrlPosition _ctrl;
            _ghostCtrl ctrlSetPosition [
                _mouseX - ((_controlPos # 2) / 2),
                _mouseY - ((_controlPos # 3) / 2),
                _controlPos # 2,
                _controlPos # 3
            ];
            _ghostCtrl ctrlSetFade 0.3;
            _ghostCtrl ctrlCommit 0;
            _ghostCtrl ctrlEnable true;
            _ghostCtrl setVariable ["data", _data];
            _ghostCtrl ctrlSetTextColor [0.5,0.5,0.5,1];
            _ghostCtrl ctrlSetText (ctrlText _ctrl);
        };			
    };
    case 1: {
        private _data = switch (true) do {
            case (ctrlClassName _ctrl in ["RscPicture", "RscPictureKeepAspect"]): {
                private _data = _ctrl getVariable ["data", []];
                _data
            };
            case (ctrlClassName _ctrl in ["DM_ListBoxDrag"]): {
                if (lbCurSel _list isEqualTo -1) exitWith {[]};
                private _data = _ctrl lbData (lbCurSel _ctrl);
                _data = call compile _data;
                _data
            };
            default {[]};
        };
        private _container = (ctrlParentControlsGroup _ctrl) getVariable ["containerObject", objNull];
        [[_ctrl, ctrlClassName _ctrl], [_data, _container]] call client_inventory_makeContext
    };
};