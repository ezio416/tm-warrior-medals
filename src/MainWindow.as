// c 2024-07-24
// m 2025-02-20

void MainWindow() {
    UI::PushStyleColor(UI::Col::Button,        vec4(colorVec * 0.8f, 1.0f));
    UI::PushStyleColor(UI::Col::ButtonActive,  vec4(colorVec * 0.6f, 1.0f));
    UI::PushStyleColor(UI::Col::ButtonHovered, vec4(colorVec,        1.0f));

    if (UI::BeginTable("##table-main-header", 2, UI::TableFlags::SizingStretchProp)) {
        UI::TableSetupColumn("total",   UI::TableColumnFlags::WidthStretch);
        UI::TableSetupColumn("buttons", UI::TableColumnFlags::WidthFixed);

        UI::TableNextRow();

        UI::TableNextColumn();

        UI::Image(icon32, vec2(scale * 32.0f));

        UI::SameLine();
        UI::PushFont(fontHeader);
        UI::AlignTextToFramePadding();
        UI::Text(tostring(totalHave) + " / " + total);

        if (S_MainWindowPercentages) {
            UI::SameLine();
            UI::Text("\\$888" + Text::Format("%.1f", float(totalHave * 100) / Math::Max(1, total)) + "%");
        }

        UI::PopFont();
        UI::TableNextColumn();

        UI::BeginDisabled(feedbackShown);
        UI::PushStyleColor(UI::Col::Text, S_ColorButtonFont);
        if (UI::Button(Icons::Envelope))
            feedbackShown = true;
        UI::PopStyleColor();
        UI::EndDisabled();
        HoverTooltip("Send feedback to the plugin author (Ezio)");

        UI::SameLine();
        UI::BeginDisabled(API::requesting);
        UI::PushStyleColor(UI::Col::Text, S_ColorButtonFont);
        if (UI::Button(Icons::Refresh))
            startnew(API::GetAllMapInfosAsync);
        UI::PopStyleColor();
        UI::EndDisabled();
        HoverTooltip("Get maps and medals info\nThis does NOT get your PBs");

        if (!getAllClicked) {
            UI::SameLine();
            if (API::Nadeo::requesting) {
                UI::BeginDisabled(API::Nadeo::cancel);
                UI::PushStyleColor(UI::Col::Text, S_ColorButtonFont);
                if (UI::ButtonColored(Icons::Times, 0.0f))
                    API::Nadeo::cancel = true;
                UI::PopStyleColor();
                UI::EndDisabled();

                HoverTooltip(API::Nadeo::allCampaignsProgress);

            } else {
                UI::PushStyleColor(UI::Col::Text, S_ColorButtonFont);
                if (UI::Button(Icons::CloudDownload))
                    startnew(API::Nadeo::GetAllCampaignPBsAsync);
                UI::PopStyleColor();

                HoverTooltip(
                    "Get PBs from Nadeo on all maps"
                    + "\n  This takes about " + Time::Format(campaignsArr.Length * 1100) + " depending on your connection."
                    + "\n  You should only need to do this once. This button will be hidden afterwards."
                );
            }
        }

        UI::EndTable();
    }

    UI::PushStyleColor(UI::Col::Tab,        vec4(colorVec * 0.6f,  1.0f));
    UI::PushStyleColor(UI::Col::TabActive,  vec4(colorVec * 0.85f, 1.0f));
    UI::PushStyleColor(UI::Col::TabHovered, vec4(colorVec * 0.85f, 1.0f));

    UI::BeginTabBar("##tab-bar");
    Tab_Seasonal();
    Tab_Weekly();
    Tab_Totd();
    Tab_Other();
    UI::EndTabBar();

    UI::PopStyleColor(6);
}

