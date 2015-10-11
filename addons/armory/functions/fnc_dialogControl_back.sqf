/*
 * Author: Jonpas
 * Goes back to menu or exits Armory.
 *
 * Arguments:
 * 0: Type <STRING>
 *
 * Return Value:
 * The return value <BOOL>
 *
 * Example:
 * ["type"] call tac_armory_fnc_dialogControl_back
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_type"];

// Set Back
if (_type == "back") then {
    ctrlSetText [BACKPIC, QUOTE(PATHTOF(UI\btnBack.paa))];
    buttonSetAction [BACKBTN, QUOTE(['main'] call FUNC(dialogControl))];
    CTRL(BACKBTN) ctrlSetTooltip "Back to Main Menu";
};

// Set Exit (and destroy GVARs)
if (_type == "exit") then {
    ctrlSetText [BACKPIC, QUOTE(PATHTOF(UI\btnExit.paa))];
    buttonSetAction [BACKBTN, QUOTE(closeDialog 0; GVAR(box) = nil; GVAR(selectedCategory) = nil; GVAR(armoryData) = nil)];
    CTRL(BACKBTN) ctrlSetTooltip "Exit Armory";
};
