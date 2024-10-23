// c 2024-07-24
// m 2024-10-23

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

        if (UI::BeginTable("##table-main-header", 2, UI::TableFlags::SizingStretchProp)) {
            UI::TableSetupColumn("refresh", UI::TableColumnFlags::WidthStretch);
            UI::TableSetupColumn("total",   UI::TableColumnFlags::WidthFixed);

            UI::TableNextRow();

            UI::TableNextColumn();
            UI::PushFont(fontHeader);
            UI::Image(icon32, vec2(scale * 32.0f));
            UI::SameLine();
            UI::AlignTextToFramePadding();
            UI::Text(tostring(totalHave) + " / " + total);
            UI::PopFont();

            UI::TableNextColumn();

            UI::BeginDisabled(API::getting);
            if (UI::Button(Icons::Refresh + " Refresh" + (API::getting  ? "ing..." : "")))
                startnew(API::GetAllMapInfosAsync);
            HoverTooltip("Maps and medals info");
            UI::EndDisabled();

            UI::SameLine();
            if (API::Nadeo::requesting) {
                if (UI::ButtonColored(Icons::Times + " Cancel", 0.0f))
                    API::Nadeo::cancel = true;
                HoverTooltip(API::Nadeo::allCampaignsProgress);
            } else if (!API::Nadeo::requesting) {
                if (UI::Button(Icons::CloudDownload + " Get PBs"))
                    startnew(API::Nadeo::GetAllCampaignPBsAsync);
                HoverTooltip("On all maps (takes about " + Time::Format(campaignsArr.Length * 1100) + ")");
            }

            UI::EndTable();
        }

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

    if (!open || !UI::BeginTabItem(campaign.nameStripped + "###tab-" + campaign.uid, open, selected ? UI::TabItemFlags::SetSelected : UI::TabItemFlags::None))
        return open;

    if (UI::BeginTable("##table-campaign-header", 2, UI::TableFlags::SizingStretchProp)) {
        UI::TableSetupColumn("name", UI::TableColumnFlags::WidthStretch);
        UI::TableSetupColumn("count", UI::TableColumnFlags::WidthFixed);

        UI::PushFont(fontHeader);

        UI::TableNextRow();

        UI::TableNextColumn();
        UI::AlignTextToFramePadding();
        UI::SeparatorText(campaign.nameStripped);
        if (campaign.clubName.Length > 0) {
            UI::PopFont();
            HoverTooltip("from the club \"" + WarriorMedals::OpenplanetFormatCodes(campaign.clubName) + "\\$Z\"");
            UI::PushFont(fontHeader);
        }

        UI::TableNextColumn();
        UI::Image(icon32, vec2(scale * 32.0f));
        UI::SameLine();
        UI::Text(tostring(campaign.count) + " / " + campaign.mapsArr.Length + " ");

        UI::PopFont();

        UI::EndTable();
    }

    if (S_MainWindowTmioLinks || S_MainWindowCampRefresh) {
        if (UI::BeginTable("#table-campaign-buttons", 2, UI::TableFlags::SizingStretchProp)) {
            UI::TableSetupColumn("tmio", UI::TableColumnFlags::WidthStretch);
            UI::TableSetupColumn("get",  UI::TableColumnFlags::WidthFixed);

            UI::TableNextRow();

            UI::TableNextColumn();
            if (S_MainWindowTmioLinks) {
                if (campaign.clubId > 0 && UI::Button(Icons::ExternalLink + " Club"))
                    OpenBrowserURL("https://trackmania.io/#/clubs/" + campaign.clubId);

                if (campaign.clubId > 0 && campaign.id > 0)
                    UI::SameLine();

                if (campaign.id > 0 && UI::Button(Icons::ExternalLink + " Campaign"))
                    OpenBrowserURL("https://trackmania.io/#/campaigns/" + campaign.clubId + "/" + campaign.id);
            }

            UI::TableNextColumn();
            if (S_MainWindowCampRefresh) {
                UI::BeginDisabled(campaign.requesting);

                if (UI::Button(Icons::Refresh))
                    startnew(CoroutineFunc(campaign.GetPBsAsync));
                HoverTooltip("Refresh PBs");

                UI::EndDisabled();
            }

            UI::EndTable();
        }
    }

    if (UI::BeginTable("##table-campaign-maps", hasPlayPermission ? 5 : 4, UI::TableFlags::RowBg | UI::TableFlags::ScrollY | UI::TableFlags::SizingStretchProp)) {
        UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(vec3(), 0.5f));

        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("Name",    UI::TableColumnFlags::WidthStretch);
        UI::TableSetupColumn("Warrior", UI::TableColumnFlags::WidthFixed, scale * 75.0f);
        UI::TableSetupColumn("PB",      UI::TableColumnFlags::WidthFixed, scale * 75.0f);
        UI::TableSetupColumn("Delta",   UI::TableColumnFlags::WidthFixed, scale * 75.0f);
        if (hasPlayPermission)
            UI::TableSetupColumn("Play", UI::TableColumnFlags::WidthFixed, scale * 30.0f);
        UI::TableHeadersRow();

        for (uint i = 0; i < campaign.mapsArr.Length; i++) {
            WarriorMedals::Map@ map = campaign.mapsArr[i];
            if (map is null)
                continue;

            const uint warrior = map.custom > 0 ? map.custom : map.warrior;

            UI::TableNextRow();

            UI::TableNextColumn();
            UI::AlignTextToFramePadding();
            UI::Text(map.nameStripped);
            if (map.campaignType == WarriorMedals::CampaignType::TrackOfTheDay)
                HoverTooltip(map.date);

            UI::TableNextColumn();
            UI::Text(Time::Format(warrior));

            UI::TableNextColumn();
            UI::Text(map.pb != uint(-1) ? Time::Format(map.pb) : "");

            UI::TableNextColumn();
            UI::Text(map.pb != uint(-1) ? (map.pb <= warrior ? "\\$77F\u2212" : "\\$F77+") + Time::Format(uint(Math::Abs(map.pb - warrior))) : "");

            if (hasPlayPermission) {
                UI::TableNextColumn();
                UI::BeginDisabled(map.loading || loading);
                if (UI::Button(Icons::Play + "##" + map.uid))
                    startnew(PlayMapAsync, @map);
                UI::EndDisabled();
                HoverTooltip("Play " + map.nameStripped);
            }
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

        dictionary@ uniqueClubs = dictionary();
        Campaign@[] unofficialCampaigns;

        float unofficialCampaignMaxLength = 0.0f;

        for (uint i = 0; i < campaignsArr.Length; i++) {
        // for (int i = campaignsArr.Length - 1; i >= 0; i--) {
            Campaign@ campaign = campaignsArr[i];
            if (campaign is null || campaign.type != WarriorMedals::CampaignType::Other)
                continue;

            if (!campaign.official) {
                uniqueClubs.Set(campaign.clubName, 0);
                unofficialCampaigns.InsertLast(campaign);
                unofficialCampaignMaxLength = Math::Max(unofficialCampaignMaxLength, Draw::MeasureString(campaign.nameStripped).x);
                continue;
            }

            if (index++ % 3 > 0)
                UI::SameLine();

            if (UI::Button(campaign.nameStripped + "###button-" + campaign.uid, vec2(scale * 120.0f, scale * 25.0f))) {
                @activeOtherCampaign = @campaign;
                selected = true;
            }
        }

        const string[]@ clubs = uniqueClubs.GetKeys();
        for (uint i = 0; i < clubs.Length; i++) {
            const string clubName = clubs[i];

            UI::PushFont(fontHeader);
            UI::SeparatorText(WarriorMedals::StripFormatCodes(clubName));
            UI::PopFont();

            index = 0;

            for (uint j = 0; j < unofficialCampaigns.Length; j++) {  // inefficient but whatever
                Campaign@ campaign = unofficialCampaigns[j];
                if (campaign.clubName != clubName)
                    continue;

                if (index++ % 3 > 0)
                    UI::SameLine();

                if (UI::Button(campaign.nameStripped + "###button-" + campaign.uid, vec2(scale * unofficialCampaignMaxLength * 0.9f, scale * 25.0f))) {
                    @activeOtherCampaign = @campaign;
                    selected = true;
                }
            }
        }

        UI::EndTabItem();
    }

    if (!Tab_SingleCampaign(@activeOtherCampaign, selected))
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
                    @activeTotdMonth = @campaign;
                    selected = true;
                }

                if (colored)
                    UI::PopStyleColor(3);

                if ((campaign.month - 1) % 3 > 0)
                    UI::SameLine();
            }

            UI::EndTabItem();
        }

        if (!Tab_SingleCampaign(@activeTotdMonth, selected))
            @activeTotdMonth = null;

    UI::EndTabBar();

    UI::EndTabItem();
}
