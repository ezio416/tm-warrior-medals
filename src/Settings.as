// c 2024-07-17
// m 2024-07-22

[Setting hidden] bool S_Window       = true;
[Setting hidden] bool S_HideWithGame = true;
[Setting hidden] bool S_HideWithOP   = false;
[Setting hidden] bool S_Delta        = true;
[SettingsTab name="Medal Window" icon="Circle"]
void Settings_MedalWindow() {
    S_Window = UI::Checkbox("Show Warrior medal window when playing", S_Window);

    if (S_Window) {
        S_HideWithGame = UI::Checkbox("Show/hide with game UI",       S_HideWithGame);
        S_HideWithOP   = UI::Checkbox("Show/hide with Openplanet UI", S_HideWithOP);
        S_Delta        = UI::Checkbox("Show PB delta",                S_Delta);
    }
}

[Setting hidden] bool S_MedalsInUI             = false;
[Setting hidden] bool S_MedalsSeasonalCampaign = true;
[Setting hidden] bool S_MedalsClubCampaign     = true;
// [Setting hidden] bool S_MedalsTotd             = true;
// [Setting hidden] bool S_MedalsTraining         = true;
[SettingsTab name="Medals in UI" icon="ListAlt" order=1]
void Settings_MedalsInUI() {
    UI::TextWrapped("Showing Warrior medal icons in the UI can be laggy, though it is a nice touch to see them more easily in a vanilla-looking way.");

    S_MedalsInUI = UI::Checkbox("Show medals in UI", S_MedalsInUI);

    if (S_MedalsInUI) {
        UI::Separator();

        UI::Text("\\$IMenu");
        S_MedalsSeasonalCampaign = UI::Checkbox("Seasonal campaign", S_MedalsSeasonalCampaign);
        S_MedalsClubCampaign     = UI::Checkbox("Club campaign",     S_MedalsClubCampaign);
        // S_MedalsTotd             = UI::Checkbox("Track of the Day",  S_MedalsTotd);
        // S_MedalsTraining         = UI::Checkbox("Training",          S_MedalsTraining);

        // UI::Separator();

        // UI::Text("\\$IIn-Game");
    }
}

[SettingsTab name="Debug" icon="Bug" order=2]
void Settings_Debug() {
    string[]@ uids = maps.GetKeys();

    UI::Text("maps: " + uids.Length);

    if (UI::BeginTable("##table-maps", 9, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
        UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(0.0f, 0.0f, 0.0f, 0.5f));

        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("uid",      UI::TableColumnFlags::WidthFixed, scale * 230.0f);
        UI::TableSetupColumn("name");
        UI::TableSetupColumn("wr",       UI::TableColumnFlags::WidthFixed, scale * 60.0f);
        UI::TableSetupColumn("wm",       UI::TableColumnFlags::WidthFixed, scale * 60.0f);
        UI::TableSetupColumn("at",       UI::TableColumnFlags::WidthFixed, scale * 60.0f);
        UI::TableSetupColumn("date",     UI::TableColumnFlags::WidthFixed, scale * 70.0f);
        UI::TableSetupColumn("campaign", UI::TableColumnFlags::WidthFixed, scale * 100.0f);
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
                UI::Text(map.date);

                UI::TableNextColumn();
                UI::Text(map.campaign);

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
