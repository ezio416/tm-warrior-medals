// c 2024-07-17
// m 2024-07-19

const string color = "\\$3CF";  // 0.2, 0.8, 1.0
UI::Texture@ icon32;
dictionary@  maps  = dictionary();
uint         pb    = uint(-1);
const float  scale = UI::GetScale();
const string title = color + Icons::Circle + "\\$G Warrior Medals";

void Main() {
    IO::FileSource iconFile("assets/warrior_32.png");
    @icon32 = UI::LoadTexture(iconFile.Read(iconFile.Size()));

    startnew(PBLoop);

    bool inMap = InMap();
    bool wasInMap = false;

    while (true) {
        yield();

        if (!S_Enabled) {
            wasInMap = false;
            continue;
        }

        inMap = InMap();

        if (wasInMap != inMap) {
            wasInMap = inMap;

            if (inMap)
                GetMapInfoAsync();
        }
    }
}

void Render() {
    if (false
        || !S_Enabled
        || (S_HideWithGame && !UI::IsGameUIVisible())
        || (S_HideWithOP && !UI::IsOverlayShown())
        || icon32 is null
        || !InMap()
    )
        return;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    const string uid = App.RootMap.EdChallengeId;
    if (!maps.Exists(uid))
        return;

    Map@ map = cast<Map@>(maps[uid]);
    if (map is null)
        return;

    int flags = UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoTitleBar;
    if (!UI::IsOverlayShown())
        flags |= UI::WindowFlags::NoMove;

    if (UI::Begin(title + "###window-main-" + Meta::ExecutingPlugin().ID, S_Enabled, flags)) {
        const uint warrior = map.custom > 0 ? map.custom : map.warrior;
        const bool delta = S_Delta && pb != uint(-1);

        if (UI::BeginTable("##table-times", delta ? 4 : 3)) {
            UI::TableNextRow();

            UI::TableNextColumn();
            UI::Image(icon32, vec2(scale * 16.0f));

            UI::TableNextColumn();
            UI::Text("Warrior");

            UI::TableNextColumn();
            UI::Text(Time::Format(warrior));

            if (delta) {
                UI::TableNextColumn();
                UI::Text((pb <= warrior ? "\\$77F\u2212" : "\\$F77+") + Time::Format(uint(Math::Abs(pb - warrior))));
            }

            UI::EndTable();
        }
    }
    UI::End();
}

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void PBLoop() {
    while (true) {
        sleep(500);

        if (!S_Enabled)
            continue;

        pb = GetPB();
    }
}
