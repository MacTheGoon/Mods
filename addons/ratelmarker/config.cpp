#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"tac_common", "ace_interaction"};
        author[]= {"DaC", "Jonpas"};
        authorUrl = "http://www.theseus-aegis.com/";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgVehicles.hpp"

#include <markerMenu.hpp>