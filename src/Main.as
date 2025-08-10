// c 2024-07-17
// m 2025-08-03

Campaign@[]         activeOtherCampaigns;
Campaign@[]         activeSeasonalCampaigns;
Campaign@[]         activeTotdMonths;
Campaign@[]         activeWeeklyWeeks;
Json::Value@        campaignIndices;
dictionary          campaigns;
Campaign@[]         campaignsArr;
Campaign@[]         campaignsArrRev;
const vec3          colorWarriorVec          = vec3(0.18f, 0.58f, 0.8f);
const bool          hasPlayPermission        = Permissions::PlayLocalMap();
UI::Texture@        iconWarrior32;
UI::Texture@        iconWarrior512;
nvg::Texture@       iconWarriorNvg;
WarriorMedals::Map@ latestTotd;
bool                loading                  = false;
dictionary          maps;
dictionary          mapsById;
int64               nextWarriorRequest       = 0;
const string        pluginColor              = "\\$38C";
const string        pluginIcon               = Icons::Circle;
Meta::Plugin@       pluginMeta               = Meta::ExecutingPlugin();
const string        pluginTitle              = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;
WarriorMedals::Map@ previousTotd;
const string        reqAgentStart            = "Openplanet / Net::HttpRequest / " + pluginMeta.ID + " " + pluginMeta.Version;
vec3[]              seasonColors;
Medal               selectedMedal            = Medal::Warrior;
bool                settingTotals            = false;
uint                total                    = 0;
uint                totalWarriorHave         = 0;
uint                totalWarriorOther        = 0;
uint                totalWarriorOtherHave    = 0;
uint                totalWarriorSeasonal     = 0;
uint                totalWarriorSeasonalHave = 0;
uint                totalWarriorTotd         = 0;
uint                totalWarriorTotdHave     = 0;
uint                totalWarriorWeekly       = 0;
uint                totalWarriorWeeklyHave   = 0;
const string        uidSeparator             = "|warrior-campaign|";

enum Medal {
    Warrior
}

void Main() {
    startnew(API::CheckVersionAsync);

    OnSettingsChanged();
    startnew(API::GetAllMapInfosAsync);
    WarriorMedals::GetIcon32();

    yield();

    IO::FileSource file("assets/warrior_512.png");
    @iconWarriorNvg = nvg::LoadTexture(file.Read(file.Size()));

    yield();

    startnew(PBLoop);

#if DEPENDENCY_ULTIMATEMEDALSEXTENDED
    trace("registering UME medal");
    UltimateMedalsExtended::AddMedal(UME_Warrior());
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

void OnDestroyed() {
#if DEPENDENCY_ULTIMATEMEDALSEXTENDED
    UltimateMedalsExtended::RemoveMedal("Warrior");
#endif
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
    if (iconWarrior32 is null) {
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
    totalWarriorHave         = 0;
    totalWarriorOther        = 0;
    totalWarriorOtherHave    = 0;
    totalWarriorSeasonal     = 0;
    totalWarriorSeasonalHave = 0;
    totalWarriorTotd         = 0;
    totalWarriorTotdHave     = 0;
    totalWarriorWeekly       = 0;
    totalWarriorWeeklyHave   = 0;

    for (uint i = 0; i < campaignsArr.Length; i++) {
        Campaign@ campaign = campaignsArr[i];
        if (campaign !is null) {
            const uint countWarrior = campaign.countWarrior;
            totalWarriorHave += countWarrior;

            switch (campaign.type) {
                case WarriorMedals::CampaignType::Other:
                    totalWarriorOther += campaign.mapsArr.Length;
                    totalWarriorOtherHave += countWarrior;
                    break;

                case WarriorMedals::CampaignType::Seasonal:
                    totalWarriorSeasonal += campaign.mapsArr.Length;
                    totalWarriorSeasonalHave += countWarrior;
                    break;

                case WarriorMedals::CampaignType::TrackOfTheDay:
                    totalWarriorTotd += campaign.mapsArr.Length;
                    totalWarriorTotdHave += countWarrior;
                    break;

                case WarriorMedals::CampaignType::Weekly:
                    totalWarriorWeekly += campaign.mapsArr.Length;
                    totalWarriorWeeklyHave += countWarrior;
                    break;
            }
        }
    }

    trace("setting totals done after " + (Time::Now - start) + "ms");
    settingTotals = false;
}

void WaitForNextRequestAsync() {
    while (true) {
        sleep(60000);

        if (true
            and nextWarriorRequest > 0
            and Time::Stamp - nextWarriorRequest > 300  // wait 5 minutes after new times drop
        ) {
            API::GetAllMapInfosAsync();
            sleep(300000);
        }
    }
}
