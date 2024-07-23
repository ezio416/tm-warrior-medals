// c 2024-07-17
// m 2024-07-23

[Setting hidden] vec3 S_ColorFall         = vec3(1.0f, 0.5f, 0.0f);
[Setting hidden] vec3 S_ColorSpring       = vec3(0.3f, 0.9f, 0.3f);
[Setting hidden] vec3 S_ColorSummer       = vec3(1.0f, 0.8f, 0.0f);
[Setting hidden] vec3 S_ColorWinter       = vec3(0.0f, 0.8f, 1.0f);
[Setting hidden] bool S_MainAutoResize    = false;
[Setting hidden] bool S_MainHideWithGame  = true;
[Setting hidden] bool S_MainHideWithOP    = true;
[Setting hidden] bool S_MainWindow        = false;
[Setting hidden] bool S_MedalDelta        = true;
[Setting hidden] bool S_MedalHideWithGame = true;
[Setting hidden] bool S_MedalHideWithOP   = false;
[Setting hidden] bool S_MedalWindow       = true;
[SettingsTab name="General" icon="Cogs"]
void Settings_General() {
    UI::PushFont(fontHeader);
    UI::Text("Main Window");
    UI::PopFont();

    if (UI::Button("Reset to default##main")) {
        Meta::Plugin@ plugin = Meta::ExecutingPlugin();
        plugin.GetSetting("S_MainWindow").Reset();
        plugin.GetSetting("S_MainHideWithGame").Reset();
        plugin.GetSetting("S_MainHideWithOP").Reset();
        plugin.GetSetting("S_MainAutoResize").Reset();
    }

    S_MainWindow = UI::Checkbox("Show main window", S_MainWindow);
    if (S_MainWindow) {
        UI::NewLine(); UI::SameLine();
        S_MainHideWithGame = UI::Checkbox("Show/hide with game UI##main",       S_MainHideWithGame);
        UI::NewLine(); UI::SameLine();
        S_MainHideWithOP   = UI::Checkbox("Show/hide with Openplanet UI##main", S_MainHideWithOP);
        UI::NewLine(); UI::SameLine();
        S_MainAutoResize   = UI::Checkbox("Auto-resize",                        S_MainAutoResize);
    }

    UI::Separator();

    UI::PushFont(fontHeader);
    UI::Text("Medal Window");
    UI::PopFont();

    if (UI::Button("Reset to default##medal")) {
        Meta::Plugin@ plugin = Meta::ExecutingPlugin();
        plugin.GetSetting("S_MedalWindow").Reset();
        plugin.GetSetting("S_MedalHideWithGame").Reset();
        plugin.GetSetting("S_MedalHideWithOP").Reset();
        plugin.GetSetting("S_MedalDelta").Reset();
    }

    S_MedalWindow = UI::Checkbox("Show medal window when playing", S_MedalWindow);
    if (S_MedalWindow) {
        UI::NewLine(); UI::SameLine();
        S_MedalHideWithGame = UI::Checkbox("Show/hide with game UI##medal",       S_MedalHideWithGame);
        UI::NewLine(); UI::SameLine();
        S_MedalHideWithOP   = UI::Checkbox("Show/hide with Openplanet UI##medal", S_MedalHideWithOP);
        UI::NewLine(); UI::SameLine();
        S_MedalDelta        = UI::Checkbox("Show PB delta",                       S_MedalDelta);
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

    S_ColorWinter = UI::InputColor3("Winter/Jan-Mar", S_ColorWinter);
    S_ColorSpring = UI::InputColor3("Spring/Apr-Jun", S_ColorSpring);
    S_ColorSummer = UI::InputColor3("Summer/Jul-Sep", S_ColorSummer);
    S_ColorFall   = UI::InputColor3("Fall/Oct-Dec",   S_ColorFall);

    const vec3[] newColors = {
        S_ColorWinter,
        S_ColorSpring,
        S_ColorSummer,
        S_ColorFall
    };

    if (newColors != seasonColors)
        OnSettingsChanged();
}

[Setting hidden] bool S_MedalsClubCampaign     = false;
[Setting hidden] bool S_MedalsInUI             = false;
[Setting hidden] bool S_MedalsSeasonalCampaign = true;
[Setting hidden] bool S_MedalsTotd             = true;
[Setting hidden] bool S_MedalsTraining         = true;
[SettingsTab name="Medals in UI" icon="ListAlt" order=1]
void Settings_MedalsInUI() {
    UI::PushFont(fontHeader);
    UI::Text("Main Toggle");
    UI::PopFont();

    if (UI::Button("Reset to default##main")) {
        Meta::Plugin@ plugin = Meta::ExecutingPlugin();
        plugin.GetSetting("S_MedalsInUI").Reset();
    }

    S_MedalsInUI = UI::Checkbox("Show medals in UI", S_MedalsInUI);
    HoverTooltipSetting("Showing Warrior medal icons in the UI can be laggy, though it is a nice touch to see them more easily in a vanilla-looking way.");

    if (S_MedalsInUI) {
        UI::Separator();

        UI::PushFont(fontHeader);
        UI::Text("Menu");
        UI::PopFont();

        if (UI::Button("Reset to default##menu")) {
            Meta::Plugin@ plugin = Meta::ExecutingPlugin();
            plugin.GetSetting("S_MedalsSeasonalCampaign").Reset();
            plugin.GetSetting("S_MedalsClubCampaign").Reset();
            plugin.GetSetting("S_MedalsTotd").Reset();
            plugin.GetSetting("S_MedalsTraining").Reset();
        }

        S_MedalsSeasonalCampaign = UI::Checkbox("Seasonal campaign", S_MedalsSeasonalCampaign);
        S_MedalsClubCampaign     = UI::Checkbox("Club campaign",     S_MedalsClubCampaign);
        HoverTooltipSetting("May be inaccurate if a club campaign shares a name with an official one.");
        S_MedalsTotd             = UI::Checkbox("Track of the Day",  S_MedalsTotd);
        S_MedalsTraining         = UI::Checkbox("Training",          S_MedalsTraining);

        // UI::Separator();

        // UI::PushFont(headerFont);
        // UI::Text("In-Game");
        // UI::PopFont();

        // if (UI::Button("Reset to default##ingame")) {
        //     Meta::Plugin@ plugin = Meta::ExecutingPlugin();
        //     plugin.GetSetting("").Reset();
        // }

        // ;
    }
}

[SettingsTab name="Debug" icon="Bug" order=2]
void Settings_Debug() {
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
                UI::Text(map.campaign);

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
