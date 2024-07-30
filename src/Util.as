// c 2024-07-18
// m 2024-07-30

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
        }

        WarriorMedals::Map@ map = cast<WarriorMedals::Map@>(maps[uids[i]]);
        if (map is null)
            continue;

        map.GetPB();
    }

    trace("getting all PBs done after " + (Time::Now - start) + "ms");
}

void HoverTooltip(const string &in msg) {
    if (!UI::IsItemHovered())
        return;

    UI::BeginTooltip();
        UI::Text(msg);
    UI::EndTooltip();
}

bool InMap() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    return true
        && App.RootMap !is null
        && App.CurrentPlayground !is null
        && App.Editor is null
    ;
}

void PlayMapAsync(ref@ m) {
    if (!hasPlayPermission) {
        warn("user doesn't have permission to play local maps");
        return;
    }

    WarriorMedals::Map@ map = cast<WarriorMedals::Map@>(m);
    if (map is null) {
        warn("given map is null");
        return;
    }

    loading = true;
    map.PlayAsync();
    loading = false;
}
