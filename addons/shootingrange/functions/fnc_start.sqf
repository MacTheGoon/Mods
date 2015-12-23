/*
 * Author: Jonpas
 * Starts shooting range.
 *
 * Arguments:
 * 0: Controller <OBJECT>
 * 1: Controllers <ARRAY>
 * 2: Name <STRING>
 * 3: Targets <ARRAY>
 * 4: Countdown Time <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["range", [target1, target2], controller, [controller1, controller2], 10] call tac_shootingrange_fnc_start;
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_controller", "_controllers", "_name", "_targets", "_countdownTime"];

private _duration = _controller getVariable [QGVAR(configDuration), nil];
private _pauseDuration = _controller getVariable [QGVAR(configPauseDuration), nil];
private _targetChangeEvent = (_targets select 0) getVariable [QGVAR(targetChangeEvent), nil];
if (isNil "_duration" || {isNil "_pauseDuration"} || {isNil "_targetChangeEvent"}) exitWith { ACE_LOGERROR("No configuration found!"); };


// Prepare targets
{
    _x animate ["terc", 1]; // Down
    _x setVariable [QGVAR(starter), ACE_player, true];
} forEach _targets;

// Set variables
{
    _x setVariable [QGVAR(running), true, true];
} forEach _controllers;


// Started notification (including players in vicinity)
private _textDuration = [localize LSTRING(Infinite), format ["%1s", _duration]] select (_duration > 0);
private _playerName = [ACE_player, true] call ACE_Common_fnc_getName;
private _text = format ["%1%2 %3<br/><br/>%4: %5<br/>%6: %7s<br/><br/>By: %8", localize LSTRING(Range), _name, localize LSTRING(Started), localize LSTRING(Duration), _textDuration, localize LSTRING(PauseDuration), _pauseDuration, _playerName];

private _size = [4.5, 4] select (_name isEqualTo "");
[_text, _size, true] call FUNC(notifyVicinity);

// Prepare score variables
GVAR(score) = 0;
GVAR(maxScore) = 0;

// Countdown timer notifications
{
    _x params ["_execTime", "_text"];

    [{
        params ["_controller", "_text"];

        // Exit if not running (eg. stopped)
        if !(_controller getVariable [QGVAR(running), false]) exitWith {};

        // Countdown timer notification
        [_text] call ACE_Common_fnc_displayTextStructured;

    }, [_controller, _text], _execTime] call ACE_Common_fnc_waitAndExecute;

} forEach [ [_countdownTime - 5, localize LSTRING(GetReady)], [_countDownTime - 3, "3"], [_countdownTime - 2, "2"], [_countdownTime - 1, "1"] ];

// Start pop-up handling and final countdown notification
[{
    params ["_controller", "_pauseDuration", "_duration", "_targets", "_controller", "_controllers", "_name", "_targetChangeEvent"];

    // Exit if not running (eg. stopped)
    if !(_controller getVariable [QGVAR(running), false]) exitWith {};

    // Final countdown notification
    [localize LSTRING(Go)] call ACE_Common_fnc_displayTextStructured;

    // Prepare target pop-up handling
    private _timeStart = diag_tickTime;
    GVAR(firstRun) = true;

    // Disable automatic pop-ups
    nopop = true;

    // Start PFH
    [FUNC(popupPFH), _pauseDuration, [_timeStart, _duration, _targets, _controller, _controllers, _name, _targetChangeEvent]] call CBA_fnc_addPerFrameHandler;

}, [_controller, _pauseDuration, _duration, _targets, _controller, _controllers, _name, _targetChangeEvent], _countdownTime] call ACE_Common_fnc_waitAndExecute;


if (_targetChangeEvent == 2) then {
    // Player count bullets fired
    GVAR(firedEHid) = ACE_player addEventHandler ["Fired", { GVAR(maxScore) = GVAR(maxScore) + 1; }];
};
