// c 2024-07-17
// m 2024-07-19

namespace WarriorMedals {
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
    import uint GetWMTime(const string &in uid) from "WarriorMedals";

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
    import uint GetWMTimeAsync(const string &in uid) from "WarriorMedals";
}
