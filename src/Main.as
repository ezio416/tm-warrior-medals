// c 2024-07-17
// m 2024-07-23

Campaign@     activeSeasonalCampaign;
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
const string  title     = colorStr + Icons::Circle + "\\$G Warrior Medals";

void Main() {
    startnew(GetAllMapInfosAsync);
    startnew(TryGetCampaignIndicesAsync);

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

void Render() {
    if (false
        || (S_HideWithGame && !UI::IsGameUIVisible())
        || (S_HideWithOP && !UI::IsOverlayShown())
        || icon32 is null
    )
        return;

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
    if (!S_MainWindow)
        return;

    if (UI::Begin(title, S_MainWindow, UI::WindowFlags::None)) {
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
    if (!S_MedalWindow || !InMap())
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

void PBLoop() {
    while (true) {
        sleep(500);
        pb = GetPB();
    }
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

    bool switchTab = false;

    UI::BeginTabBar("##tab-bar-seasonal");
        if (UI::BeginTabItem(Icons::List + " List")) {
            uint lastYear = 0;

            for (uint i = 0; i < campaignsArr.Length; i++) {
                Campaign@ campaign = campaignsArr[i];
                if (campaign is null || campaign.type != WarriorMedals::CampaignType::Seasonal)
                    continue;

                const uint year = Text::ParseUInt(campaign.name.SubStr(campaign.name.Length - 4));
                if (lastYear != year) {
                    if (lastYear > 0) {
                        UI::NewLine();
                        UI::Separator();
                    }

                    lastYear = year;

                    UI::PushFont(headerFont);
                    UI::Text(tostring(year));
                    UI::PopFont();
                }

                UI::PushStyleColor(UI::Col::Button,        vec4(campaign.color - vec3(0.1f), 1.0f));
                UI::PushStyleColor(UI::Col::ButtonActive,  vec4(campaign.color - vec3(0.4f), 1.0f));
                UI::PushStyleColor(UI::Col::ButtonHovered, vec4(campaign.color,              1.0f));
                if (UI::Button(campaign.name.SubStr(0, campaign.name.Length - 5) + "##" + campaign.name, vec2(scale * 100.0f, scale * 25.0f))) {
                    @activeSeasonalCampaign = campaign;
                    switchTab = true;
                }
                UI::PopStyleColor(3);

                UI::SameLine();
            }

            UI::EndTabItem();
        }

        bool seasonTabOpen = activeSeasonalCampaign !is null;
        if (seasonTabOpen && UI::BeginTabItem(activeSeasonalCampaign.name, seasonTabOpen, switchTab ? UI::TabItemFlags::SetSelected : UI::TabItemFlags::None)) {
            for (uint i = 0; i < activeSeasonalCampaign.mapsArr.Length; i++) {
                WarriorMedals::Map@ map = activeSeasonalCampaign.mapsArr[i];
                if (map is null)
                    continue;

                UI::Text(map.name);
            }

            UI::EndTabItem();
        }
        if (!seasonTabOpen)
            @activeSeasonalCampaign = null;

    UI::EndTabBar();

    UI::EndTabItem();
}

void Tab_Totd() {
    if (!UI::BeginTabItem(Icons::Calendar + " Tracks of the Day"))
        return;

    for (uint i = 0; i < campaignsArr.Length; i++) {
        Campaign@ campaign = campaignsArr[i];
        if (campaign is null || campaign.type != WarriorMedals::CampaignType::TrackOfTheDay)
            continue;

        UI::Text(campaign.name);
    }

    UI::EndTabItem();
}
