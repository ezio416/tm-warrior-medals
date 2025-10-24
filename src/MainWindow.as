// c 2024-07-24
// m 2025-10-23

void MainWindow(const bool detached = false) {
    switch (selectedMedal) {
        case Medal::Warrior:
            UI::PushStyleColor(UI::Col::Button,        vec4(colorWarriorVec * 0.8f, 1.0f));
            UI::PushStyleColor(UI::Col::ButtonActive,  vec4(colorWarriorVec * 0.6f, 1.0f));
            UI::PushStyleColor(UI::Col::ButtonHovered, vec4(colorWarriorVec,        1.0f));
            break;
    }

    if (UI::BeginTable("##table-main-header", 2, UI::TableFlags::SizingStretchProp)) {
        UI::TableSetupColumn("total",   UI::TableColumnFlags::WidthStretch);
        UI::TableSetupColumn("buttons", UI::TableColumnFlags::WidthFixed);

        UI::TableNextRow();

        UI::TableNextColumn();
        switch (selectedMedal) {
            case Medal::Warrior:
                IconAndTotals(totalWarriorHave, total);
                break;
        }

        if (false
            or API::requesting
            or API::Nadeo::allPbsNew
        ) {
            UI::PushFont(UI::Font::Default, 26.0f);
            UI::SameLine();
            UI::Text(Shadow() + "\\$888Loading...");
            UI::PopFont();
        }

        UI::TableNextColumn();

        UI::PushStyleColor(UI::Col::Text, S_ColorButtonFont);
        if (UI::Button(Shadow() + Icons::Globe)) {
            OpenBrowserURL("https://e416.dev/warrior-medals");
        }
        UI::PopStyleColor();
        HoverTooltip("Open the Warrior Medals website");

        UI::SameLine();
        UI::BeginDisabled(feedbackShown);
        UI::PushStyleColor(UI::Col::Text, S_ColorButtonFont);
        if (UI::Button(Shadow() + Icons::Envelope)) {
            feedbackShown = true;
        }
        UI::PopStyleColor();
        UI::EndDisabled();
        HoverTooltip("Send feedback to the plugin author (Ezio)");

        UI::SameLine();
        UI::BeginDisabled(false
            or API::requesting
            or API::Nadeo::allPbsNew
        );
        UI::PushStyleColor(UI::Col::Text, S_ColorButtonFont);
        if (UI::Button(Shadow() + Icons::Refresh)) {
            startnew(API::GetAllMapInfosAsync, false);
        }
        UI::PopStyleColor();
        UI::EndDisabled();
        HoverTooltip("Get maps and medals info");

        UI::EndTable();
    }

    switch (selectedMedal) {
        case Medal::Warrior:
            UI::PushStyleColor(UI::Col::Tab,        vec4(colorWarriorVec * 0.6f,  1.0f));
            UI::PushStyleColor(UI::Col::TabActive,  vec4(colorWarriorVec * 0.85f, 1.0f));
            UI::PushStyleColor(UI::Col::TabHovered, vec4(colorWarriorVec * 0.85f, 1.0f));
            break;
    }

    UI::BeginTabBar("##tab-bar");
    Tab_Seasonal(detached);
    Tab_Weekly(detached);
    Tab_Totd(detached);
    Tab_Other(detached);
    UI::EndTabBar();

    UI::PopStyleColor(6);
}

void MainWindowDetached() {
    if (false
        or !S_MainWindowDetached
        or (true
            and S_MainWindowHideWithGame
            and !UI::IsGameUIVisible()
        )
        or (true
            and S_MainWindowHideWithOP
            and !UI::IsOverlayShown()
        )
    ) {
        return;
    }

    if (UI::Begin(
        pluginTitle,
        S_MainWindowDetached,
        S_MainWindowAutoResize ? UI::WindowFlags::AlwaysAutoResize : UI::WindowFlags::None
    )) {
        MainWindow(true);
    }

    UI::End();
}

