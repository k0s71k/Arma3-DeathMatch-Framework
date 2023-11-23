#define GUI_GRID_H (0.04)
#define GUI_GRID_W (0.025)

params [
	["_display", displayNull, [displayNull]],
	["_group", controlNull, [controlNull]],
	["_itemsCount", 0, [0]]
];

// Some Math shit
private _pictureHeight		= 3 * GUI_GRID_H;
private _weaponItemsHeight	= 1.5 * GUI_GRID_H;
private _weaponItemsMargin	= 0.2 * GUI_GRID_W;
private _weaponItemsWidth	= (14.5 * GUI_GRID_W - (_weaponItemsMargin * (_itemsCount - 1))) / _itemsCount;
private _controlXPos		= 0;
private _controlsArray		= [];

// Главный слот оружия
private _picture = [_display, [
	0,
	0,
	14.5 * GUI_GRID_W,
	3 * GUI_GRID_H
], "RscPictureKeepAspect", _group] call client_inventory_createControl;
// Текст с количеством патрон
private _ammoText = [_display, [
	0.5 * GUI_GRID_W,
	1.7 * GUI_GRID_H,
	13.5 * GUI_GRID_W,
	1 * GUI_GRID_H
], "RscStructuredText", _group, false] call client_inventory_createControl;
_ammoText ctrlEnable false;

_controlsArray pushBack _picture;

// Создаем значки для предметов оружия
for "_i" from 1 to _itemsCount do {
	private _control = [_display, [
		_controlXPos,
		_pictureHeight + 0.1 * GUI_GRID_H,
		_weaponItemsWidth,
		_weaponItemsHeight
	], "RscPictureKeepAspect", _group] call client_inventory_createControl;

	_controlsArray pushBack _control;

	_controlXPos = _controlXPos + _weaponItemsWidth + _weaponItemsMargin;
};

_controlsArray pushBack _ammoText;

_controlsArray