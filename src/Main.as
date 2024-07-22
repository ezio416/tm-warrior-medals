// c 2024-07-17
// m 2024-07-22

const string colorStr    = "\\$3CF";
const vec3   colorVec    = vec3(0.2f, 0.8f, 1.0f);
UI::Texture@ icon32;
UI::Texture@ icon512;
dictionary@  maps        = dictionary();
uint         pb          = uint(-1);
const float  scale       = UI::GetScale();
const string title       = colorStr + Icons::Circle + "\\$G Warrior Medals";
const string windowTitle = title + "###window-main-" + Meta::ExecutingPlugin().ID;

void Main() {
    startnew(GetAllMapInfosAsync);

    WarriorMedals::GetIcon32();

    startnew(PBLoop);

    bool inMap = InMap();
    bool wasInMap = false;

    while (true) {
        yield();

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
        || !S_Window
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

    WarriorMedals::Map@ map = cast<WarriorMedals::Map@>(maps[uid]);
    if (map is null)
        return;

    int flags = UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoTitleBar;
    if (!UI::IsOverlayShown())
        flags |= UI::WindowFlags::NoMove;

    if (UI::Begin(windowTitle, S_Window, flags)) {
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
    if (UI::MenuItem(title, "", S_Window))
        S_Window = !S_Window;
}

void Update(float) {
    DrawOverUI();
}

void PBLoop() {
    while (true) {
        sleep(500);
        pb = GetPB();
    }
}
