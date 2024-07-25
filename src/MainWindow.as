// c 2024-07-24
// m 2024-07-24

void MainWindow() {
    if (false
        || !S_MainWindow
        || (S_MainWindowHideWithGame && !UI::IsGameUIVisible())
        || (S_MainWindowHideWithOP && !UI::IsOverlayShown())
    )
        return;

    if (UI::Begin(title, S_MainWindow, S_MainWindowAutoResize ? UI::WindowFlags::AlwaysAutoResize : UI::WindowFlags::None)) {
        UI::PushStyleColor(UI::Col::Button,        vec4(colorVec - vec3(0.2f), 1.0f));
        UI::PushStyleColor(UI::Col::ButtonActive,  vec4(colorVec - vec3(0.4f), 1.0f));
        UI::PushStyleColor(UI::Col::ButtonHovered, vec4(colorVec,              1.0f));
        UI::BeginDisabled(getting);
        if (UI::Button(Icons::Refresh + " Refresh" + (getting  ? "ing..." : ""))) {
            trace("refreshing...");
            startnew(GetAllMapInfosAsync);
        }
        UI::EndDisabled();

        UI::PushStyleColor(UI::Col::Tab,        vec4(colorVec - vec3(0.4f),  1.0f));
        UI::PushStyleColor(UI::Col::TabActive,  vec4(colorVec - vec3(0.15f), 1.0f));
        UI::PushStyleColor(UI::Col::TabHovered, vec4(colorVec - vec3(0.15f), 1.0f));
        UI::BeginTabBar("##tab-bar");
            Tab_Seasonal();
            Tab_Totd();
            Tab_Other();
        UI::EndTabBar();
        UI::PopStyleColor(6);
    }
    UI::End();
}

bool Tab_SingleCampaign(Campaign@ campaign, bool selected) {
    bool open = campaign !is null;

    if (!open || !UI::BeginTabItem(campaign.name, open, selected ? UI::TabItemFlags::SetSelected : UI::TabItemFlags::None))
        return open;

    if (UI::BeginTable("##table-campaign-header", 2, UI::TableFlags::SizingStretchProp)) {
        UI::TableSetupColumn("name", UI::TableColumnFlags::WidthStretch);
        UI::TableSetupColumn("count", UI::TableColumnFlags::WidthFixed);

        UI::PushFont(fontHeader);

        UI::TableNextRow();

        UI::TableNextColumn();
        UI::AlignTextToFramePadding();
        UI::SeparatorText(campaign.name);

        UI::TableNextColumn();
        UI::Image(icon32, vec2(scale * 32.0f));
        UI::SameLine();
        UI::Text(tostring(campaign.count) + " / " + campaign.mapsArr.Length + " ");

        UI::PopFont();

        UI::EndTable();
    }

    if (UI::BeginTable("##table-campaign-maps", 5, UI::TableFlags::RowBg | UI::TableFlags::ScrollY | UI::TableFlags::SizingStretchProp)) {
        UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(vec3(0.0f), 0.5f));

        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("Name",    UI::TableColumnFlags::WidthStretch);
        UI::TableSetupColumn("Warrior", UI::TableColumnFlags::WidthFixed, scale * 75.0f);
        UI::TableSetupColumn("PB",      UI::TableColumnFlags::WidthFixed, scale * 75.0f);
        UI::TableSetupColumn("Delta",   UI::TableColumnFlags::WidthFixed, scale * 75.0f);
        UI::TableSetupColumn("Play",    UI::TableColumnFlags::WidthFixed, scale * 30.0f);
        UI::TableHeadersRow();

        for (uint i = 0; i < campaign.mapsArr.Length; i++) {
            WarriorMedals::Map@ map = campaign.mapsArr[i];
            if (map is null)
                continue;

            const uint warrior = map.custom > 0 ? map.custom : map.warrior;

            UI::TableNextRow();

            UI::TableNextColumn();
            UI::AlignTextToFramePadding();
            UI::Text(map.name);

            UI::TableNextColumn();
            UI::Text(Time::Format(warrior));

            UI::TableNextColumn();
            UI::Text(map.pb != uint(-1) ? Time::Format(map.pb) : "");

            UI::TableNextColumn();
            UI::Text(map.pb != uint(-1) ? (map.pb <= warrior ? "\\$77F\u2212" : "\\$F77+") + Time::Format(uint(Math::Abs(map.pb - warrior))) : "");

            UI::TableNextColumn();
            UI::BeginDisabled(map.loading || loading);
            if (UI::Button(Icons::Play + "##" + map.name))
                startnew(PlayMapAsync, @map);
            UI::EndDisabled();
            HoverTooltip("Play " + map.name);
        }

        UI::TableNextRow();

        UI::PopStyleColor();
        UI::EndTable();
    }

    UI::EndTabItem();
    return open;
}