void MainWindowDetached() {
    if (false
        || !S_MainWindowDetached
        || (S_MainWindowHideWithGame && !UI::IsGameUIVisible())
        || (S_MainWindowHideWithOP && !UI::IsOverlayShown())
    )
        return;

    if (UI::Begin(
        title,
        S_MainWindowDetached,
        S_MainWindowAutoResize ? UI::WindowFlags::AlwaysAutoResize : UI::WindowFlags::None
    ))
        MainWindow();

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
        UI::Text(tostring(campaign.count) + " / " + campaign.mapsArr.Length);
        if (S_MainWindowPercentages) {
            UI::SameLine();
            UI::Text("\\$888" + Text::Format("%.1f", float(campaign.count * 100) / Math::Max(1, campaign.mapsArr.Length)) + "%");
        }

        UI::PopFont();

        UI::EndTable();
    }

    if (false
        || (S_MainWindowTmioLinks && (campaign.clubId > 0 || campaign.id > 0))
        || S_MainWindowCampRefresh
    ) {
        if (UI::BeginTable("#table-campaign-buttons", 2, UI::TableFlags::SizingStretchProp)) {
            UI::TableSetupColumn("tmio", UI::TableColumnFlags::WidthStretch);
            UI::TableSetupColumn("get",  UI::TableColumnFlags::WidthFixed);

            UI::TableNextRow();

            UI::TableNextColumn();
            UI::PushStyleColor(UI::Col::Text, S_ColorButtonFont);
            if (S_MainWindowTmioLinks) {
                if (campaign.clubId > 0 && UI::Button(Icons::ExternalLink + " Club"))
                    OpenBrowserURL("https://trackmania.io/#/clubs/" + campaign.clubId);

                if (campaign.clubId > 0 && campaign.id > 0)
                    UI::SameLine();

                if (campaign.id > 0 && UI::Button(Icons::ExternalLink + " Campaign")) {
                    const string clubId = campaign.type == WarriorMedals::CampaignType::Seasonal ? "seasonal" : tostring(campaign.clubId);
                    OpenBrowserURL("https://trackmania.io/#/campaigns/" + clubId + "/" + campaign.id);
                }
            }
            UI::PopStyleColor();

            UI::TableNextColumn();
            if (S_MainWindowCampRefresh) {
                UI::BeginDisabled(campaign.requesting || API::Nadeo::requesting);

                UI::PushStyleColor(UI::Col::Text, S_ColorButtonFont);
                if (UI::Button(Icons::CloudDownload + "##single-camp"))
                    startnew(CoroutineFunc(campaign.GetPBsAsync));
                UI::PopStyleColor();
                HoverTooltip("Get PBs");

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
            UI::TableSetupColumn("Play", UI::TableColumnFlags::WidthFixed, scale * 40.0f);
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
                UI::PushStyleColor(UI::Col::Text, S_ColorButtonFont);
                if (UI::Button(Icons::Play + "##" + map.uid))
                    startnew(PlayMapAsync, @map);
                UI::PopStyleColor();
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

            UI::PushStyleColor(UI::Col::Text, S_ColorButtonFont);
            if (UI::Button(campaign.nameStripped + "###button-" + campaign.uid, vec2(scale * 120.0f, scale * 25.0f))) {
                @activeOtherCampaign = @campaign;
                selected = true;
            }
            UI::PopStyleColor();
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

                UI::PushStyleColor(UI::Col::Text, S_ColorButtonFont);
                if (UI::Button(campaign.nameStripped + "###button-" + campaign.uid, vec2(unofficialCampaignMaxLength + scale * 15.0f, scale * 25.0f))) {
                    @activeOtherCampaign = @campaign;
                    selected = true;
                }
                UI::PopStyleColor();
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
                lastYear = campaign.year;

                UI::PushFont(fontHeader);
                UI::SeparatorText(tostring(campaign.year + 2020));
                UI::PopFont();
            } else
                UI::SameLine();

            bool colored = false;
            if (seasonColors.Length == 4 && campaign.colorIndex < 4) {
                UI::PushStyleColor(UI::Col::Button,        vec4(seasonColors[campaign.colorIndex] * 0.9f, 1.0f));
                UI::PushStyleColor(UI::Col::ButtonActive,  vec4(seasonColors[campaign.colorIndex] * 0.6f, 1.0f));
                UI::PushStyleColor(UI::Col::ButtonHovered, vec4(seasonColors[campaign.colorIndex],        1.0f));
                colored = true;
            }

            UI::PushStyleColor(UI::Col::Text, S_ColorButtonFont);
            if (UI::Button(campaign.name.SubStr(0, campaign.name.Length - 5) + "##" + campaign.name, vec2(scale * 100.0f, scale * 25.0f))) {
                @activeSeasonalCampaign = @campaign;
                selected = true;
            }
            UI::PopStyleColor();

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
                UI::PushStyleColor(UI::Col::Button,        vec4(seasonColors[campaign.colorIndex] * 0.9f, 1.0f));
                UI::PushStyleColor(UI::Col::ButtonActive,  vec4(seasonColors[campaign.colorIndex] * 0.6f, 1.0f));
                UI::PushStyleColor(UI::Col::ButtonHovered, vec4(seasonColors[campaign.colorIndex],        1.0f));
                colored = true;
            }

            UI::PushStyleColor(UI::Col::Text, S_ColorButtonFont);
            if (UI::Button(campaign.name.SubStr(0, campaign.name.Length - 5) + "##" + campaign.name, vec2(scale * 100.0f, scale * 25.0f))) {
                @activeTotdMonth = @campaign;
                selected = true;
            }
            UI::PopStyleColor();

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

void Tab_Weekly() {
    if (!UI::BeginTabItem(Icons::ClockO + " Weekly Shorts"))
        return;

    bool selected = false;

    UI::BeginTabBar("##tab-bar-weekly");

    if (UI::BeginTabItem(Icons::List + " List")) {
        uint curWeekInYear = 0;
        uint lastYear      = 0;

        for (uint i = 0; i < campaignsArr.Length; i++) {
            Campaign@ campaign = campaignsArr[i];
            if (campaign is null || campaign.type != WarriorMedals::CampaignType::Weekly)
                continue;

            if (lastYear != campaign.year) {
                lastYear = campaign.year;
                curWeekInYear = 0;

                UI::PushFont(fontHeader);
                UI::SeparatorText(tostring(campaign.year + 2020));
                UI::PopFont();

            } else if (curWeekInYear % 6 > 0)
                UI::SameLine();

            bool colored = false;
            if (campaign.week < 5) {
                const vec3 colorNadeo = vec3(1.0f, 0.8f, 0.1f);
                UI::PushStyleColor(UI::Col::Button,        vec4(colorNadeo * 0.9f, 1.0f));
                UI::PushStyleColor(UI::Col::ButtonActive,  vec4(colorNadeo * 0.6f, 1.0f));
                UI::PushStyleColor(UI::Col::ButtonHovered, vec4(colorNadeo,        1.0f));
                colored = true;
            }

            UI::PushStyleColor(UI::Col::Text, S_ColorButtonFont);
            if (UI::Button(campaign.name, vec2(scale * 60.0f, scale * 25.0f))) {
                @activeWeeklyWeek = @campaign;
                selected = true;
            }
            UI::PopStyleColor();

            if (colored)
                UI::PopStyleColor(3);

            curWeekInYear++;
        }

        UI::EndTabItem();
    }

    if (!Tab_SingleCampaign(@activeWeeklyWeek, selected))
        @activeWeeklyWeek = null;

    UI::EndTabBar();

    UI::EndTabItem();
}