bool Tab_SingleCampaign(Campaign@ campaign, const bool selected) {
    bool open = campaign !is null;

    if (false
        or !open
        or !UI::BeginTabItem(
            Shadow() + campaign.nameStripped + "###tab-" + campaign.uid,
            open,
            selected ? UI::TabItemFlags::SetSelected : UI::TabItemFlags::None
        )
    ) {
        return open;
    }

    const float scale = UI::GetScale();

    if (UI::BeginTable("##table-campaign-header", 2, UI::TableFlags::SizingStretchProp)) {
        UI::TableSetupColumn("name", UI::TableColumnFlags::WidthStretch);
        UI::TableSetupColumn("count", UI::TableColumnFlags::WidthFixed);

        UI::PushFont(UI::Font::Default, 26.0f);

        UI::TableNextRow();

        UI::TableNextColumn();
        UI::AlignTextToFramePadding();
        UI::SeparatorText(Shadow() + campaign.nameStripped);
        if (true
            and campaign.clubName.Length > 0
            and campaign.clubName != "None"
        ) {
            UI::PushFont(UI::Font::Default, 16.0f);
            HoverTooltip("from the club \"" + WarriorMedals::OpenplanetFormatCodes(campaign.clubName) + "\\$Z\"");
            UI::PopFont();
        }

        UI::TableNextColumn();
        IconAndTotals(campaign.countWarrior, campaign.mapsArr.Length);

        UI::PopFont();

        UI::EndTable();
    }

    const bool totd = campaign.type == WarriorMedals::CampaignType::TrackOfTheDay;

    if (false
        or S_MainWindowCampRefresh
        or (true
            and S_MainWindowTmioLinks
            and (false
                or campaign.clubId > 0
                or campaign.id > 0
                or totd
            )
        )
    ) {
        if (UI::BeginTable("#table-campaign-buttons", 2, UI::TableFlags::SizingStretchProp)) {
            UI::TableSetupColumn("tmio", UI::TableColumnFlags::WidthStretch);
            UI::TableSetupColumn("get",  UI::TableColumnFlags::WidthFixed);

            UI::TableNextRow();

            UI::TableNextColumn();
            UI::PushStyleColor(UI::Col::Text, S_ColorButtonFont);
            if (S_MainWindowTmioLinks) {
                if (true
                    and campaign.clubId > 0
                    and UI::Button(Shadow() + Icons::ExternalLink + " Club")
                ) {
                    OpenBrowserURL("https://trackmania.io/#/clubs/" + campaign.clubId);
                }

                if (true
                    and campaign.clubId > 0
                    and campaign.id > 0
                ) {
                    UI::SameLine();
                }

                if (true
                    and (false
                        or totd
                        or campaign.id > 0
                    )
                    and UI::Button(Shadow() + Icons::ExternalLink + " Campaign")
                ) {
                    if (totd) {
                        OpenBrowserURL("https://trackmania.io/#/totd/" + (campaign.year + 2020) + "-" + campaign.month);
                    } else {
                        string clubId;
                        switch (campaign.type) {
                            case WarriorMedals::CampaignType::Seasonal:
                                clubId = "seasonal";
                                break;

                            case WarriorMedals::CampaignType::Weekly:
                                clubId = "weekly";
                                break;

                            default:
                                clubId = tostring(campaign.clubId);
                        }

                        OpenBrowserURL("https://trackmania.io/#/campaigns/" + clubId + "/" + campaign.id);
                    }
                }
            }
            UI::PopStyleColor();

            UI::TableNextColumn();
            if (S_MainWindowCampRefresh) {
                UI::BeginDisabled(false
                    or campaign.requesting
                    or API::Nadeo::requesting
                );

                UI::PushStyleColor(UI::Col::Text, S_ColorButtonFont);
                if (UI::Button(Shadow() + Icons::CloudDownload + "##single-camp")) {
                    startnew(CoroutineFunc(campaign.GetPBsAsync));
                }
                UI::PopStyleColor();
                HoverTooltip("Get PBs");

                UI::EndDisabled();
            }

            UI::EndTable();
        }
    }

    if (UI::BeginTable("##table-campaign-maps", hasPlayPermission ? 6 : 5, UI::TableFlags::RowBg | UI::TableFlags::ScrollY | UI::TableFlags::SizingStretchProp)) {
        UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(vec3(), 0.5f));

        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("Name",    UI::TableColumnFlags::WidthStretch);
        switch (selectedMedal) {
            case Medal::Warrior:
                UI::TableSetupColumn("Warrior", UI::TableColumnFlags::WidthFixed, scale * 75.0f);
                break;
        }
        UI::TableSetupColumn("PB",      UI::TableColumnFlags::WidthFixed, scale * 75.0f);
        UI::TableSetupColumn("Delta",   UI::TableColumnFlags::WidthFixed, scale * 75.0f);
        if (hasPlayPermission) {
            UI::TableSetupColumn("Play", UI::TableColumnFlags::WidthFixed, scale * 35.0f);
        }
        UI::TableSetupColumn("Tmio", UI::TableColumnFlags::WidthFixed, scale * 35.0f);
        UI::TableHeadersRow();

        for (uint i = 0; i < campaign.mapsArr.Length; i++) {
            WarriorMedals::Map@ map = campaign.mapsArr[i];
            if (map is null) {
                continue;
            }

            UI::TableNextRow();

            UI::TableNextColumn();
            UI::AlignTextToFramePadding();
            UI::Text(Shadow() + map.nameStripped);
            if (map.campaignType == WarriorMedals::CampaignType::TrackOfTheDay) {
                HoverTooltip(map.date);
            }
            if (map.reason.Length > 0) {
                UI::SameLine();
                HoverTooltipSetting(
                    "modified, reason: '" + map.reason + "'"
                );
            }

            UI::TableNextColumn();
            UI::Text(Shadow() + Time::Format(map.warrior));

            UI::TableNextColumn();
            UI::Text(Shadow() + (map.pb != uint(-1) ? Time::Format(map.pb) : ""));

            UI::TableNextColumn();
            switch (selectedMedal) {
                case Medal::Warrior:
                    UI::Text(
                        Shadow() + (map.pb != uint(-1) ? (map.pb <= map.warrior ? "\\$77F\u2212" : "\\$F77+")
                        + Time::Format(uint(Math::Abs(map.pb - map.warrior))) : "")
                    );
                    break;
            }

            if (hasPlayPermission) {
                UI::TableNextColumn();
                UI::BeginDisabled(false
                    or map.loading
                    or loading
                );
                UI::PushStyleColor(UI::Col::Text, S_ColorButtonFont);
                if (UI::Button(Shadow() + Icons::Play + "##" + map.uid)) {
                    startnew(PlayMapAsync, map);
                }
                UI::PopStyleColor();
                UI::EndDisabled();
                HoverTooltip("Play " + map.nameStripped);
            }

            UI::TableNextColumn();
            if (UI::Button(Shadow() + Icons::Heartbeat + "##" + map.uid)) {
                OpenBrowserURL("https://trackmania.io/#/leaderboard/" + map.uid);
            }
        }

        UI::TableNextRow();

        UI::PopStyleColor();
        UI::EndTable();
    }

    UI::EndTabItem();

    return open;
}

