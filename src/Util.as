// c 2024-07-18
// m 2024-07-19

bool CheckJsonType(Json::Value@ value, Json::Type desired, const string &in name, bool warning = true) {
    if (value is null) {
        if (warning)
            warn(name + " is null");
        return false;
    }

    const Json::Type type = value.GetType();
    if (type != desired) {
        if (warning)
            warn(name + " is a(n) " + tostring(type) + ", not a(n) " + tostring(desired));
        return false;
    }

    return true;
}

uint GetPB() {
    return GetPB(cast<CTrackMania@>(GetApp()).RootMap);
}

uint GetPB(CGameCtnChallenge@ Map) {
    if (Map is null)
        return uint(-1);

    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);
    CGameManiaAppPlayground@ CMAP = Network.ClientManiaAppPlayground;

    if (false
        || Map is null
        || CMAP is null
        || CMAP.ScoreMgr is null
        || App.UserManagerScript is null
        || App.UserManagerScript.Users.Length == 0
        || App.UserManagerScript.Users[0] is null
    )
        return uint(-1);

    return CMAP.ScoreMgr.Map_GetRecord_v2(App.UserManagerScript.Users[0].Id, Map.EdChallengeId, "PersonalBest", "", "TimeAttack", "");
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
