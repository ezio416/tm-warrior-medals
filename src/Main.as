// c 2024-07-17
// m 2025-07-15

Campaign@[]         activeOtherCampaigns;
Campaign@[]         activeSeasonalCampaigns;
Campaign@[]         activeTotdMonths;
Campaign@[]         activeWeeklyWeeks;
Json::Value@        campaignIndices;
dictionary          campaigns;
Campaign@[]         campaignsArr;
Campaign@[]         campaignsArrRev;
const vec3          colorVec          = vec3(0.18f, 0.58f, 0.8f);
const bool          hasPlayPermission = Permissions::PlayLocalMap();
nvg::Texture@       iconUI;
UI::Texture@        icon32;
UI::Texture@        icon512;
WarriorMedals::Map@ latestTotd;
bool                loading           = false;
dictionary          maps;
dictionary          mapsById;
const string        pluginColor       = "\\$38C";
const string        pluginIcon        = Icons::Circle;
Meta::Plugin@       pluginMeta        = Meta::ExecutingPlugin();
const string        pluginTitle       = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;
const string        reqAgentStart     = "Openplanet / Net::HttpRequest / " + pluginMeta.ID + " " + pluginMeta.Version;
vec3[]              seasonColors;
bool                settingTotals     = false;
uint                total             = 0;
uint                totalHave         = 0;
uint                totalOther        = 0;
uint                totalOtherHave    = 0;
uint                totalSeasonal     = 0;
uint                totalSeasonalHave = 0;
uint                totalTotd         = 0;
uint                totalTotdHave     = 0;
uint                totalWeekly       = 0;
uint                totalWeeklyHave   = 0;
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

    yield();

    IO::FileSource file("assets/warrior_512.png");
    @iconUI = nvg::LoadTexture(file.Read(file.Size()));

    yield();

    startnew(PBLoop);

#if DEPENDENCY_ULTIMATEMEDALSEXTENDED
    print("registering UME medal");
    UltimateMedalsExtended::AddMedal(UME_Medal());
#endif

    bool inMap = InMap();
    bool wasInMap = false;

    while (true) {
        yield();

        inMap = InMap();

        if (wasInMap != inMap) {
            wasInMap = inMap;

            if (inMap) {
                API::GetMapInfoAsync();
            }
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
    if (icon32 is null) {
        return;
    }

    MainWindowDetached();
    MedalWindow();
    FeedbackWindow();
}

void RenderEarly() {
    DrawOverUI();
}

void RenderMenu() {
    if (UI::BeginMenu(pluginTitle)) {
        if (UI::MenuItem(pluginColor + Icons::WindowMaximize + "\\$G Detached main window", "", S_MainWindowDetached)) {
            S_MainWindowDetached = !S_MainWindowDetached;
        }

        if (UI::MenuItem(pluginColor + Icons::Circle + "\\$G Medal window", "", S_MedalWindow)) {
            S_MedalWindow = !S_MedalWindow;
        }

        UI::EndMenu();
    }
}

void PBLoop() {
    auto App = cast<CTrackMania>(GetApp());

    while (true) {
        sleep(500);

        if (false
            or App.RootMap is null
            or App.Editor !is null
            or !maps.Exists(App.RootMap.EdChallengeId)
        ) {
            continue;
        }

        auto map = cast<WarriorMedals::Map>(maps[App.RootMap.EdChallengeId]);
        if (map !is null) {
            const uint prevPb = map.pb;

            map.GetPBAsync();

            if (prevPb != map.pb) {
                SetTotals();
            }
        }
    }
}

void SetTotals() {
    if (settingTotals) {
        return;
    }

    settingTotals = true;

    const uint64 start = Time::Now;
    trace("setting totals");

    total = maps.GetKeys().Length;
    totalHave         = 0;
    totalOther        = 0;
    totalOtherHave    = 0;
    totalSeasonal     = 0;
    totalSeasonalHave = 0;
    totalTotd         = 0;
    totalTotdHave     = 0;
    totalWeekly       = 0;
    totalWeeklyHave   = 0;

    for (uint i = 0; i < campaignsArr.Length; i++) {
        Campaign@ campaign = campaignsArr[i];
        if (campaign !is null) {
            const uint count = campaign.count;
            totalHave += count;

            switch (campaign.type) {
                case WarriorMedals::CampaignType::Other:
                    totalOther += campaign.mapsArr.Length;
                    totalOtherHave += count;
                    break;

                case WarriorMedals::CampaignType::Seasonal:
                    totalSeasonal += campaign.mapsArr.Length;
                    totalSeasonalHave += count;
                    break;

                case WarriorMedals::CampaignType::TrackOfTheDay:
                    totalTotd += campaign.mapsArr.Length;
                    totalTotdHave += count;
                    break;

                case WarriorMedals::CampaignType::Weekly:
                    totalWeekly += campaign.mapsArr.Length;
                    totalWeeklyHave += count;
                    break;
            }
        }
    }

    trace("setting totals done after " + (Time::Now - start) + "ms");
    settingTotals = false;
}
