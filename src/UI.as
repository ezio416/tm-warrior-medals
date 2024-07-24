// c 2024-07-22
// m 2024-07-23

void DrawOverUI() {
    if (false
        || !S_MedalsInUI
        || iconUI is null
        || (true
            && !S_MedalsSeasonalCampaign
            && !S_MedalsLiveCampaign
            && !S_MedalsTotd
            && !S_MedalsClubCampaign
            && !S_MedalsTraining
            && !S_MedalsPause
        )
    )
        return;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    NGameLoadProgress_SMgr@ LoadProgress = App.LoadProgress;
    if (LoadProgress !is null && LoadProgress.State != NGameLoadProgress::EState::Disabled)
        return;

    CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);

    if (InMap()) {
        if (!maps.Exists(App.RootMap.EdChallengeId))
            return;

        WarriorMedals::Map@ map = cast<WarriorMedals::Map@>(maps[App.RootMap.EdChallengeId]);
        if (false
            || map is null
            || !map.hasWarrior
        )
            return;

        CGameManiaAppPlayground@ CMAP = Network.ClientManiaAppPlayground;
        if (CMAP is null || CMAP.UILayers.Length < 23)
            return;

        CGameManialinkPage@ Pause;

        for (uint i = 0; i < CMAP.UILayers.Length; i++) {
            if (true
                && !(Pause is null && S_MedalsPause && Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed)
            )
                break;

            CGameUILayer@ Layer = CMAP.UILayers[i];
            if (false
                || Layer is null
                || !Layer.IsVisible
                // || Layer.Type != CGameUILayer::EUILayerType::Normal
                || Layer.ManialinkPageUtf8.Length == 0
            )
                continue;

            const string pageName = Layer.ManialinkPageUtf8.Trim();

            if (true
                && S_MedalsPause
                && Pause is null
                && Layer.Type == CGameUILayer::EUILayerType::InGameMenu
                && pageName.SubStr(0, 100).Contains("_PauseMenu")
            ) {
                @Pause = Layer.LocalPage;
                continue;
            }
        }

        DrawOverPauseMenu(Pause);

        return;
    }

    CTrackManiaNetworkServerInfo@ ServerInfo = cast<CTrackManiaNetworkServerInfo@>(Network.ServerInfo);
    if (ServerInfo.CurGameModeStr.Length > 0)
        return;

    CTrackManiaMenus@ Menus = cast<CTrackManiaMenus@>(App.MenuManager);
    if (Menus is null)
        return;

    CGameManiaAppTitle@ Title = Menus.MenuCustom_CurrentManiaApp;
    if (Title is null || Title.UILayers.Length == 0)
        return;

    CGameManialinkPage@ Campaign;
    CGameManialinkPage@ LiveCampaign;
    // CGameManialinkPage@ LiveTotd;
    CGameManialinkPage@ Totd;
    CGameManialinkPage@ Training;

    for (uint i = 0; i < Title.UILayers.Length; i++) {
        if (true
            && !(Campaign     is null && (S_MedalsSeasonalCampaign || S_MedalsClubCampaign))
            && !(LiveCampaign is null && S_MedalsLiveCampaign)
            // && !(LiveTotd     is null && S_MedalsLiveTotd)
            && !(Totd         is null && S_MedalsTotd)
            && !(Training     is null && S_MedalsTraining)
        )
            break;

        CGameUILayer@ Layer = Title.UILayers[i];
        if (false
            || Layer is null
            || !Layer.IsVisible
            || Layer.Type != CGameUILayer::EUILayerType::Normal
            || Layer.ManialinkPageUtf8.Length == 0
        )
            continue;

        const string pageName = Layer.ManialinkPageUtf8.Trim();

        // if (true
        //     && S_MedalsLiveTotd
        //     && LiveTotd is null
        //     && pageName.SubStr(17, 23) == "Page_TOTDChannelDisplay"
        // ) {  // 27
        //     @LiveTotd = Layer.LocalPage;
        //     continue;
        // }

        if (true
            && (S_MedalsSeasonalCampaign || S_MedalsClubCampaign)
            && Campaign is null
            && pageName.SubStr(17, 20) == "Page_CampaignDisplay"
        ) {  // 30
            @Campaign = Layer.LocalPage;
            continue;
        }

        if (true
            && S_MedalsTotd
            && Totd is null
            && pageName.SubStr(17, 27) == "Page_MonthlyCampaignDisplay"
        ) {  // 31
            @Totd = Layer.LocalPage;
            continue;
        }

        if (true
            && S_MedalsTraining
            && Training is null
            && pageName.SubStr(17, 20) == "Page_TrainingDisplay"
        ) {  // 41
            @Training = Layer.LocalPage;
            continue;
        }

        if (true
            && S_MedalsLiveCampaign
            && LiveCampaign is null
            && pageName.SubStr(17, 24) == "Page_RoomCampaignDisplay"
        ) {  // 42
            @LiveCampaign = Layer.LocalPage;
            continue;
        }
    }

    DrawOverCampaignPage(Campaign);
    DrawOverLiveCampaignPage(LiveCampaign);
    // DrawOverLiveTotdPage(LiveTotd);
    DrawOverTotdPage(Totd);
    DrawOverTrainingPage(Training);
}

