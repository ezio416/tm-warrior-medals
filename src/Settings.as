// c 2024-07-17
// m 2025-07-26

[Setting hidden category="Colors"]       vec3 S_ColorFall                  = vec3(1.0f, 0.5f, 0.0f);
[Setting hidden category="Colors"]       vec3 S_ColorSpring                = vec3(0.3f, 0.9f, 0.3f);
[Setting hidden category="Colors"]       vec3 S_ColorSummer                = vec3(1.0f, 0.8f, 0.0f);
[Setting hidden category="Colors"]       vec3 S_ColorWinter                = vec3(0.0f, 0.8f, 1.0f);
[Setting hidden category="Colors"]       vec4 S_ColorButtonFont            = vec4(1.0f);

[Setting hidden category="Main Window"]  bool S_MainWindowAutoResize       = false;
[Setting hidden category="Main Window"]  bool S_MainWindowCampRefresh      = true;
[Setting hidden category="Main Window"]  bool S_MainWindowDetached         = false;
[Setting hidden category="Main Window"]  bool S_MainWindowHideWithGame     = true;
[Setting hidden category="Main Window"]  bool S_MainWindowHideWithOP       = true;
[Setting hidden category="Main Window"]  bool S_MainWindowOldestFirst      = false;
[Setting hidden category="Main Window"]  bool S_MainWindowPercentages      = true;
[Setting hidden category="Main Window"]  bool S_MainWindowTextShadows      = true;
[Setting hidden category="Main Window"]  bool S_MainWindowTmioLinks        = true;
[Setting hidden category="Main Window"]  bool S_MainWindowTypeTotals       = true;

[Setting hidden category="Medal Window"] bool S_MedalWindow                = true;
[Setting hidden category="Medal Window"] bool S_MedalWindowDelta           = true;
[Setting hidden category="Medal Window"] bool S_MedalWindowHideWithGame    = true;
[Setting hidden category="Medal Window"] bool S_MedalWindowHideWithOP      = false;
[Setting hidden category="Medal Window"] bool S_MedalWindowIcon            = true;
[Setting hidden category="Medal Window"] bool S_MedalWindowName            = true;

[Setting hidden category="UI Medals"]    bool S_UIMedals                   = true;
[Setting hidden category="UI Medals"]    bool S_UIMedalBanner              = true;
[Setting hidden category="UI Medals"]    bool S_UIMedalEnd                 = true;
[Setting hidden category="UI Medals"]    bool S_UIMedalPause               = true;
/*[Setting hidden category="UI Medals"]*/bool S_UIMedalsAlwaysMenu         = false;
/*[Setting hidden category="UI Medals"]*/bool S_UIMedalsAlwaysPlayground   = false;
[Setting hidden category="UI Medals"]    bool S_UIMedalsClubCampaign       = true;
[Setting hidden category="UI Medals"]    bool S_UIMedalsLiveCampaign       = true;
[Setting hidden category="UI Medals"]    bool S_UIMedalsLiveTotd           = false;
[Setting hidden category="UI Medals"]    bool S_UIMedalsSeasonalCampaign   = true;
[Setting hidden category="UI Medals"]    bool S_UIMedalsSoloMenu           = true;
[Setting hidden category="UI Medals"]    bool S_UIMedalStart               = true;
[Setting hidden category="UI Medals"]    bool S_UIMedalsTotd               = true;
[Setting hidden category="UI Medals"]    bool S_UIMedalsWeekly             = true;

