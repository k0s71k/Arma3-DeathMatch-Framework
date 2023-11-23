disableSerialization;

for "_i" from 0 to 1 step 0 do {
	{
		_x params [
			"_control",
			"_status",
			"_statusChangeAt"
		];

		// Если время не пришло, пропускаем итерацию
		if (diag_tickTime < _statusChangeAt) then {continue};
		// Если уже убрали контрол
		if (_status == 1) then {
			ctrlDelete _control;
			DM_hintData deleteAt _forEachIndex;
			continue
		};
		// Если кончилось время контрола
		private _newPosition	= ctrlPosition _control;
		_newPosition			set [0, safeZoneX + safeZoneW];

		_control	ctrlSetFade 1;
		_control	ctrlSetPosition _newPosition;
		_control	ctrlCommit 0.25;
		// Сохраняем полученные значения
		DM_hintData	set [_forEachIndex, [_control, 1, (diag_tickTime + 1)]]
	} foreach DM_hintData;
	uiSleep 0.5;
};
