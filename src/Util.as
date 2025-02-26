// c 2024-07-18
// m 2025-02-20

float GayHue(uint cycleTimeMs = 5000, float offset = 0.0f, bool reverse = false) {
    const float h = float(Time::Now % cycleTimeMs) / float(cycleTimeMs) + offset;
    const float normal = h - Math::Floor(h);

    if (reverse)
        return 1.0f - normal;

    return normal;
}

void GetAllPBsAsync() {
    const string[]@ uids = maps.GetKeys();

    uint64 lastYield = Time::Now;
    const uint64 maxFrameTime = 50;

    const uint64 start = lastYield;
    trace("getting all PBs from game");

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
        Files::AddPB(map);
    }

    trace("got all PBs from game after " + (Time::Now - start) + "ms");
}

void HoverTooltip(const string &in msg) {
    if (!UI::IsItemHovered(UI::HoveredFlags::AllowWhenDisabled))
        return;

    UI::BeginTooltip();
    UI::Text(Shadow() + msg);
    UI::EndTooltip();
}

bool InMap(bool allowEditor = false) {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    return true
        && App.RootMap !is null
        && App.CurrentPlayground !is null
        && (App.Editor is null || allowEditor)
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

string Shadow() {
    return S_MainWindowTextShadows ? "\\$S" : "";
}
