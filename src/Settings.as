// c 2024-07-17
// m 2024-07-19

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

[Setting category="General" name="Show/hide with game UI"]
bool S_HideWithGame = true;

[Setting category="General" name="Show/hide with Openplanet UI"]
bool S_HideWithOP = false;

[Setting category="General" name="Show PB delta"]
bool S_Delta = true;

[SettingsTab name="Debug" icon="Bug"]
void Debug() {
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
                Map@ map = cast<Map@>(maps[uids[i]]);

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