void DrawCampaign(CGameManialinkFrame@ Maps, const string &in campaignName, bool club = false) {
    if (Maps is null || campaignName.Length == 0)
        return;

    uint[] indicesToShow;
    Campaign@ campaign = GetCampaign(campaignName.ToLower());
    if (campaign !is null) {
        for (uint i = 0; i < campaign.mapsArr.Length; i++) {
            WarriorMedals::Map@ map = campaign.mapsArr[i];
            if (map is null)
                continue;

            if (map.pb < (map.custom > 0 ? map.custom : map.warrior))
                indicesToShow.InsertLast(map.index);
        }
    }

    for (uint i = 0; i < Maps.Controls.Length; i++) {
        if (indicesToShow.Length == 0)
            break;

        if (indicesToShow.Find(i) == -1)
            continue;

        CGameManialinkFrame@ Map = cast<CGameManialinkFrame@>(Maps.Controls[i]);
        if (Map is null || !Map.Visible)
            continue;

        CGameManialinkFrame@ MedalStack = cast<CGameManialinkFrame@>(Map.GetFirstChild("frame-medalstack"));
        if (MedalStack is null || !MedalStack.Visible)
            continue;

        const float w = Draw::GetWidth();
        const float h = Draw::GetHeight();
        const float unit = (w / h < 16.0f / 9.0f) ? w / 320.0f : h / 180.0f;
        const vec2 offset = vec2(-99.8f, 1.05f) + (club ? vec2(0.4f, 2.51f) : vec2());
        const vec2 rowOffset = vec2(-2.02f, -11.5f);
        const vec2 columnOffset = vec2(36.0f, 0.0f);
        const vec2 coords = vec2(w * 0.5f, h * 0.5f)
            + vec2(unit, -unit) * (
                offset
                + ((i % 5) * rowOffset)
                + ((i / 5) * columnOffset)
            )
        ;

        nvg::BeginPath();
        nvg::FillPaint(nvg::TexturePattern(coords, vec2(unit * 9.6f), 0.0f, iconUI, 1.0f));
        nvg::Fill();
    }
}

void DrawOverCampaignPage(CGameManialinkPage@ Page) {
    if (Page is null)
        return;

    string campaignName;
    CGameManialinkLabel@ CampaignLabel = cast<CGameManialinkLabel@>(Page.GetFirstChild("label-title"));
    if (CampaignLabel !is null)
        campaignName = CampaignLabel.Value;

    string clubName;
    CGameManialinkFrame@ ClubLink = cast<CGameManialinkFrame@>(Page.GetFirstChild("button-club"));
    if (ClubLink !is null && ClubLink.Visible) {
        CGameManialinkLabel@ ClubLabel = cast<CGameManialinkLabel@>(ClubLink.GetFirstChild("menu-libs-expendable-button_label-button-text"));
        if (ClubLabel !is null)
            clubName = ClubLabel.Value.SubStr(15);
    }
    const bool club = clubName.Length > 0;

    if (club) {
        if (!S_MedalsClubCampaign)
            return;
    } else {
        if (!S_MedalsSeasonalCampaign)
            return;
        campaignName = campaignName.SubStr(19).Replace("\u0091", " ");
    }

    DrawCampaign(cast<CGameManialinkFrame@>(Page.GetFirstChild("frame-maps")), campaignName, club);
}

void DrawOverLiveCampaignPage(CGameManialinkPage@ Page) {
    if (Page is null)
        return;

    string campaignName;
    CGameManialinkLabel@ CampaignLabel = cast<CGameManialinkLabel@>(Page.GetFirstChild("label-title"));
    if (CampaignLabel !is null)
        campaignName = string(CampaignLabel.Value).SubStr(19).Replace("\u0091", " ");

    DrawCampaign(cast<CGameManialinkFrame@>(Page.GetFirstChild("frame-maps")), campaignName, false);
}

