// c 2024-07-17
// m 2024-10-23

[Setting hidden] vec3 S_ColorFall                = vec3(1.0f, 0.5f, 0.0f);
[Setting hidden] vec3 S_ColorSpring              = vec3(0.3f, 0.9f, 0.3f);
[Setting hidden] vec3 S_ColorSummer              = vec3(1.0f, 0.8f, 0.0f);
[Setting hidden] vec3 S_ColorWinter              = vec3(0.0f, 0.8f, 1.0f);

[Setting hidden] bool S_MainWindow               = false;
[Setting hidden] bool S_MainWindowAutoResize     = false;
[Setting hidden] bool S_MainWindowCampRefresh    = true;
[Setting hidden] bool S_MainWindowHideWithGame   = true;
[Setting hidden] bool S_MainWindowHideWithOP     = true;
[Setting hidden] bool S_MainWindowPercentages    = true;
[Setting hidden] bool S_MainWindowTmioLinks      = true;

[Setting hidden] bool S_MedalWindow              = true;
[Setting hidden] bool S_MedalWindowDelta         = true;
[Setting hidden] bool S_MedalWindowHideWithGame  = true;
[Setting hidden] bool S_MedalWindowHideWithOP    = false;
[Setting hidden] bool S_MedalWindowIcon          = true;
[Setting hidden] bool S_MedalWindowName          = true;

[Setting hidden] bool S_UIMedals                 = true;
[Setting hidden] bool S_UIMedalBanner            = true;
[Setting hidden] bool S_UIMedalEnd               = true;
[Setting hidden] bool S_UIMedalPause             = true;
[Setting hidden] bool S_UIMedalsClubCampaign     = true;
[Setting hidden] bool S_UIMedalsLiveCampaign     = true;
[Setting hidden] bool S_UIMedalsLiveTotd         = false;
[Setting hidden] bool S_UIMedalsSeasonalCampaign = true;
[Setting hidden] bool S_UIMedalStart             = true;
[Setting hidden] bool S_UIMedalsTotd             = true;
[Setting hidden] bool S_UIMedalsTraining         = true;

[SettingsTab name="General" icon="Cogs"]
void Settings_General() {
    UI::PushFont(fontHeader);
    UI::Text("Main Window");
    UI::PopFont();

    if (UI::Button("Reset to default##main")) {
        Meta::Plugin@ plugin = Meta::ExecutingPlugin();
        plugin.GetSetting("S_MainWindow").Reset();
        plugin.GetSetting("S_MainWindowHideWithGame").Reset();
        plugin.GetSetting("S_MainWindowHideWithOP").Reset();
        plugin.GetSetting("S_MainWindowAutoResize").Reset();
        plugin.GetSetting("S_MainWindowTmioLinks").Reset();
        plugin.GetSetting("S_MainWindowCampRefresh").Reset();
        plugin.GetSetting("S_MainWindowPercentages").Reset();
    }

    if ((S_MainWindow = UI::Checkbox("Show main window", S_MainWindow))) {
        UI::NewLine(); UI::SameLine();
        S_MainWindowHideWithGame = UI::Checkbox(
            "Show/hide with game UI##main",
            S_MainWindowHideWithGame
        );

        UI::NewLine(); UI::SameLine();
        S_MainWindowHideWithOP = UI::Checkbox(
            "Show/hide with Openplanet UI##main",
            S_MainWindowHideWithOP
        );

        UI::NewLine(); UI::SameLine();
        S_MainWindowAutoResize = UI::Checkbox(
            "Auto-resize",
            S_MainWindowAutoResize
        );

        UI::NewLine(); UI::SameLine();
        S_MainWindowTmioLinks = UI::Checkbox(
            "Show Trackmania.io buttons on campaigns",
            S_MainWindowTmioLinks
        );

        UI::NewLine(); UI::SameLine();
        S_MainWindowCampRefresh = UI::Checkbox(
            "Show PB refresh button on campaigns",
            S_MainWindowCampRefresh
        );

        UI::NewLine(); UI::SameLine();
        S_MainWindowPercentages = UI::Checkbox(
            "Show percentages",
            S_MainWindowPercentages
        );
    }

    UI::Separator();

    UI::PushFont(fontHeader);
    UI::Text("Medal Window");
    UI::PopFont();

    if (UI::Button("Reset to default##medal")) {
        Meta::Plugin@ plugin = Meta::ExecutingPlugin();
        plugin.GetSetting("S_MedalWindow").Reset();
        plugin.GetSetting("S_MedalWindowHideWithGame").Reset();
        plugin.GetSetting("S_MedalWindowHideWithOP").Reset();
        plugin.GetSetting("S_MedalWindowDelta").Reset();
        plugin.GetSetting("S_MedalWindowIcon").Reset();
        plugin.GetSetting("S_MedalWindowName").Reset();

    }

    if ((S_MedalWindow = UI::Checkbox("Show medal window when playing", S_MedalWindow))) {
        UI::NewLine(); UI::SameLine();
        S_MedalWindowHideWithGame = UI::Checkbox(
            "Show/hide with game UI##medal",
            S_MedalWindowHideWithGame
        );

        UI::NewLine(); UI::SameLine();
        S_MedalWindowHideWithOP = UI::Checkbox(
            "Show/hide with Openplanet UI##medal",
            S_MedalWindowHideWithOP
        );

        UI::NewLine(); UI::SameLine();
        S_MedalWindowIcon = UI::Checkbox(
            "Show real medal icon",
            S_MedalWindowIcon
        );

        UI::NewLine(); UI::SameLine();
        S_MedalWindowName = UI::Checkbox(
            "Show medal name",
            S_MedalWindowName
        );

        UI::NewLine(); UI::SameLine();
        S_MedalWindowDelta = UI::Checkbox(
            "Show PB delta",
            S_MedalWindowDelta
        );
    }

    UI::Separator();

    UI::PushFont(fontHeader);
    UI::Text("Colors");
    UI::PopFont();

    if (UI::Button("Reset to default##colors")) {
        Meta::Plugin@ plugin = Meta::ExecutingPlugin();
        plugin.GetSetting("S_ColorWinter").Reset();
        plugin.GetSetting("S_ColorSpring").Reset();
        plugin.GetSetting("S_ColorSummer").Reset();
        plugin.GetSetting("S_ColorFall").Reset();
    }

    S_ColorWinter = UI::InputColor3("Winter / Jan-Mar", S_ColorWinter);
    S_ColorSpring = UI::InputColor3("Spring / Apr-Jun", S_ColorSpring);
    S_ColorSummer = UI::InputColor3("Summer / Jul-Sep", S_ColorSummer);
    S_ColorFall   = UI::InputColor3("Fall / Oct-Dec",   S_ColorFall);

    const vec3[] newColors = {
        S_ColorWinter,
        S_ColorSpring,
        S_ColorSummer,
        S_ColorFall
    };

    if (newColors != seasonColors)
        OnSettingsChanged();
}

