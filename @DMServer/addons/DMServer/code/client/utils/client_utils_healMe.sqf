if (!isNull objectParent player) exitWith {};
if (damage player == 0) exitWith {["Вы полностью здоровы", "warning"] call client_gui_hint};
player playMoveNow "ainvpknlmstpsnonwnondnon_medic_1";
waitUntil {uiSleep 0.1; (animationState player) == "ainvpknlmstpsnonwnondnon_medic_1"};
waitUntil {uiSleep 0.1; (animationState player) != "ainvpknlmstpsnonwnondnon_medic_1"};

player setDamage 0;
["Вы полностью излечились", "done"] call client_gui_hint;