[SettingsTab name="General" icon="Cogs"]
void Settings_General() {
    const float scale = UI::GetScale();
    const float indent = scale * 15.0f;

    UI::PushFont(UI::Font::Default, 26.0f);
    UI::Text("Main Window");
    UI::PopFont();

    if (UI::Button("Reset to default##mainwindow")) {
        Meta::PluginSetting@[]@ settings = pluginMeta.GetSettings();
        for (uint i = 0; i < settings.Length; i++) {
            if (settings[i].Category == "Main Window") {
                settings[i].Reset();
            }
        }
    }

    if ((S_MainWindowDetached = UI::Checkbox("Show a detached main window", S_MainWindowDetached))) {
        UI::Indent(indent);

        S_MainWindowHideWithGame = UI::Checkbox(
            "Show/hide with game UI##main",
            S_MainWindowHideWithGame
        );

        S_MainWindowHideWithOP = UI::Checkbox(
            "Show/hide with Openplanet UI##main",
            S_MainWindowHideWithOP
        );

        S_MainWindowAutoResize = UI::Checkbox(
            "Auto-resize",
            S_MainWindowAutoResize
        );

        UI::Indent(-indent);
    }

    S_MainWindowTmioLinks = UI::Checkbox(
        "Show Trackmania.io buttons on campaigns",
        S_MainWindowTmioLinks
    );

    S_MainWindowCampRefresh = UI::Checkbox(
        "Show PB refresh button on campaigns",
        S_MainWindowCampRefresh
    );

    S_MainWindowTypeTotals = UI::Checkbox(
        "Show totals per campaign type",
        S_MainWindowTypeTotals
    );
    HoverTooltipSetting("Seasonal, Totd, etc.");

    S_MainWindowPercentages = UI::Checkbox(
        "Show percentages",
        S_MainWindowPercentages
    );

    S_MainWindowOldestFirst = UI::Checkbox(
        "Sort campaigns oldest to newest",
        S_MainWindowOldestFirst
    );
    HoverTooltipSetting("Seasonal, Weekly Shorts, Track of the Day");

    S_MainWindowTextShadows = UI::Checkbox(
        "Show text shadows",
        S_MainWindowTextShadows
    );

    UI::Separator();

    UI::PushFont(UI::Font::Default, 26.0f);
    UI::Text("Medal Window");
    UI::PopFont();

    if (UI::Button("Reset to default##medalwindow")) {
        Meta::PluginSetting@[]@ settings = pluginMeta.GetSettings();
        for (uint i = 0; i < settings.Length; i++) {
            if (settings[i].Category == "Medal Window") {
                settings[i].Reset();
            }
        }
    }

    if ((S_MedalWindow = UI::Checkbox("Show medal window when playing", S_MedalWindow))) {
        UI::Indent(indent);

        S_MedalWindowHideWithGame = UI::Checkbox(
            "Show/hide with game UI##medal",
            S_MedalWindowHideWithGame
        );

        S_MedalWindowHideWithOP = UI::Checkbox(
            "Show/hide with Openplanet UI##medal",
            S_MedalWindowHideWithOP
        );

        S_MedalWindowIcon = UI::Checkbox(
            "Show real medal icon",
            S_MedalWindowIcon
        );

        S_MedalWindowName = UI::Checkbox(
            "Show medal name",
            S_MedalWindowName
        );

        S_MedalWindowDelta = UI::Checkbox(
            "Show PB delta",
            S_MedalWindowDelta
        );

        UI::Indent(-indent);
    }

    UI::Separator();

    UI::PushFont(UI::Font::Default, 26.0f);
    UI::Text("Colors");
    UI::PopFont();

    if (UI::Button("Reset to default##colors")) {
        Meta::PluginSetting@[]@ settings = pluginMeta.GetSettings();
        for (uint i = 0; i < settings.Length; i++) {
            if (settings[i].Category == "Colors") {
                settings[i].Reset();
            }
        }
    }

    S_ColorWinter     = UI::InputColor3("Winter / Jan-Mar", S_ColorWinter);
    S_ColorSpring     = UI::InputColor3("Spring / Apr-Jun", S_ColorSpring);
    S_ColorSummer     = UI::InputColor3("Summer / Jul-Sep", S_ColorSummer);
    S_ColorFall       = UI::InputColor3("Fall / Oct-Dec",   S_ColorFall);
    S_ColorButtonFont = UI::InputColor4("Button Font",      S_ColorButtonFont);

    const vec3[] newColors = {
        S_ColorWinter,
        S_ColorSpring,
        S_ColorSummer,
        S_ColorFall
    };

    if (newColors != seasonColors) {
        OnSettingsChanged();
    }
}