[SettingsTab name="UI Medals" icon="ListAlt" order=1]
void Settings_MedalsInUI() {
    UI::PushFont(fontHeader);
    UI::Text("Toggle");
    UI::PopFont();

    if (UI::Button("Reset to default##main")) {
        Meta::Plugin@ plugin = Meta::ExecutingPlugin();
        plugin.GetSetting("S_UIMedals").Reset();
    }

    S_UIMedals = UI::Checkbox("Show medals in UI", S_UIMedals);
    HoverTooltipSetting("Showing Warrior medal icons in the UI can be laggy, but it's a nice touch to see them more easily in a vanilla-looking way");

    if (S_UIMedals) {
        UI::Separator();

        UI::PushFont(fontHeader);
        UI::Text("Main Menu");
        UI::PopFont();

        if (UI::Button("Reset to default##menu")) {
            Meta::Plugin@ plugin = Meta::ExecutingPlugin();
            plugin.GetSetting("S_UIMedalsSeasonalCampaign").Reset();
            plugin.GetSetting("S_UIMedalsLiveCampaign").Reset();
            plugin.GetSetting("S_UIMedalsClubCampaign").Reset();
            plugin.GetSetting("S_UIMedalsTotd").Reset();
            // plugin.GetSetting("S_UIMedalsLiveTotd").Reset();
            plugin.GetSetting("S_UIMedalsTraining").Reset();
        }

        S_UIMedalsSeasonalCampaign = UI::Checkbox("Seasonal campaign",        S_UIMedalsSeasonalCampaign);
        S_UIMedalsLiveCampaign     = UI::Checkbox("Seasonal campaign (live)", S_UIMedalsLiveCampaign);
        HoverTooltipSetting("In the arcade");
        S_UIMedalsTotd             = UI::Checkbox("Track of the Day",         S_UIMedalsTotd);
        // S_UIMedalsLiveTotd         = UI::Checkbox("Track of the Day (live)",  S_UIMedalsLiveTotd);
        S_UIMedalsClubCampaign     = UI::Checkbox("Club campaign",            S_UIMedalsClubCampaign);
        HoverTooltipSetting("May be inaccurate if a club or campaign's name is changed");
        S_UIMedalsTraining         = UI::Checkbox("Training",                 S_UIMedalsTraining);

        UI::Separator();

        UI::PushFont(fontHeader);
        UI::Text("Playing");
        UI::PopFont();

        if (UI::Button("Reset to default##playing")) {
            Meta::Plugin@ plugin = Meta::ExecutingPlugin();
            plugin.GetSetting("S_UIMedalBanner").Reset();
            plugin.GetSetting("S_UIMedalStart").Reset();
            plugin.GetSetting("S_UIMedalPause").Reset();
            plugin.GetSetting("S_UIMedalEnd").Reset();
        }

        S_UIMedalBanner = UI::Checkbox("Record banner", S_UIMedalBanner);
        HoverTooltipSetting("Shows at the top-left in a live match");
        S_UIMedalStart  = UI::Checkbox("Start menu",    S_UIMedalStart);
        HoverTooltipSetting("Only shows in solo");
        S_UIMedalPause  = UI::Checkbox("Pause menu",    S_UIMedalPause);
        S_UIMedalEnd    = UI::Checkbox("End menu",      S_UIMedalEnd);
        HoverTooltipSetting("Only shows in solo");
    }
}

