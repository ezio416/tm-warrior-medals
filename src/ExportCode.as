/*
Exports from the Warrior Medals plugin.
*/
namespace WarriorMedals {
    /*
    Returns the Warrior medal color as a string.
    */
    string GetColorWarriorStr() {
        return pluginColor;
    }

    /*
    Returns the Warrior medal color as a vec3.
    */
    vec3 GetColorWarriorVec() {
        return colorWarriorVec;
    }

    /*
    Returns the Warrior medal icon (32x32).
    */
    const UI::Texture@ GetIconWarrior32() {
        if (iconWarrior32 is null) {
            IO::FileSource file("assets/warrior_32.png");
            @iconWarrior32 = UI::LoadTexture(file.Read(file.Size()));
        }

        return iconWarrior32;
    }

    /*
    Returns the Warrior medal icon (512x512).
    */
    const UI::Texture@ GetIconWarrior512() {
        if (iconWarrior512 is null) {
            IO::FileSource file("assets/warrior_512.png");
            @iconWarrior512 = UI::LoadTexture(file.Read(file.Size()));
        }

        return iconWarrior512;
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
        if (false
            or pluginMeta is null
            or !pluginMeta.Enabled
        ) {
            // warn("Warrior Medals is disabled");
            return 0;
        }

        auto App = cast<CTrackMania>(GetApp());

        if (false
            or App.RootMap is null
            or App.Editor !is null
        ) {
            return 0;
        }

        return GetWMTime(App.RootMap.EdChallengeId);
    }

    /*
    Gets the warrior medal time for a given map UID.
    If there is an error or the map does not have a Warrior medal, returns 0.
    This does not query the API for a time, so the plugin must already have it cached for this to return a time.
    Only use this if you need a synchronous function.
    */
    uint GetWMTime(const string&in uid) {
        if (false
            or pluginMeta is null
            or !pluginMeta.Enabled
            or GetApp().Editor !is null
        ) {
            // warn("Warrior Medals is disabled");
            return 0;
        }

        if (!maps.Exists(uid)) {
            // startnew(GetWMTimeAsync, uid);
            return 0;
        }

        auto map = cast<Map>(maps[uid]);
        return map !is null ? map.warrior : 0;
    }

    /*
    Gets the warrior medal time for the current map.
    If there is an error or the map does not have a Warrior medal, returns 0.
    Queries the API for a medal time if the plugin does not have it cached.
    Use this instead of the synchronous version if possible.
    */
    uint GetWMTimeAsync() {
        if (false
            or pluginMeta is null
            or !pluginMeta.Enabled
        ) {
            // warn("Warrior Medals is disabled");
            return 0;
        }

        auto App = cast<CTrackMania>(GetApp());

        if (false
            or App.RootMap is null
            or App.Editor !is null
        ) {
            return 0;
        }

        return GetWMTimeAsync(App.RootMap.EdChallengeId);
    }

    /*
    Gets the warrior medal time for a given map UID.
    If there is an error or the map does not have a Warrior medal, returns 0.
    Queries the API for a medal time if the plugin does not have it cached.
    Use this instead of the synchronous version if possible.
    */
    uint GetWMTimeAsync(const string&in uid) {
        if (false
            or pluginMeta is null
            or !pluginMeta.Enabled
            or GetApp().Editor !is null
        ) {
            // warn("Warrior Medals is disabled");
            return 0;
        }

        if (!maps.Exists(uid)) {
            API::GetMapInfoAsync(uid);
        }

        if (!maps.Exists(uid)) {
            return 0;
        }

        auto map = cast<Map>(maps[uid]);
        return map !is null ? map.warrior : 0;
    }

    // DEPRECATED EXPORTS /////////////////////////////////////////////////////////////////////////////////////////////

    /*
    Returns the Warrior medal color as a string.
    Deprecated.
    */
    string GetColorStr() {
        return GetColorWarriorStr();
    }

    /*
    Returns the Warrior medal color as a vec3.
    Deprecated.
    */
    vec3 GetColorVec() {
        return GetColorWarriorVec();
    }

    /*
    Returns the Warrior medal icon (32x32).
    Deprecated.
    */
    const UI::Texture@ GetIcon32() {
        return GetIconWarrior32();
    }

    /*
    Returns the Warrior medal icon (512x512).
    Deprecated.
    */
    const UI::Texture@ GetIcon512() {
        return GetIconWarrior512();
    }
}
