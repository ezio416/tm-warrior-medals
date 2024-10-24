// c 2024-07-24
// m 2024-10-23

void MedalWindow() {
    if (false
        || !S_MedalWindow
        || (S_MedalWindowHideWithGame && !UI::IsGameUIVisible())
        || (S_MedalWindowHideWithOP && !UI::IsOverlayShown())
        || !InMap()
    )
        return;

    const string uid = cast<CTrackMania@>(GetApp()).RootMap.EdChallengeId;
    if (!maps.Exists(uid))
        return;

    WarriorMedals::Map@ map = cast<WarriorMedals::Map@>(maps[uid]);
    if (map is null)
        return;

    int flags = UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoTitleBar;
    if (!UI::IsOverlayShown())
        flags |= UI::WindowFlags::NoMove;

    if (UI::Begin(title + "-medal", S_MedalWindow, flags)) {
        const uint warrior = map.custom > 0 ? map.custom : map.warrior;
        const bool delta = S_MedalWindowDelta && map.pb != uint(-1);

        int cols = 2;
        if (S_MedalWindowName)
            cols++;
        if (delta)
            cols++;

        if (UI::BeginTable("##table-times", cols)) {
            UI::TableNextRow();

            UI::TableNextColumn();
            if (S_MedalWindowIcon)
                UI::Image(icon32, vec2(scale * 16.0f));
            else
                UI::Text(colorStr + Icons::Circle);

            if (S_MedalWindowName) {
                UI::TableNextColumn();
                UI::Text("Warrior");
            }

            UI::TableNextColumn();
            UI::Text(Time::Format(warrior));

            if (delta) {
                UI::TableNextColumn();
                UI::Text((map.pb <= warrior ? "\\$77F\u2212" : "\\$F77+") + Time::Format(uint(Math::Abs(map.pb - warrior))));
            }

            UI::EndTable();
        }
    }
    UI::End();
}
