// c 2024-07-17
// m 2024-07-21

/*
Exports from the Warrior Medals plugin.
*/
namespace WarriorMedals {
    /*
    Returns the plugin's main color as a string.
    */
    string GetColorStr() {
        return colorStr;
    }

    /*
    Returns the plugin's main color as a vec3.
    */
    vec3 GetColorVec() {
        return colorVec;
    }

    /*
    Returns the Warrior medal icon (32x32).
    */
    UI::Texture@ GetIcon32() {
        if (icon32 is null) {
            IO::FileSource file("assets/warrior_32.png");
            @icon32 = UI::LoadTexture(file.Read(file.Size()));
        }

        return icon32;
    }

    /*
    Returns the Warrior medal icon (512x512).
    */
    UI::Texture@ GetIcon512() {
        if (icon512 is null) {
            IO::FileSource file("assets/warrior_512.png");
            @icon512 = UI::LoadTexture(file.Read(file.Size()));
        }

        return icon512;
    }

    /*
    Returns all cached map data.
    Keys are map UIDs and values are of type WarriorMedals::Map@.
    */
    const dictionary@ GetMaps() {
        return maps;
    }

    /*
    Gets the warrior medal time for the current map.
    If there is an error or the map does not have a Warrior medal, returns 0.
    This does not query the API for a time, so the plugin must already have it cached for this to return a time.
    Only use this if you need a synchronous function.
    */
    uint GetWMTime() {
        if (!Meta::ExecutingPlugin().Enabled) {
            warn("plugin disabled");
            return 0;
        }

        CTrackMania@ App = cast<CTrackMania@>(GetApp());

        if (App.RootMap is null)
            return 0;

        return GetWMTime(App.RootMap.EdChallengeId);
    }

    /*
    Gets the warrior medal time for a given map UID.
    If there is an error or the map does not have a Warrior medal, returns 0.
    This does not query the API for a time, so the plugin must already have it cached for this to return a time.
    Only use this if you need a synchronous function.
    */
    uint GetWMTime(const string &in uid) {
        if (!Meta::ExecutingPlugin().Enabled) {
            warn("plugin disabled");
            return 0;
        }

        if (!maps.Exists(uid))
            return 0;

        Map@ map = cast<Map@>(maps[uid]);
        if (map is null)
            return 0;

        return map.custom > 0 ? map.custom : map.warrior;
    }

    /*
    Gets the warrior medal time for the current map.
    If there is an error or the map does not have a Warrior medal, returns 0.
    Queries the API for a medal time if the plugin does not have it cached.
    Use this instead of the synchronous version if possible.
    */
    uint GetWMTimeAsync() {
        if (!Meta::ExecutingPlugin().Enabled) {
            warn("plugin disabled");
            return 0;
        }

        CTrackMania@ App = cast<CTrackMania@>(GetApp());

        if (App.RootMap is null)
            return 0;

        return GetWMTimeAsync(App.RootMap.EdChallengeId);
    }

    /*
    Gets the warrior medal time for a given map UID.
    If there is an error or the map does not have a Warrior medal, returns 0.
    Queries the API for a medal time if the plugin does not have it cached.
    Use this instead of the synchronous version if possible.
    */
    uint GetWMTimeAsync(const string &in uid) {
        if (!Meta::ExecutingPlugin().Enabled) {
            warn("plugin disabled");
            return 0;
        }

        if (!maps.Exists(uid))
            GetMapInfoAsync(uid);

        if (!maps.Exists(uid))
            return 0;

        Map@ map = cast<Map@>(maps[uid]);
        if (map is null)
            return 0;

        return map.custom > 0 ? map.custom : map.warrior;
    }
}
