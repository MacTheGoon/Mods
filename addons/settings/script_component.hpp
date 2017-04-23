#define COMPONENT settings
#define COMPONENT_BEAUTIFIED Settings
#include "\x\tac\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE
// #define ENABLE_PERFORMANCE_COUNTERS

#ifdef DEBUG_ENABLED_SETTINGS
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_SETTINGS
    #define DEBUG_SETTINGS DEBUG_SETTINGS_SETTINGS
#endif

#include "\x\tac\addons\main\script_macros.hpp"

#define PATH_SETTINGS_FILE_PBO QPATHTOF(cba\settings.sqf)