// c 2024-07-17
// m 2025-10-30

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
Json::Value@        pbsById                  = Json::Value();
const string        pluginColor              = "\\$38C";
const string        pluginIcon               = Icons::Circle;
Meta::Plugin@       pluginMeta               = Meta::ExecutingPlugin();
const string        pluginTitle              = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;
WarriorMedals::Map@ previousTotd;
vec3[]              seasonColors;
Medal               selectedMedal            = Medal::Warrior;
bool                settingTotals            = false;
Token               token;
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
    if (API::savedToken.Length > 0) {
        token.token = API::savedToken;
    }

    WarriorMedals::GetIcon32();
    IO::FileSource file("assets/warrior_512.png");
    @iconWarriorNvg = nvg::LoadTexture(file.Read(file.Size()));

    yield();

    API::GetTokenAsync();

    OnSettingsChanged();
    startnew(API::GetAllMapInfosAsync);

    yield();

    startnew(PBLoop);
    startnew(WaitForNextRequestAsync);

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

void OnEnabled() {
    if (API::savedToken.Length > 0) {
        token.token = API::savedToken;
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

void ReadPBs() {
    const uint64 start = Time::Now;
    trace("reading PBs from file");

    @pbsById = Json::Value();

    try {
        @pbsById = Json::FromFile(IO::FromStorageFolder("pbs2.json"));
        if (pbsById.GetType() != Json::Type::Object) {
            @pbsById = Json::Value();
            throw("bad json");
        }
    } catch {
        error("error reading all PBs from file after " + (Time::Now - start) + "ms: " + getExceptionInfo());
        return;
    }

    string[]@ ids = mapsById.GetKeys();
    string id;
    for (uint i = 0; i < ids.Length; i++) {
        id = ids[i];
        if (pbsById.HasKey(id)) {
            auto map = cast<WarriorMedals::Map>(mapsById[id]);
            if (map !is null) {
                map.pb = uint(pbsById[id]);
            }
        }
    }

    trace("read all PBs (" + pbsById.Length + ") after " + (Time::Now - start) + "ms");
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
        sleep(1000);

        if (true
            and nextWarriorRequest > 0
            and Time::Stamp - nextWarriorRequest > 0
        ) {
            trace("passed next request time, waiting to actually request...");
            sleep(Math::Rand(240000, 360001));  // 4-6 minutes
            trace("auto-requesting maps...");
            API::GetAllMapInfosAsync();
        }
    }
}
