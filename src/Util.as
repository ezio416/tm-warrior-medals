// c 2024-07-18
// m 2025-07-15

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