void Tab_Other(const bool detached = false) {
    if (!UI::BeginTabItem(Shadow() + Icons::QuestionCircle + " Other###tab-other")) {
        return;
    }

    const float scale = UI::GetScale();
    int selected = -2;

    TypeTotals(WarriorMedals::CampaignType::Other);

    UI::BeginTabBar("##tab-bar-totd");

    if (UI::BeginTabItem(Shadow() + Icons::List + " List")) {
        if (!detached) {
            UI::BeginChild("##child-list-other");
        }

        UI::PushFont(UI::Font::Default, 26.0f);
        UI::SeparatorText(Shadow() + "Official");
        UI::PopFont();

        uint index = 0;

        dictionary uniqueClubs;
        Campaign@[] unofficialCampaigns;

        float unofficialCampaignMaxLength = 0.0f;

        for (uint i = 0; i < campaignsArr.Length; i++) {
            Campaign@ campaign = campaignsArr[i];
            if (false
                or campaign is null
                or campaign.type != WarriorMedals::CampaignType::Other
            ) {
                continue;
            }

            if (!campaign.official) {
                uniqueClubs.Set(campaign.clubName, 0);
                unofficialCampaigns.InsertLast(campaign);
                unofficialCampaignMaxLength = Math::Max(unofficialCampaignMaxLength, Draw::MeasureString(campaign.nameStripped).x);
                continue;
            }

            if (index++ % 3 > 0) {
                UI::SameLine();
            }

            UI::PushStyleColor(UI::Col::Text, S_ColorButtonFont);
            if (UI::Button(Shadow() + campaign.nameStripped + "###button-" + campaign.uid, vec2(scale * 120.0f, scale * 25.0f))) {
                const int index2 = activeOtherCampaigns.FindByRef(campaign);
                if (index2 > -1) {
                    activeOtherCampaigns.RemoveAt(index2);
                }
                activeOtherCampaigns.InsertLast(campaign);
                selected = activeOtherCampaigns.Length - 1;
            }
            UI::PopStyleColor();
            switch (selectedMedal) {
                case Medal::Warrior:
                    UI::SetItemTooltip(tostring(campaign.countWarrior) + " / " + campaign.mapsArr.Length);
                    break;
            }
        }

        const string[]@ clubs = uniqueClubs.GetKeys();
        for (uint i = 0; i < clubs.Length; i++) {
            const string clubName = clubs[i];

            UI::PushFont(UI::Font::Default, 26.0f);
            UI::SeparatorText(Shadow() + WarriorMedals::StripFormatCodes(clubName));
            UI::PopFont();

            index = 0;

            for (uint j = 0; j < unofficialCampaigns.Length; j++) {  // inefficient but whatever
                Campaign@ campaign = unofficialCampaigns[j];
                if (campaign.clubName != clubName) {
                    continue;
                }

                if (index++ % 3 > 0) {
                    UI::SameLine();
                }

                UI::PushStyleColor(UI::Col::Text, S_ColorButtonFont);
                if (UI::Button(Shadow() + campaign.nameStripped + "###button-" + campaign.uid, vec2(unofficialCampaignMaxLength + scale * 15.0f, scale * 25.0f))) {
                    const int index2 = activeOtherCampaigns.FindByRef(campaign);
                    if (index2 > -1) {
                        activeOtherCampaigns.RemoveAt(index2);
                    }
                    activeOtherCampaigns.InsertLast(campaign);
                    selected = activeOtherCampaigns.Length - 1;
                }
                UI::PopStyleColor();
                switch (selectedMedal) {
                    case Medal::Warrior:
                        UI::SetItemTooltip(tostring(campaign.countWarrior) + " / " + campaign.mapsArr.Length);
                        break;
                }
            }
        }

        if (!detached) {
            UI::EndChild();
        }

        UI::EndTabItem();
    }

    for (int i = 0; i < int(activeOtherCampaigns.Length); i++) {
        if (!Tab_SingleCampaign(activeOtherCampaigns[i], i == selected)) {
            activeOtherCampaigns.RemoveAt(i);
            i--;
        }
    }

    UI::EndTabBar();

    UI::EndTabItem();
}