[SettingsTab name="UI Medals" icon="ListAlt" order=1]
void Settings_MedalsInUI() {
    UI::PushFont(UI::Font::Default, 26.0f);
    UI::Text("Toggle");
    UI::PopFont();

    if (UI::Button("Reset to default##mainui")) {
        pluginMeta.GetSetting("S_UIMedals").Reset();
    }

    S_UIMedals = UI::Checkbox("Show medals in UI", S_UIMedals);
    HoverTooltipSetting("Showing Warrior medal icons in the UI can be laggy, but it's a nice touch to see them more easily in a vanilla-looking way");

    if (S_UIMedals) {
        UI::Separator();

        UI::PushFont(UI::Font::Default, 26.0f);
        UI::Text("Main Menu");
        UI::PopFont();

        if (UI::Button("Reset to default##menu")) {
            pluginMeta.GetSetting("S_UIMedalsSoloMenu").Reset();
            pluginMeta.GetSetting("S_UIMedalsSeasonalCampaign").Reset();
            pluginMeta.GetSetting("S_UIMedalsLiveCampaign").Reset();
            pluginMeta.GetSetting("S_UIMedalsClubCampaign").Reset();
            pluginMeta.GetSetting("S_UIMedalsTotd").Reset();
            pluginMeta.GetSetting("S_UIMedalsLiveTotd").Reset();
            pluginMeta.GetSetting("S_UIMedalsWeekly").Reset();
        }

        S_UIMedalsSoloMenu         = UI::Checkbox("Solo menu",                S_UIMedalsSoloMenu);
        HoverTooltipSetting("Shown on top of the Campaign and Track of the Day tiles");
        S_UIMedalsSeasonalCampaign = UI::Checkbox("Seasonal campaign",        S_UIMedalsSeasonalCampaign);
        S_UIMedalsLiveCampaign     = UI::Checkbox("Seasonal campaign (live)", S_UIMedalsLiveCampaign);
        HoverTooltipSetting("In the arcade");
        S_UIMedalsTotd             = UI::Checkbox("Track of the Day",         S_UIMedalsTotd);
        S_UIMedalsLiveTotd         = UI::Checkbox("Track of the Day (live)",  S_UIMedalsLiveTotd);
        HoverTooltipSetting("Runs off the edge of the background tile a little bit, should be fixed in the future");
        S_UIMedalsClubCampaign     = UI::Checkbox("Club campaign",            S_UIMedalsClubCampaign);
        HoverTooltipSetting("May be inaccurate if a club or campaign's name is changed");
        S_UIMedalsWeekly           = UI::Checkbox("Weekly Shorts",            S_UIMedalsWeekly);

        UI::Separator();

        UI::PushFont(UI::Font::Default, 26.0f);
        UI::Text("Playing");
        UI::PopFont();

        if (UI::Button("Reset to default##playing")) {
            pluginMeta.GetSetting("S_UIMedalBanner").Reset();
            pluginMeta.GetSetting("S_UIMedalStart").Reset();
            pluginMeta.GetSetting("S_UIMedalPause").Reset();
            pluginMeta.GetSetting("S_UIMedalEnd").Reset();
        }

        S_UIMedalBanner = UI::Checkbox("Record banner", S_UIMedalBanner);
        HoverTooltipSetting("Shows at the top-left in a live match");
        S_UIMedalStart  = UI::Checkbox("Start menu",    S_UIMedalStart);
        HoverTooltipSetting("Only shows in solo");
        S_UIMedalPause  = UI::Checkbox("Pause menu",    S_UIMedalPause);
        S_UIMedalEnd    = UI::Checkbox("End menu",      S_UIMedalEnd);
        HoverTooltipSetting("Only shows in solo");

        UI::Separator();

        UI::PushFont(UI::Font::Default, 26.0f);
        UI::Text("Debug");
        UI::PopFont();

        S_UIMedalsAlwaysMenu       = UI::Checkbox("Always show in menu",       S_UIMedalsAlwaysMenu);
        S_UIMedalsAlwaysPlayground = UI::Checkbox("Always show in playground", S_UIMedalsAlwaysPlayground);
    }
}

