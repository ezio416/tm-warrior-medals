// c 2024-07-17
// m 2024-07-17

namespace WarriorMedals {
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
}