void Tab_Other() {
    if (!UI::BeginTabItem(Icons::QuestionCircle + " Other"))
        return;

    bool selected = false;

    UI::BeginTabBar("##tab-bar-totd");
        if (UI::BeginTabItem(Icons::List + " List")) {
            UI::PushFont(fontHeader);
            UI::SeparatorText("Official");
            UI::PopFont();

            uint index = 0;

            for (uint i = 0; i < campaignsArr.Length; i++) {
                Campaign@ campaign = campaignsArr[i];
                if (campaign is null || campaign.type != WarriorMedals::CampaignType::Other)
                    continue;

                if (index++ % 3 > 0)
                    UI::SameLine();

                if (UI::Button(campaign.name, vec2(scale * 120.0f, scale * 25.0f))) {
                    @activeOtherCampaign = campaign;
                    selected = true;
                }
            }

            // TODO: non-official campaigns if they are added

            UI::EndTabItem();
        }

        if (!Tab_SingleCampaign(activeOtherCampaign, selected))
            @activeOtherCampaign = null;

    UI::EndTabBar();

    UI::EndTabItem();
}

void Tab_Seasonal() {
    if (!UI::BeginTabItem(Icons::SnowflakeO + " Seasonal"))
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
                    UI::PushFont(fontHeader);
                    UI::SeparatorText(tostring(campaign.year + 2020));
                    UI::PopFont();

                    lastYear = campaign.year;
                } else
                    UI::SameLine();

                bool colored = false;
                if (seasonColors.Length == 4 && campaign.colorIndex < 4) {
                    UI::PushStyleColor(UI::Col::Button,        vec4(seasonColors[campaign.colorIndex] - vec3(0.1f), 1.0f));
                    UI::PushStyleColor(UI::Col::ButtonActive,  vec4(seasonColors[campaign.colorIndex] - vec3(0.4f), 1.0f));
                    UI::PushStyleColor(UI::Col::ButtonHovered, vec4(seasonColors[campaign.colorIndex],              1.0f));
                    colored = true;
                }

                if (UI::Button(campaign.name.SubStr(0, campaign.name.Length - 5) + "##" + campaign.name, vec2(scale * 100.0f, scale * 25.0f))) {
                    @activeSeasonalCampaign = @campaign;
                    selected = true;
                }

                if (colored)
                    UI::PopStyleColor(3);
            }

            UI::EndTabItem();
        }

        if (!Tab_SingleCampaign(@activeSeasonalCampaign, selected))
            @activeSeasonalCampaign = null;

    UI::EndTabBar();

    UI::EndTabItem();
}

void Tab_Totd() {
    if (!UI::BeginTabItem(Icons::Calendar + " Track of the Day"))
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
                    lastYear = campaign.year;

                    UI::PushFont(fontHeader);
                    UI::SeparatorText(tostring(campaign.year + 2020));
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

        if (!Tab_SingleCampaign(activeTotdMonth, selected))
            @activeTotdMonth = null;

    UI::EndTabBar();

    UI::EndTabItem();
}
