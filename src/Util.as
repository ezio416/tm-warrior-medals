// c 2024-07-18
// m 2025-10-29

void HoverTooltip(const string&in msg) {
    if (!UI::IsItemHovered(UI::HoveredFlags::AllowWhenDisabled)) {
        return;
    }

    UI::BeginTooltip();
    UI::Text(Shadow() + msg);
    UI::EndTooltip();
}

bool InMap() {
    auto App = cast<CTrackMania>(GetApp());

    return true
        and App.RootMap !is null
        and App.CurrentPlayground !is null
        and App.Editor is null
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

void WarnOutdated() {
    const string msg = "Please update through the Plugin Manager at the top. Your current version ("
        + pluginMeta.Version + ") will soon be unsupported!";
    warn(msg);
    UI::ShowNotification(pluginTitle, msg, vec4(colorWarriorVec * 0.5f, 1.0f), 10000);
}