void Tab_Seasonal(const bool detached = false) {
    if (!UI::BeginTabItem(Shadow() + Icons::SnowflakeO + " Seasonal###tab-seasonal")) {
        return;
    }

    const float scale = UI::GetScale();
    int selected = -2;

    TypeTotals(WarriorMedals::CampaignType::Seasonal);

    UI::BeginTabBar("##tab-bar-seasonal");

    if (UI::BeginTabItem(Shadow() + Icons::List + " List")) {
        if (!detached) {
            UI::BeginChild("##child-list-seasonal");
        }

        int lastYear = -1;

        Campaign@[]@ arr = S_MainWindowOldestFirst ? campaignsArrRev : campaignsArr;
        for (uint i = 0; i < arr.Length; i++) {
            Campaign@ campaign = arr[i];
            if (false
                or campaign is null
                or campaign.type != WarriorMedals::CampaignType::Seasonal
            ) {
                continue;
            }

            if (uint(lastYear) != campaign.year) {
                lastYear = campaign.year;

                UI::PushFont(UI::Font::Default, 26.0f);
                UI::SeparatorText(Shadow() + tostring(campaign.year + 2020));
                UI::PopFont();
            } else {
                UI::SameLine();
            }

            bool colored = false;
            if (true
                and seasonColors.Length == 4
                and campaign.colorIndex < 4
            ) {
                UI::PushStyleColor(UI::Col::Button,        vec4(seasonColors[campaign.colorIndex] * 0.9f, 1.0f));
                UI::PushStyleColor(UI::Col::ButtonActive,  vec4(seasonColors[campaign.colorIndex] * 0.6f, 1.0f));
                UI::PushStyleColor(UI::Col::ButtonHovered, vec4(seasonColors[campaign.colorIndex],        1.0f));
                colored = true;
            }

            UI::PushStyleColor(UI::Col::Text, S_ColorButtonFont);
            if (UI::Button(Shadow() + campaign.name.SubStr(0, campaign.name.Length - 5) + "##" + campaign.name, vec2(scale * 100.0f, scale * 25.0f))) {
                const int index = activeSeasonalCampaigns.FindByRef(campaign);
                if (index > -1) {
                    activeSeasonalCampaigns.RemoveAt(index);
                }
                activeSeasonalCampaigns.InsertLast(campaign);
                selected = activeSeasonalCampaigns.Length - 1;
            }
            UI::PopStyleColor();
            switch (selectedMedal) {
                case Medal::Warrior:
                    UI::SetItemTooltip(tostring(campaign.countWarrior) + " / " + campaign.mapsArr.Length);
                    break;
            }

            if (colored) {
                UI::PopStyleColor(3);
            }
        }

        if (!detached) {
            UI::EndChild();
        }

        UI::EndTabItem();
    }

    for (int i = 0; i < int(activeSeasonalCampaigns.Length); i++) {
        if (!Tab_SingleCampaign(activeSeasonalCampaigns[i], i == selected)) {
            activeSeasonalCampaigns.RemoveAt(i);
            i--;
        }
    }

    UI::EndTabBar();

    UI::EndTabItem();
}

