// c 2024-07-18
// m 2024-07-22

void GetAllPBsAsync() {
    const string[]@ uids = maps.GetKeys();

    uint64 lastYield = Time::Now;
    const uint64 maxFrameTime = 50;

    const uint64 start = lastYield;
    trace("getting all PBs");

    for (uint i = 0; i < uids.Length; i++) {
        const uint64 now = Time::Now;
        if (now - lastYield > maxFrameTime) {
            lastYield = now;
            yield();
            print("yield at index " + i);
        }

        WarriorMedals::Map@ map = cast<WarriorMedals::Map@>(maps[uids[i]]);
        if (map is null)
            continue;

        map.GetPB();
    }

    const uint64 end = Time::Now;
    trace("getting all PBs done after " + (end - start) + "ms");
}

uint GetPB() {
    return GetPB(cast<CTrackMania@>(GetApp()).RootMap);
}

uint GetPB(CGameCtnChallenge@ Map) {
    if (Map is null)
        return uint(-1);

    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);
    CGameManiaAppPlayground@ CMAP = Network.ClientManiaAppPlayground;

    if (false
        || Map is null
        || CMAP is null
        || CMAP.ScoreMgr is null
        || App.UserManagerScript is null
        || App.UserManagerScript.Users.Length == 0
        || App.UserManagerScript.Users[0] is null
    )
        return uint(-1);

    return CMAP.ScoreMgr.Map_GetRecord_v2(App.UserManagerScript.Users[0].Id, Map.EdChallengeId, "PersonalBest", "", "TimeAttack", "");
}

bool InMap() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    return true
        && App.RootMap !is null
        && App.CurrentPlayground !is null
        && App.Editor is null
    ;
}
