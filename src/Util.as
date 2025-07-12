// c 2024-07-18
// m 2025-07-12

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

        auto map = cast<WarriorMedals::Map>(maps[uids[i]]);
        if (map is null) {
            continue;
        }

        map.GetPB();
        Files::AddPB(map);
    }

    trace("got all PBs from game after " + (Time::Now - start) + "ms");
}

void HoverTooltip(const string&in msg) {
    if (!UI::IsItemHovered(UI::HoveredFlags::AllowWhenDisabled)) {
        return;
    }

    UI::BeginTooltip();
    UI::Text(Shadow() + msg);
    UI::EndTooltip();
}

bool InMap(bool allowEditor = false) {
    auto App = cast<CTrackMania>(GetApp());

    return true
        and App.RootMap !is null
        and App.CurrentPlayground !is null
        and (App.Editor is null or allowEditor)
    ;
}

void PlayMapAsync(ref@ m) {
    if (!hasPlayPermission) {
        warn("user doesn't have permission to play local maps");
        return;
    }

    auto map = cast<WarriorMedals::Map>(m);
    if (map is null) {
        warn("given map is null");
        return;
    }

#if DEPENDENCY_MLHOOK
    if (Meta::GetPluginFromID("MLHook").Enabled) {
        MLHook::Queue_Menu_SendCustomEvent("Event_UpdateLoadingScreen", {map.name});
    }
#endif

    loading = true;
    map.PlayAsync();
    loading = false;
}

string Shadow() {
    return S_MainWindowTextShadows ? "\\$S" : "";
}