void Tab_Totd(const bool detached = false) {
    if (!UI::BeginTabItem(Shadow() + Icons::Calendar + " Track of the Day###tab-totd")) {
        return;
    }

    const float scale = UI::GetScale();
    int selected = -2;

    TypeTotals(WarriorMedals::CampaignType::TrackOfTheDay);

    UI::BeginTabBar("##tab-bar-totd");

    if (UI::BeginTabItem(Shadow() + Icons::List + " List")) {
        if (!detached) {
            UI::BeginChild("##child-list-totd");
        }

        uint curMonthInYear = 0;
        int  lastYear       = -1;

        Campaign@[]@ arr = S_MainWindowOldestFirst ? campaignsArrRev : campaignsArr;
        for (uint i = 0; i < arr.Length; i++) {
            Campaign@ campaign = arr[i];
            if (false
                or campaign is null
                or campaign.type != WarriorMedals::CampaignType::TrackOfTheDay
            ) {
                continue;
            }

            if (uint(lastYear) != campaign.year) {
                lastYear = campaign.year;
                curMonthInYear = 0;

                UI::PushFont(UI::Font::Default, 26.0f);
                UI::SeparatorText(Shadow() + tostring(campaign.year + 2020));
                UI::PopFont();
            } else if (curMonthInYear % 3 > 0) {
                UI::SameLine();
            }

            bool colored = false;
            if (true
                and seasonColors.Length == 4
                and campaign.colorIndex < 4
            ) {
                UI::PushStyleColor(UI::Col::Button,        vec4(seasonColors[campaign.colorIndex] * 0.9f, 1.0f));
                UI::PushStyleColor(UI::Col::ButtonActive,  vec4(seasonColors[campaign.colorIndex] * 0.6f, 1.0f));
                UI::PushStyleColor(UI::Col::ButtonHovered, vec4(seasonColors[campaign.colorIndex],        1.0f));
                colored = true;
            }

            UI::PushStyleColor(UI::Col::Text, S_ColorButtonFont);
            if (UI::Button(Shadow() + campaign.name.SubStr(0, campaign.name.Length - 5) + "##" + campaign.name, vec2(scale * 137.0f, scale * 25.0f))) {
                const int index = activeTotdMonths.FindByRef(campaign);
                if (index > -1) {
                    activeTotdMonths.RemoveAt(index);
                }
                activeTotdMonths.InsertLast(campaign);
                selected = activeTotdMonths.Length - 1;
            }
            UI::PopStyleColor();
            switch (selectedMedal) {
                case Medal::Warrior:
                    UI::SetItemTooltip(tostring(campaign.countWarrior) + " / " + campaign.mapsArr.Length);
                    break;
            }

            if (colored) {
                UI::PopStyleColor(3);
            }

            curMonthInYear++;
        }

        if (!detached) {
            UI::EndChild();
        }

        UI::EndTabItem();
    }

    for (int i = 0; i < int(activeTotdMonths.Length); i++) {
        if (!Tab_SingleCampaign(activeTotdMonths[i], i == selected)) {
            activeTotdMonths.RemoveAt(i);
            i--;
        }
    }

    UI::EndTabBar();

    UI::EndTabItem();
}

