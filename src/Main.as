// c 2024-07-17
// m 2024-07-23

Campaign@     activeSeasonalCampaign;
Campaign@     activeTotdMonth;
Json::Value@  campaignIndices;
dictionary@   campaigns = dictionary();
Campaign@[]   campaignsArr;
const string  colorStr  = "\\$3CF";
const vec3    colorVec  = vec3(0.2f, 0.8f, 1.0f);
UI::Font@     headerFont;
nvg::Texture@ icon;
UI::Texture@  icon32;
UI::Texture@  icon512;
dictionary@   maps      = dictionary();
uint          pb        = uint(-1);
const float   scale     = UI::GetScale();
vec3[]        seasonColors;
const string  title     = colorStr + Icons::Circle + "\\$G Warrior Medals";

void Main() {
    OnSettingsChanged();

    startnew(GetAllMapInfosAsync);

    WarriorMedals::GetIcon32();

    yield();

    IO::FileSource file("assets/warrior_512.png");
    @icon = nvg::LoadTexture(file.Read(file.Size()));

    yield();

    @headerFont = UI::LoadFont("DroidSans.ttf", 26);

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

void OnSettingsChanged() {
    seasonColors = {
        S_ColorWinter,
        S_ColorSpring,
        S_ColorSummer,
        S_ColorFall
    };
}

void Render() {
    MainWindow();
    MedalWindow();
}

void RenderEarly() {
    DrawOverUI();
}

void RenderMenu() {
    if (UI::BeginMenu(title)) {
        if (UI::MenuItem(colorStr + Icons::WindowMaximize + "\\$G Main window", "", S_MainWindow))
            S_MainWindow = !S_MainWindow;

        if (UI::MenuItem(colorStr + Icons::Circle + "\\$G Medal window", "", S_MedalWindow))
            S_MedalWindow = !S_MedalWindow;

        UI::EndMenu();
    }
}

void MainWindow() {
    if (false
        || !S_MainWindow
        || (S_MainHideWithGame && !UI::IsGameUIVisible())
        || (S_MainHideWithOP && !UI::IsOverlayShown())
    )
        return;

    if (UI::Begin(title, S_MainWindow, UI::WindowFlags::None)) {
        UI::PushStyleColor(UI::Col::Button,        vec4(colorVec - vec3(0.2f), 1.0f));
        UI::PushStyleColor(UI::Col::ButtonActive,  vec4(colorVec - vec3(0.4f), 1.0f));
        UI::PushStyleColor(UI::Col::ButtonHovered, vec4(colorVec,              1.0f));
        UI::BeginDisabled(getting);
        if (UI::Button(Icons::Refresh + " Refresh" + (getting  ? "ing..." : ""))) {
            trace("refreshing...");
            startnew(GetAllMapInfosAsync);
        }
        UI::EndDisabled();
        UI::PopStyleColor(3);

        UI::PushStyleColor(UI::Col::Tab,        vec4(colorVec - vec3(0.4f),  1.0f));
        UI::PushStyleColor(UI::Col::TabActive,  vec4(colorVec - vec3(0.15f), 1.0f));
        UI::PushStyleColor(UI::Col::TabHovered, vec4(colorVec - vec3(0.15f), 1.0f));
        UI::BeginTabBar("##tab-bar");
            Tab_Seasonal();
            Tab_Totd();
            Tab_Other();
        UI::EndTabBar();
        UI::PopStyleColor(3);
    }
    UI::End();
}

void MedalWindow() {
    if (false
        || !S_MedalWindow
        || (S_MedalHideWithGame && !UI::IsGameUIVisible())
        || (S_MedalHideWithOP && !UI::IsOverlayShown())
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
        const bool delta = S_MedalDelta && pb != uint(-1);

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

void PBLoop() {
    while (true) {
        sleep(500);
        pb = GetPB();
    }
}

bool Tab_Campaign(Campaign@ campaign, bool selected) {
    bool open = campaign !is null;

    if (open && UI::BeginTabItem(campaign.name, open, selected ? UI::TabItemFlags::SetSelected : UI::TabItemFlags::None)) {
        for (uint i = 0; i < campaign.mapsArr.Length; i++) {
            WarriorMedals::Map@ map = campaign.mapsArr[i];
            if (map is null)
                continue;

            UI::Text(map.name);
        }

        UI::EndTabItem();
    }

    return open;
}

void Tab_Other() {
    if (!UI::BeginTabItem(Icons::QuestionCircle + " Other Campaigns"))
        return;

    for (uint i = 0; i < campaignsArr.Length; i++) {
        Campaign@ campaign = campaignsArr[i];
        if (campaign is null || campaign.type != WarriorMedals::CampaignType::Other)
            continue;

        UI::Text(campaign.name);
    }

    UI::EndTabItem();
}

void Tab_Seasonal() {
    if (!UI::BeginTabItem(Icons::SnowflakeO + " Seasonal Campaigns"))
        return;

    bool selected = false;

    UI::BeginTabBar("##tab-bar-seasonal");
        if (UI::BeginTabItem(Icons::List + " List")) {
            uint lastYear = 0;

            for (uint i = 0; i < campaignsArr.Length; i++) {
                Campaign@ campaign = campaignsArr[i];
                if (campaign is null || campaign.type != WarriorMedals::CampaignType::Seasonal)
                    continue;

                if (lastYear != campaign.year) {
                    if (lastYear > 0) {
                        UI::NewLine();
                        UI::Separator();
                    }

                    lastYear = campaign.year;

                    UI::PushFont(headerFont);
                    UI::Text(tostring(campaign.year + 2020));
                    UI::PopFont();
                }

                bool colored = false;
                if (seasonColors.Length == 4 && campaign.colorIndex < 4) {
                    UI::PushStyleColor(UI::Col::Button,        vec4(seasonColors[campaign.colorIndex] - vec3(0.1f), 1.0f));
                    UI::PushStyleColor(UI::Col::ButtonActive,  vec4(seasonColors[campaign.colorIndex] - vec3(0.4f), 1.0f));
                    UI::PushStyleColor(UI::Col::ButtonHovered, vec4(seasonColors[campaign.colorIndex],              1.0f));
                    colored = true;
                }

                if (UI::Button(campaign.name.SubStr(0, campaign.name.Length - 5) + "##" + campaign.name, vec2(scale * 100.0f, scale * 25.0f))) {
                    @activeSeasonalCampaign = campaign;
                    selected = true;
                }

                if (colored)
                    UI::PopStyleColor(3);

                UI::SameLine();
            }

            UI::EndTabItem();
        }

        if (!Tab_Campaign(activeSeasonalCampaign, selected))
            @activeSeasonalCampaign = null;

    UI::EndTabBar();

    UI::EndTabItem();
}

void Tab_Totd() {
    if (!UI::BeginTabItem(Icons::Calendar + " Tracks of the Day"))
        return;

    bool selected = false;

    UI::BeginTabBar("##tab-bar-totd");
        if (UI::BeginTabItem(Icons::List + " List")) {
            uint lastYear = 0;

            for (uint i = 0; i < campaignsArr.Length; i++) {
                Campaign@ campaign = campaignsArr[i];
                if (campaign is null || campaign.type != WarriorMedals::CampaignType::TrackOfTheDay)
                    continue;

                if (lastYear != campaign.year) {
                    if (lastYear > 0)
                        UI::Separator();

                    lastYear = campaign.year;

                    UI::PushFont(headerFont);
                    UI::Text(tostring(campaign.year + 2020));
                    UI::PopFont();
                }

                bool colored = false;
                if (seasonColors.Length == 4 && campaign.colorIndex < 4) {
                    UI::PushStyleColor(UI::Col::Button,        vec4(seasonColors[campaign.colorIndex] - vec3(0.1f), 1.0f));
                    UI::PushStyleColor(UI::Col::ButtonActive,  vec4(seasonColors[campaign.colorIndex] - vec3(0.4f), 1.0f));
                    UI::PushStyleColor(UI::Col::ButtonHovered, vec4(seasonColors[campaign.colorIndex],              1.0f));
                    colored = true;
                }

                if (UI::Button(campaign.name.SubStr(0, campaign.name.Length - 5) + "##" + campaign.name, vec2(scale * 100.0f, scale * 25.0f))) {
                    @activeTotdMonth = campaign;
                    selected = true;
                }

                if (colored)
                    UI::PopStyleColor(3);

                if ((campaign.month - 1) % 3 > 0)
                    UI::SameLine();
            }

            UI::EndTabItem();
        }

        if (!Tab_Campaign(activeTotdMonth, selected))
            @activeTotdMonth = null;

    UI::EndTabBar();

    UI::EndTabItem();
}