void DrawOverLiveTotdPage(CGameManialinkPage@ Page) {
    if (Page is null)
        return;

    CGameManialinkFrame@ PrevDay = cast<CGameManialinkFrame@>(Page.GetFirstChild("frame-previous-day"));
    if (PrevDay is null || !PrevDay.Visible)
        return;

    CGameManialinkLabel@ DayLabel = cast<CGameManialinkLabel@>(PrevDay.GetFirstChild("label-day"));
    if (DayLabel is null)
        return;

    const string date = string(DayLabel.Value).SubStr(19).Replace("%1\u0091", "");
    UI::Text(date);

    uint month = 0;

    const uint day = Text::ParseUInt(date.SubStr(date.Length - 2));
    UI::Text(tostring(day));

    CGameManialinkFrame@ MedalStack = cast<CGameManialinkFrame@>(PrevDay.GetFirstChild("frame-medal-stack"));
    if (MedalStack is null || !MedalStack.Visible)
        return;

    UI::Text("medal stack");
}

void DrawOverPauseMenu(CGameManialinkPage@ Page) {
    if (Page is null)
        return;

    const float w = Draw::GetWidth();
    const float h = Draw::GetHeight();
    const float unit = (w / h < 16.0f / 9.0f) ? w / 320.0f : h / 180.0f;
    const vec2 offset = vec2(-33.4f, 40.83f);  // TODO: different for PlayMap and Training
    const vec2 coords = vec2(w * 0.5f, h * 0.5f) + vec2(unit, -unit) * offset;

    nvg::BeginPath();
    nvg::FillPaint(nvg::TexturePattern(coords, vec2(240.0f), 0.0f, iconUI, 1.0f));
    nvg::Fill();
}

void DrawOverTotdPage(CGameManialinkPage@ Page) {
    if (Page is null)
        return;

    CGameManialinkFrame@ Maps = cast<CGameManialinkFrame@>(Page.GetFirstChild("frame-maps"));
    if (Maps is null)
        return;

    string monthName;
    CGameManialinkLabel@ MonthLabel = cast<CGameManialinkLabel@>(Page.GetFirstChild("label-title"));
    if (MonthLabel !is null)
        monthName = string(MonthLabel.Value).SubStr(12).Replace("%1\u0091", "");

    uint[] indicesToShow;
    Campaign@ campaign = GetCampaign(monthName.ToLower());
    if (campaign !is null) {
        for (uint i = 0; i < campaign.mapsArr.Length; i++) {
            WarriorMedals::Map@ map = campaign.mapsArr[i];
            if (map is null)
                continue;

            if (map.pb < (map.custom > 0 ? map.custom : map.warrior))
                indicesToShow.InsertLast(map.index);
        }
    }

    uint indexOffset = 0;
    for (uint i = 0; i < Maps.Controls.Length; i++) {
        if (indexOffset > 6)
            break;

        if (indicesToShow.Length == 0)
            break;

        CGameManialinkFrame@ Map = cast<CGameManialinkFrame@>(Maps.Controls[i]);
        if (Map is null || !Map.Visible) {
            indexOffset++;
            continue;
        }

        if (indicesToShow.Find(i - indexOffset) == -1)  // needs to be here dumbass :)
            continue;

        CGameManialinkFrame@ MedalStack = cast<CGameManialinkFrame@>(Map.GetFirstChild("frame-medalstack"));
        if (MedalStack is null || !MedalStack.Visible)
            continue;

        const float w = Draw::GetWidth();
        const float h = Draw::GetHeight();
        const float unit = (w / h < 16.0f / 9.0f) ? w / 320.0f : h / 180.0f;
        const vec2 offset = vec2(-118.2f, 1.2f);
        const vec2 columnOffset = vec2(29.1f, 0.0f);
        const vec2 rowOffset = vec2(-2.02f, -11.5f);
        const vec2 coords = vec2(w * 0.5f, h * 0.5f)
            + vec2(unit, -unit) * (
                offset
                + ((i % 7) * columnOffset)
                + ((i / 7) * rowOffset)
            )
        ;

        nvg::BeginPath();
        nvg::FillPaint(nvg::TexturePattern(coords, vec2(unit * 9.15f), 0.0f, iconUI, 1.0f));
        nvg::Fill();
    }
}

void DrawOverTrainingPage(CGameManialinkPage@ Page) {
    if (Page is null)
        return;

    DrawCampaign(cast<CGameManialinkFrame@>(Page.GetFirstChild("frame-maps")), "training", true);
}