void Tab_Weekly(const bool detached = false) {
    if (!UI::BeginTabItem(Shadow() + Icons::ClockO + " Weekly Shorts###tab-weekly")) {
        return;
    }

    const float scale = UI::GetScale();
    int selected = -2;

    TypeTotals(WarriorMedals::CampaignType::Weekly);

    UI::BeginTabBar("##tab-bar-weekly");

    if (UI::BeginTabItem(Shadow() + Icons::List + " List")) {
        if (!detached) {
            UI::BeginChild("##child-list-weekly");
        }

        uint curWeekInYear = 0;
        int  lastYear      = -1;

        Campaign@[]@ arr = S_MainWindowOldestFirst ? campaignsArrRev : campaignsArr;
        for (uint i = 0; i < arr.Length; i++) {
            Campaign@ campaign = arr[i];
            if (false
                or campaign is null
                or campaign.type != WarriorMedals::CampaignType::Weekly
            ) {
                continue;
            }

            if (uint(lastYear) != campaign.year) {
                lastYear = campaign.year;
                curWeekInYear = 0;

                UI::PushFont(UI::Font::Default, 26.0f);
                UI::SeparatorText(Shadow() + tostring(campaign.year + 2020));
                UI::PopFont();

            } else if (curWeekInYear % 5 > 0) {
                UI::SameLine();
            }

            bool colored = false;
            if (false
                or campaign.week < 5
                or campaign.week == 29
            ) {
                const vec3 colorNadeo = vec3(1.0f, 0.75f, 0.1f);
                UI::PushStyleColor(UI::Col::Button,        vec4(colorNadeo * 0.9f, 1.0f));
                UI::PushStyleColor(UI::Col::ButtonActive,  vec4(colorNadeo * 0.6f, 1.0f));
                UI::PushStyleColor(UI::Col::ButtonHovered, vec4(colorNadeo,        1.0f));
                colored = true;
            }

            UI::PushStyleColor(UI::Col::Text, S_ColorButtonFont);
            if (UI::Button(Shadow() + campaign.name, vec2(scale * 78.0f, scale * 25.0f))) {
                const int index = activeWeeklyWeeks.FindByRef(campaign);
                if (index > -1) {
                    activeWeeklyWeeks.RemoveAt(index);
                }
                activeWeeklyWeeks.InsertLast(campaign);
                selected = activeWeeklyWeeks.Length - 1;
            }
            UI::PopStyleColor();
            switch (selectedMedal) {
                case Medal::Warrior:
                    UI::SetItemTooltip(tostring(campaign.countWarrior) + " / " + campaign.mapsArr.Length);
                    break;
            }

            if (colored) {
                UI::PopStyleColor(3);
            }

            curWeekInYear++;
        }

        if (!detached) {
            UI::EndChild();
        }

        UI::EndTabItem();
    }

    for (int i = 0; i < int(activeWeeklyWeeks.Length); i++) {
        if (!Tab_SingleCampaign(activeWeeklyWeeks[i], i == selected)) {
            activeWeeklyWeeks.RemoveAt(i);
            i--;
        }
    }

    UI::EndTabBar();

    UI::EndTabItem();
}

