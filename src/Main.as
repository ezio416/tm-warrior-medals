// c 2024-07-17
// m 2024-07-17

const string color = "\\$3CF";
dictionary@  maps  = dictionary();
const float  scale = UI::GetScale();
const string title = color + Icons::Circle + "\\$G Warrior Medals";

void Main() {
    LoadFilesAsync();
}

void Render() {
    if (
        !S_Enabled
        || (S_HideWithGame && !UI::IsGameUIVisible())
        || (S_HideWithOP && !UI::IsOverlayShown())
    )
        return;

    if (!InMap())
        return;

    const uint wm = WarriorMedals::GetWMTime();

    if (UI::Begin(title, S_Enabled, UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoTitleBar)) {
        UI::Text(color + Icons::Circle + "\\$G Warrior: " + (wm > 0 ? Time::Format(wm) : "none"));
    }
    UI::End();
}

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

class Map {
    uint   author;
    uint   custom = 0;
    string nameColor;
    string nameRaw;
    string nameStripped;
    string reason;
    uint   warrior;
    string uid;
    uint   worldRecord;

    Map() { }
    Map(Json::Value@ map) {
        author      = uint(  map["author_time"]);
        uid         = string(map["map_uid"]);
        warrior     = uint(  map["warrior_time"]);
        worldRecord = uint(  map["world_record"]);

        nameRaw = string(map["map_name"]);
        nameColor = Text::OpenplanetFormatCodes(nameRaw);
        nameStripped = Text::StripFormatCodes(nameRaw);
    }

    void UpdateCustom(Json::Value@ map) {
        custom = uint(  map["custom_warrior"]);
        reason = string(map["reason"]);
    }
}

bool InMap() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    return true
        && App.RootMap !is null
        && App.CurrentPlayground !is null
        && App.Editor is null
    ;
}

void LoadFilesAsync() {
    const string[] files = { "campaign", "totd" };
    for (uint i = 0; i < files.Length; i++) {
        const string file = files[i];

        Json::Value@ loaded = Json::FromFile("assets/" + file + ".json");

        string[]@ keys = loaded.GetKeys();
        for (uint j = 0; j < keys.Length; j++) {
            const string campaignName = keys[j];

            Json::Value@ campaign = loaded[campaignName];

            string[]@ uids = campaign.GetKeys();
            for (uint k = 0; k < uids.Length; k++) {
                const string uid = uids[k];

                Json::Value@ jsonMap = campaign[uid];
                jsonMap["map_uid"] = uid;
                Map@ map = Map(jsonMap);
                maps[uid] = @map;
            }
        }

        yield();
    }

    Json::Value@ custom = Json::FromFile("assets/custom.json");

    for (uint i = 0; i < files.Length; i++) {
        const string file = files[i];

        Json::Value@ section = custom[file];

        string[]@ keys = section.GetKeys();
        for (uint j = 0; j < keys.Length; j++) {
            const string campaignName = keys[j];

            Json::Value@ campaign = section[campaignName];

            string[]@ uids = campaign.GetKeys();
            for (uint k = 0; k < uids.Length; k++) {
                const string uid = uids[k];

                Map@ map = cast<Map@>(maps[uid]);
                map.UpdateCustom(campaign[uid]);
            }
        }
    }
}
