/*
Exports from the Warrior Medals plugin.
*/
namespace WarriorMedals {
    /*
    Returns the Warrior medal color as a string.
    */
    import string GetColorWarriorStr() from "WarriorMedals";

    /*
    Returns the Warrior medal color as a vec3.
    */
    import vec3 GetColorWarriorVec() from "WarriorMedals";

    /*
    Returns the Warrior medal icon (32x32).
    */
    import const UI::Texture@ GetIconWarrior32() from "WarriorMedals";

    /*
    Returns the Warrior medal icon (512x512).
    */
    import const UI::Texture@ GetIconWarrior512() from "WarriorMedals";

    /*
    Returns all cached map data.
    Keys are map UIDs and values are of type WarriorMedals::Map@.
    */
    import const dictionary@ GetMaps() from "WarriorMedals";

    /*
    Gets the warrior medal time for the current map.
    If there is an error or the map does not have a Warrior medal, returns 0.
    This does not query the API for a time, so the plugin must already have it cached for this to return a time.
    Only use this if you need a synchronous function.
    */
    import uint GetWMTime() from "WarriorMedals";

    /*
    Gets the warrior medal time for a given map UID.
    If there is an error or the map does not have a Warrior medal, returns 0.
    This does not query the API for a time, so the plugin must already have it cached for this to return a time.
    Only use this if you need a synchronous function.
    */
    import uint GetWMTime(const string&in uid) from "WarriorMedals";

    /*
    Gets the warrior medal time for the current map.
    If there is an error or the map does not have a Warrior medal, returns 0.
    Queries the API for a medal time if the plugin does not have it cached.
    Use this instead of the synchronous version if possible.
    */
    import uint GetWMTimeAsync() from "WarriorMedals";

    /*
    Gets the warrior medal time for a given map UID.
    If there is an error or the map does not have a Warrior medal, returns 0.
    Queries the API for a medal time if the plugin does not have it cached.
    Use this instead of the synchronous version if possible.
    */
    import uint GetWMTimeAsync(const string&in uid) from "WarriorMedals";

    // DEPRECATED EXPORTS /////////////////////////////////////////////////////////////////////////////////////////////

    /*
    Returns the Warrior medal color as a string.
    Deprecated.
    */
    import string GetColorStr() from "WarriorMedals";

    /*
    Returns the Warrior medal color as a vec3.
    Deprecated.
    */
    import vec3 GetColorVec() from "WarriorMedals";

    /*
    Returns the Warrior medal icon (32x32).
    Deprecated.
    */
    import const UI::Texture@ GetIcon32() from "WarriorMedals";

    /*
    Returns the Warrior medal icon (512x512).
    Deprecated.
    */
    import const UI::Texture@ GetIcon512() from "WarriorMedals";

}