void TypeTotals(const WarriorMedals::CampaignType type) {
    if (S_MainWindowTypeTotals) {
        uint total = 0;
        uint totalHave = 0;

        switch (type) {
            case WarriorMedals::CampaignType::Other:
                switch (selectedMedal) {
                    case Medal::Warrior:
                        total = totalWarriorOther;
                        totalHave = totalWarriorOtherHave;
                        break;
                }
                break;

            case WarriorMedals::CampaignType::Seasonal:
                switch (selectedMedal) {
                    case Medal::Warrior:
                        total = totalWarriorSeasonal;
                        totalHave = totalWarriorSeasonalHave;
                        break;
                }
                break;

            case WarriorMedals::CampaignType::TrackOfTheDay:
                switch (selectedMedal) {
                    case Medal::Warrior:
                        total = totalWarriorTotd;
                        totalHave = totalWarriorTotdHave;
                        break;
                }
                break;

            case WarriorMedals::CampaignType::Weekly:
                switch (selectedMedal) {
                    case Medal::Warrior:
                        total = totalWarriorWeekly;
                        totalHave = totalWarriorWeeklyHave;
                        break;
                }
                break;
        }

        IconAndTotals(totalHave, total);
    }
}

void IconAndTotals(const uint totalHave, const uint total) {
    switch (selectedMedal) {
        case Medal::Warrior:
            UI::Image(iconWarrior32, vec2(UI::GetScale() * 32.0f));
            break;
    }

    UI::SameLine();
    UI::PushFont(UI::Font::Default, 26.0f);
    UI::AlignTextToFramePadding();

    const bool colorText = true
        and totalHave > 0
        and totalHave == total
    ;

    if (colorText) {
        switch (selectedMedal) {
            case Medal::Warrior:
                UI::PushStyleColor(UI::Col::Text, vec4(colorWarriorVec, 1.0f));
                break;
        }
    }
    UI::Text(Shadow() + totalHave + " / " + total);
    if (colorText) {
        UI::PopStyleColor();
    }

    if (S_MainWindowPercentages) {
        UI::SameLine();
        if (colorText) {
            switch (selectedMedal) {
                case Medal::Warrior:
                    UI::PushStyleColor(UI::Col::Text, vec4(colorWarriorVec, 0.4f));
                    break;
            }
        } else {
            UI::PushStyleColor(UI::Col::Text, vec4(0.5f));
        }
        UI::Text(Shadow() + Text::Format("%.1f", float(totalHave * 100) / Math::Max(1, total)) + "%");
        UI::PopStyleColor();
    }

    UI::PopFont();
}