[SettingsTab name="Debug" icon="Bug" order=2]
void Settings_Debug() {
    const float scale = UI::GetScale();

    UI::BeginTabBar("##tabs-debug");

    if (UI::BeginTabItem("Campaigns")) {
        string[]@ uids = campaigns.GetKeys();

        UI::Text("campaigns: " + uids.Length);

        if (UI::BeginTable("##table-campaigns", 9, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
            UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(vec3(), 0.5f));

            UI::TableSetupScrollFreeze(0, 1);
            UI::TableSetupColumn("uid",      UI::TableColumnFlags::WidthFixed, scale * 350.0f);
            UI::TableSetupColumn("clubId",   UI::TableColumnFlags::WidthFixed, scale * 50.0f);
            UI::TableSetupColumn("clubName", UI::TableColumnFlags::WidthFixed, scale * 230.0f);
            UI::TableSetupColumn("id",       UI::TableColumnFlags::WidthFixed, scale * 50.0f);
            UI::TableSetupColumn("index",    UI::TableColumnFlags::WidthFixed, scale * 50.0f);
            UI::TableSetupColumn("name",     UI::TableColumnFlags::WidthFixed, scale * 230.0f);
            UI::TableSetupColumn("year",     UI::TableColumnFlags::WidthFixed, scale * 80.0f);
            UI::TableSetupColumn("month",    UI::TableColumnFlags::WidthFixed, scale * 80.0f);
            UI::TableSetupColumn("week",     UI::TableColumnFlags::WidthFixed, scale * 80.0f);
            UI::TableHeadersRow();

            UI::ListClipper clipper(uids.Length);
            while (clipper.Step()) {
                for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                    auto campaign = cast<Campaign>(campaigns[uids[i]]);

                    UI::TableNextRow();

                    UI::TableNextColumn();
                    UI::Text(campaign.uid);

                    UI::TableNextColumn();
                    UI::Text(tostring(campaign.clubId));

                    UI::TableNextColumn();
                    UI::Text(campaign.clubName);

                    UI::TableNextColumn();
                    UI::Text(tostring(campaign.id));

                    UI::TableNextColumn();
                    UI::Text(tostring(campaign.index));

                    UI::TableNextColumn();
                    UI::Text(campaign.name);

                    UI::TableNextColumn();
                    UI::Text(tostring(campaign.year));

                    UI::TableNextColumn();
                    UI::Text(tostring(campaign.month));

                    UI::TableNextColumn();
                    UI::Text(tostring(campaign.week));
                }
            }

            UI::PopStyleColor();
            UI::EndTable();
        }

        UI::EndTabItem();
    }

    if (UI::BeginTabItem("Maps")) {
        string[]@ uids = maps.GetKeys();

        UI::Text("maps: " + uids.Length);

        if (UI::BeginTable("##table-maps", 12, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
            UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(vec3(), 0.5f));

            UI::TableSetupScrollFreeze(0, 1);
            UI::TableSetupColumn("uid",      UI::TableColumnFlags::WidthFixed, scale * 230.0f);
            UI::TableSetupColumn("name");
            UI::TableSetupColumn("wr",       UI::TableColumnFlags::WidthFixed, scale * 60.0f);
            UI::TableSetupColumn("wm",       UI::TableColumnFlags::WidthFixed, scale * 60.0f);
            UI::TableSetupColumn("at",       UI::TableColumnFlags::WidthFixed, scale * 60.0f);
            UI::TableSetupColumn("gt",       UI::TableColumnFlags::WidthFixed, scale * 60.0f);
            UI::TableSetupColumn("pb",       UI::TableColumnFlags::WidthFixed, scale * 60.0f);
            UI::TableSetupColumn("date",     UI::TableColumnFlags::WidthFixed, scale * 70.0f);
            UI::TableSetupColumn("campaign", UI::TableColumnFlags::WidthFixed, scale * 100.0f);
            UI::TableSetupColumn("index",    UI::TableColumnFlags::WidthFixed, scale * 40.0f);
            UI::TableSetupColumn("id",       UI::TableColumnFlags::WidthFixed, scale * 280.0f);
            UI::TableSetupColumn("reason");
            UI::TableHeadersRow();

            UI::ListClipper clipper(uids.Length);
            while (clipper.Step()) {
                for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                    auto map = cast<WarriorMedals::Map>(maps[uids[i]]);

                    UI::TableNextRow();

                    UI::TableNextColumn();
                    UI::Text(map.uid);

                    UI::TableNextColumn();
                    UI::Text(map.name);

                    UI::TableNextColumn();
                    UI::Text(Time::Format(map.worldRecord));

                    UI::TableNextColumn();
                    UI::Text(Time::Format(map.warrior));

                    UI::TableNextColumn();
                    UI::Text(Time::Format(map.author));

                    UI::TableNextColumn();
                    UI::Text(Time::Format(map.gold));

                    UI::TableNextColumn();
                    UI::Text(map.pb != uint(-1) ? Time::Format(map.pb) : "");

                    UI::TableNextColumn();
                    UI::Text(map.date);

                    UI::TableNextColumn();
                    UI::Text(map.campaignName);

                    UI::TableNextColumn();
                    UI::Text(tostring(map.index));

                    UI::TableNextColumn();
                    UI::Text(map.id);

                    UI::TableNextColumn();
                    UI::Text(map.reason);
                }
            }

            UI::PopStyleColor();
            UI::EndTable();
        }

        UI::EndTabItem();
    }

    if (UI::BeginTabItem("Other")) {
        UI::Text("previous totd: " + (previousTotd !is null ? previousTotd.date : "null"));
        UI::Text("latest totd: " + (latestTotd !is null ? latestTotd.date : "null"));

        UI::EndTabItem();
    }

    UI::EndTabBar();
}

[SettingsTab name="Warrior Medals" icon="Circle" order=3]
void Settings_MainWindow() {
    MainWindow();
}

void HoverTooltipSetting(const string&in msg, const string&in color = "666") {
    UI::SameLine();
    UI::Text("\\$" + color + Icons::QuestionCircle);
    if (!UI::IsItemHovered()) {
        return;
    }

    // UI::SetNextWindowSize(int(Math::Min(Draw::MeasureString(msg).x, 400.0f)), 0.0f);
    UI::BeginTooltip();
    // UI::TextWrapped(Shadow() + msg);
    UI::Text(Shadow() + msg);
    UI::EndTooltip();
}
