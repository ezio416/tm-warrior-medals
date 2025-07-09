// c 2024-07-17
// m 2025-07-08

Campaign@           activeOtherCampaign;
Campaign@           activeSeasonalCampaign;
Campaign@           activeTotdMonth;
Campaign@           activeWeeklyWeek;
Json::Value@        campaignIndices;
dictionary@         campaigns         = dictionary();
Campaign@[]         campaignsArr;
Campaign@[]         campaignsArrRev;
const vec3          colorVec          = vec3(0.2f, 0.8f, 1.0f);
UI::Font@           fontHeader;
UI::Font@           fontSubHeader;
bool                hasPlayPermission = false;
nvg::Texture@       iconUI;
UI::Texture@        icon32;
UI::Texture@        icon512;
WarriorMedals::Map@ latestTotd;
bool                loading           = false;
dictionary@         maps              = dictionary();
const string        pluginColor       = "\\$3CF";
const string        pluginIcon        = Icons::Circle;
Meta::Plugin@       pluginMeta        = Meta::ExecutingPlugin();
const string        pluginTitle       = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;
const string        reqAgentStart     = "Openplanet / Net::HttpRequest / " + pluginMeta.ID + " " + pluginMeta.Version;
vec3[]              seasonColors;
bool                settingTotals     = false;
uint                total             = 0;
uint                totalHave         = 0;
const string        uidSeparator      = "|warrior-campaign|";

void OnDestroyed() {
#if DEPENDENCY_ULTIMATEMEDALSEXTENDED
    UltimateMedalsExtended::RemoveMedal("Warrior");
#endif
}

void Main() {
    startnew(API::CheckVersionAsync);

    OnSettingsChanged();
    startnew(API::GetAllMapInfosAsync);
    WarriorMedals::GetIcon32();
    hasPlayPermission = Permissions::PlayLocalMap();

    yield();

    IO::FileSource file("assets/warrior_512.png");
    @iconUI = nvg::LoadTexture(file.Read(file.Size()));

    yield();

    @fontSubHeader = UI::LoadFont("DroidSans.ttf", 20.0f);
    @fontHeader    = UI::LoadFont("DroidSans.ttf", 26.0f);

    startnew(PBLoop);

#if DEPENDENCY_ULTIMATEMEDALSEXTENDED
    print("registering UME medal");
    UME_Medal@ medal = UME_Medal();
    UltimateMedalsExtended::AddMedal(medal);
#endif

    bool inMap = InMap();
    bool wasInMap = false;

    while (true) {
        yield();

        inMap = InMap();

        if (wasInMap != inMap) {
            wasInMap = inMap;

            if (inMap)
                API::GetMapInfoAsync();
        }
    }
}

void OnSettingsChanged() {
    seasonColors = {
        S_ColorWinter,
        S_ColorSpring,
        S_ColorSummer,
        S_ColorFall
    };
}

void Render() {
    if (icon32 is null)
        return;

    MainWindowDetached();
    MedalWindow();
    FeedbackWindow();
}

void RenderEarly() {
    DrawOverUI();
}

void RenderMenu() {
    if (UI::BeginMenu(pluginTitle)) {
        if (UI::MenuItem(pluginColor + Icons::WindowMaximize + "\\$G Detached main window", "", S_MainWindowDetached))
            S_MainWindowDetached = !S_MainWindowDetached;

        if (UI::MenuItem(pluginColor + Icons::Circle + "\\$G Medal window", "", S_MedalWindow))
            S_MedalWindow = !S_MedalWindow;

        UI::EndMenu();
    }
}

void PBLoop() {
    while (true) {
        sleep(500);

        CTrackMania@ App = cast<CTrackMania@>(GetApp());
        if (App.RootMap is null || !maps.Exists(App.RootMap.EdChallengeId))
            continue;

        WarriorMedals::Map@ map = cast<WarriorMedals::Map@>(maps[App.RootMap.EdChallengeId]);
        if (map !is null) {
            const uint prevPb = map.pb;

            map.GetPBAsync();
            Files::AddPB(map);

            if (prevPb != map.pb) {
                SetTotals();
                Files::SavePB(map);
            }
        }
    }
}

void SetTotals() {
    if (settingTotals)
        return;

    settingTotals = true;

    const uint64 start = Time::Now;
    trace("setting totals");

    total = maps.GetKeys().Length;
    totalHave = 0;

    for (uint i = 0; i < campaignsArr.Length; i++) {
        Campaign@ campaign = campaignsArr[i];
        if (campaign !is null)
            totalHave += campaign.count;
    }

    trace("setting totals done after " + (Time::Now - start) + "ms");
    settingTotals = false;
}
