// c 2024-07-17
// m 2024-07-18

const string color = "\\$3CF";
dictionary@  maps  = dictionary();
const float  scale = UI::GetScale();
const string title = color + Icons::Circle + "\\$G Warrior Medals";

void Main() {
    GetAllWarriorTimesAsync();

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

            if (inMap && !maps.Exists(cast<CTrackMania@>(GetApp()).RootMap.EdChallengeId))
                GetCurrentWarriorTimeAsync();
        }
    }
}

void Render() {
    if (false
        || !S_Enabled
        || (S_HideWithGame && !UI::IsGameUIVisible())
        || (S_HideWithOP && !UI::IsOverlayShown())
    )
        return;

    if (!InMap())
        return;

    int flags = UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoTitleBar;
    if (!UI::IsOverlayShown())
        flags |= UI::WindowFlags::NoMove;

    if (UI::Begin(title, S_Enabled, flags)) {
        CTrackMania@ App = cast<CTrackMania@>(GetApp());

        const string uid = App.RootMap.EdChallengeId;

        string reason;
        string text = "none";

        if (maps.Exists(uid)) {
            Map@ map = cast<Map@>(maps[uid]);
            if (map !is null) {
                reason = map.reason;
                text = Time::Format(map.custom > 0 ? map.custom : map.warrior);
            }
        }

        UI::Text(color + Icons::Circle + "\\$G Warrior: " + text);
        if (reason.Length > 0)
            HoverTooltip("Custom medal time due to: \\$FA6" + reason);
    }
    UI::End();
}

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}