[SettingsTab name="Debug" icon="Bug" order=2]
void Settings_Debug() {
    if (API::Nadeo::requesting) {
        UI::BeginDisabled(API::Nadeo::cancel);
        if (UI::ButtonColored(Icons::Times + " Cancel", 0.0f))
            API::Nadeo::cancel = true;
        UI::EndDisabled();

        HoverTooltipSetting(API::Nadeo::allCampaignsProgress);

    } else {
        if (UI::Button(Icons::CloudDownload + " Get All PBs"))
            startnew(API::Nadeo::GetAllCampaignPBsAsync);

        HoverTooltipSetting(
            "This requests PBs from Nadeo. Please do not spam this. "
            + "Unless I've made a mistake, you should only need to click it once ever,"
            + " in which case it would be hidden from your main window now."
        );
    }

    UI::BeginTabBar("##tabs-debug");

    if (UI::BeginTabItem("Campaigns")) {
        string[]@ uids = campaigns.GetKeys();

        UI::Text("campaigns: " + uids.Length);

        if (UI::BeginTable("##table-campaigns", 5, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
            UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(0.0f, 0.0f, 0.0f, 0.5f));

            UI::TableSetupScrollFreeze(0, 1);
            UI::TableSetupColumn("uid",      UI::TableColumnFlags::WidthFixed, scale * 350.0f);
            UI::TableSetupColumn("clubId",   UI::TableColumnFlags::WidthFixed, scale * 50.0f);
            UI::TableSetupColumn("clubName", UI::TableColumnFlags::WidthFixed, scale * 230.0f);
            UI::TableSetupColumn("id",       UI::TableColumnFlags::WidthFixed, scale * 50.0f);
            UI::TableSetupColumn("name",     UI::TableColumnFlags::WidthFixed, scale * 230.0f);
            UI::TableHeadersRow();

            UI::ListClipper clipper(uids.Length);
            while (clipper.Step()) {
                for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                    Campaign@ campaign = cast<Campaign@>(campaigns[uids[i]]);

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
                    UI::Text(campaign.name);
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

        if (UI::BeginTable("##table-maps", 11, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
            UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(0.0f, 0.0f, 0.0f, 0.5f));

            UI::TableSetupScrollFreeze(0, 1);
            UI::TableSetupColumn("uid",      UI::TableColumnFlags::WidthFixed, scale * 230.0f);
            UI::TableSetupColumn("name");
            UI::TableSetupColumn("wr",       UI::TableColumnFlags::WidthFixed, scale * 60.0f);
            UI::TableSetupColumn("wm",       UI::TableColumnFlags::WidthFixed, scale * 60.0f);
            UI::TableSetupColumn("at",       UI::TableColumnFlags::WidthFixed, scale * 60.0f);
            UI::TableSetupColumn("pb",       UI::TableColumnFlags::WidthFixed, scale * 60.0f);
            UI::TableSetupColumn("date",     UI::TableColumnFlags::WidthFixed, scale * 70.0f);
            UI::TableSetupColumn("campaign", UI::TableColumnFlags::WidthFixed, scale * 100.0f);
            UI::TableSetupColumn("index",    UI::TableColumnFlags::WidthFixed, scale * 40.0f);
            UI::TableSetupColumn("custom",   UI::TableColumnFlags::WidthFixed, scale * 60.0f);
            UI::TableSetupColumn("reason");
            UI::TableHeadersRow();

            UI::ListClipper clipper(uids.Length);
            while (clipper.Step()) {
                for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                    WarriorMedals::Map@ map = cast<WarriorMedals::Map@>(maps[uids[i]]);

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
                    UI::Text(map.pb != uint(-1) ? Time::Format(map.pb) : "");

                    UI::TableNextColumn();
                    UI::Text(map.date);

                    UI::TableNextColumn();
                    UI::Text(map.campaignName);

                    UI::TableNextColumn();
                    UI::Text(tostring(map.index));

                    UI::TableNextColumn();
                    UI::Text(Time::Format(map.custom));

                    UI::TableNextColumn();
                    UI::Text(map.reason);
                }
            }

            UI::PopStyleColor();
            UI::EndTable();
        }

        UI::EndTabItem();
    }

    UI::EndTabBar();
}

void HoverTooltipSetting(const string &in msg, const string &in color = "666") {
    UI::SameLine();
    UI::Text("\\$" + color + Icons::QuestionCircle);
    if (!UI::IsItemHovered())
        return;

    UI::SetNextWindowSize(int(Math::Min(Draw::MeasureString(msg).x, 400.0f)), 0.0f);
    UI::BeginTooltip();
    UI::TextWrapped(msg);
    UI::EndTooltip();
}
