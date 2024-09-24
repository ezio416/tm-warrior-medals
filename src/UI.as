// c 2024-07-22
// m 2024-09-24

uint FrameConfirmQuit = 0;

enum PlaygroundPageType {
    Record,
    Start,
    Pause,
    End
}

void DrawOverUI() {
    if (false
        || !S_UIMedals
        || iconUI is null
        || (true
            && !S_UIMedalsSeasonalCampaign
            && !S_UIMedalsLiveCampaign
            && !S_UIMedalsTotd
            && !S_UIMedalsClubCampaign
            && !S_UIMedalsTraining
            && !S_UIMedalBanner
            && !S_UIMedalStart
            && !S_UIMedalPause
            && !S_UIMedalEnd
        )
    )
        return;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    NGameLoadProgress_SMgr@ LoadProgress = App.LoadProgress;
    if (LoadProgress !is null && LoadProgress.State != NGameLoadProgress::EState::Disabled)
        return;

    CDx11Viewport@ Viewport = cast<CDx11Viewport@>(App.Viewport);
    if (Viewport is null || Viewport.Overlays.Length == 0)
        return;

    for (int i = Viewport.Overlays.Length - 1; i >= 0; i--) {
        CHmsZoneOverlay@ Overlay = Viewport.Overlays[i];
        if (false
            || Overlay is null
            || Overlay.m_CorpusVisibles.Length == 0
            || Overlay.m_CorpusVisibles[0] is null
            || Overlay.m_CorpusVisibles[0].Item is null
            || Overlay.m_CorpusVisibles[0].Item.SceneMobil is null
        )
            continue;

        if (FrameConfirmQuit > 0 && FrameConfirmQuit == Overlay.m_CorpusVisibles[0].Item.SceneMobil.Id.Value)
            return;

        if (Overlay.m_CorpusVisibles[0].Item.SceneMobil.IdName == "FrameConfirmQuit") {
            FrameConfirmQuit = Overlay.m_CorpusVisibles[0].Item.SceneMobil.Id.Value;
            return;
        }
    }

    CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);
    CTrackManiaNetworkServerInfo@ ServerInfo = cast<CTrackManiaNetworkServerInfo@>(Network.ServerInfo);

    if (InMap()) {
        if (false
            || !UI::IsGameUIVisible()
            || !maps.Exists(App.RootMap.EdChallengeId)
        )
            return;

        WarriorMedals::Map@ map = cast<WarriorMedals::Map@>(maps[App.RootMap.EdChallengeId]);
        if (false
            || map is null
            || !map.hasWarrior
        )
            return;

        CGameManiaAppPlayground@ CMAP = Network.ClientManiaAppPlayground;
        if (false
            || CMAP is null
            || CMAP.UILayers.Length < 23
            || CMAP.UI is null
        )
            return;

        const bool endSequence = CMAP.UI.UISequence == CGamePlaygroundUIConfig::EUISequence::EndRound;

        const bool startSequence = false
            || CMAP.UI.UISequence == CGamePlaygroundUIConfig::EUISequence::Intro
            || CMAP.UI.UISequence == CGamePlaygroundUIConfig::EUISequence::RollingBackgroundIntro
            || endSequence
        ;

        const bool lookForBanner = ServerInfo.CurGameModeStr.Contains("_Online") || ServerInfo.CurGameModeStr.Contains("PlayMap");

        CGameManialinkPage@ ScoresTable;
        CGameManialinkPage@ Record;
        CGameManialinkPage@ Start;
        CGameManialinkPage@ Pause;
        CGameManialinkPage@ End;

        for (uint i = 0; i < CMAP.UILayers.Length; i++) {
            const bool pauseDisplayed = S_UIMedalPause && Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed;

            if (true
                && !(Record is null && S_UIMedalBanner && lookForBanner)
                && !(Start  is null && S_UIMedalStart  && startSequence)
                && !(Pause  is null && pauseDisplayed)
                && !(End    is null && S_UIMedalEnd    && endSequence)
            )
                break;

            CGameUILayer@ Layer = CMAP.UILayers[i];
            if (false
                || Layer is null
                || !Layer.IsVisible
                || (true
                    && Layer.Type != CGameUILayer::EUILayerType::Normal
                    && Layer.Type != CGameUILayer::EUILayerType::InGameMenu
                )
                || Layer.ManialinkPageUtf8.Length == 0
            )
                continue;

            const string pageName = Layer.ManialinkPageUtf8.Trim().SubStr(0, 64);

            if (true
                && pauseDisplayed
                && ScoresTable is null
                && Layer.Type == CGameUILayer::EUILayerType::Normal
                && pageName.Contains("_Race_ScoresTable")
            ) {
                @ScoresTable = Layer.LocalPage;
                continue;
            }

            if (true
                && lookForBanner
                && !startSequence
                && S_UIMedalBanner
                && Record is null
                && Layer.Type == CGameUILayer::EUILayerType::Normal
                && pageName.Contains("_Race_Record")
            ) {
                @Record = Layer.LocalPage;
                continue;
            }

            if (true
                && startSequence
                && S_UIMedalStart
                && Start is null
                && Layer.Type == CGameUILayer::EUILayerType::Normal
                && pageName.Contains("_StartRaceMenu")
            ) {
                @Start = Layer.LocalPage;
                continue;
            }

            if (true
                && S_UIMedalPause
                && Pause is null
                && Layer.Type == CGameUILayer::EUILayerType::InGameMenu
                && pageName.Contains("_PauseMenu")
            ) {
                @Pause = Layer.LocalPage;
                continue;
            }

            if (true
                && endSequence
                && S_UIMedalEnd
                && End is null
                && Layer.Type == CGameUILayer::EUILayerType::Normal
                && pageName.Contains("_EndRaceMenu")
            ) {
                @End = Layer.LocalPage;
                continue;
            }
        }

        DrawOverPlaygroundPage(Record, PlaygroundPageType::Record);
        DrawOverPlaygroundPage(Start);
        DrawOverPlaygroundPage(Pause, PlaygroundPageType::Pause, ScoresTable);
        DrawOverPlaygroundPage(End, PlaygroundPageType::End);

        return;
    }

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
            && !(Campaign     is null && (S_UIMedalsSeasonalCampaign || S_UIMedalsClubCampaign))
            && !(LiveCampaign is null && S_UIMedalsLiveCampaign)
            && !(Totd         is null && S_UIMedalsTotd)
            // && !(LiveTotd     is null && S_UIMedalsLiveTotd)
            && !(Training     is null && S_UIMedalsTraining)
        )
            break;

        CGameUILayer@ Layer = Title.UILayers[i];
        if (false
            || Layer is null
            || Layer.LocalPage is null
            || !Layer.IsVisible
            || Layer.Type != CGameUILayer::EUILayerType::Normal
            || Layer.ManialinkPageUtf8.Length == 0
        )
            continue;

        const string pageName = Layer.ManialinkPageUtf8.Trim().SubStr(17, 27);

        if (pageName.StartsWith("Overlay_ReportSystem")) {
            CGameManialinkFrame@ Frame = cast<CGameManialinkFrame@>(Layer.LocalPage.GetFirstChild("frame-report-system"));
            if (Frame !is null && Frame.Visible)
                return;
        }

        // if (true
        //     && S_UIMedalsLiveTotd
        //     && LiveTotd is null
            // && pageName.StartsWith("Page_TOTDChannelDisplay")
        // ) {
        //     @LiveTotd = Layer.LocalPage;
        //     continue;
        // }

        if (true
            && (S_UIMedalsSeasonalCampaign || S_UIMedalsClubCampaign)
            && Campaign is null
            && pageName.StartsWith("Page_CampaignDisplay")
        ) {
            @Campaign = Layer.LocalPage;
            continue;
        }

        if (true
            && S_UIMedalsTotd
            && Totd is null
            && pageName.StartsWith("Page_MonthlyCampaignDisplay")
        ) {
            @Totd = Layer.LocalPage;
            continue;
        }

        if (true
            && S_UIMedalsTraining
            && Training is null
            && pageName.StartsWith("Page_TrainingDisplay")
        ) {
            @Training = Layer.LocalPage;
            continue;
        }

        if (true
            && S_UIMedalsLiveCampaign
            && LiveCampaign is null
            && pageName.StartsWith("Page_RoomCampaignDisplay")
        ) {
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

void DrawCampaign(CGameManialinkFrame@ Maps, const string &in uid, bool club = false) {
    if (Maps is null || uid.Length == 0)
        return;

    int8[] indicesToShow;
    Campaign@ campaign = GetCampaign(uid);
    if (campaign !is null) {
        for (uint i = 0; i < campaign.mapsArr.Length; i++) {
            WarriorMedals::Map@ map = campaign.mapsArr[i];
            if (map is null)
                continue;

            if (map.hasWarrior)
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

        const float w         = Draw::GetWidth();
        const float h         = Draw::GetHeight();
        const vec2  center    = vec2(w * 0.5f, h * 0.5f);
        const float unit      = (w / h < 16.0f / 9.0f) ? w / 320.0f : h / 180.0f;
        const vec2  scale     = vec2(unit, -unit);
        const vec2  offset    = vec2(-99.8f, 1.05f) + (club ? vec2(0.4f, 2.51f) : vec2());
        const vec2  rowOffset = vec2(-2.02f, -11.5f) * (i % 5);
        const vec2  colOffset = vec2(36.0f, 0.0f) * (i / 5);
        const vec2  coords    = center + scale * (offset + rowOffset + colOffset);

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
        if (!S_UIMedalsClubCampaign)
            return;
    } else {
        if (!S_UIMedalsSeasonalCampaign)
            return;
        campaignName = campaignName.SubStr(19).Replace("\u0091", " ");
    }

    DrawCampaign(cast<CGameManialinkFrame@>(Page.GetFirstChild("frame-maps")), CampaignUid(campaignName, clubName), club);
}

void DrawOverLiveCampaignPage(CGameManialinkPage@ Page) {
    if (Page is null)
        return;

    string campaignName;
    CGameManialinkLabel@ CampaignLabel = cast<CGameManialinkLabel@>(Page.GetFirstChild("label-title"));
    if (CampaignLabel !is null)
        campaignName = string(CampaignLabel.Value).SubStr(19).Replace("\u0091", " ");

    DrawCampaign(cast<CGameManialinkFrame@>(Page.GetFirstChild("frame-maps")), CampaignUid(campaignName), false);
}

// void DrawOverLiveTotdPage(CGameManialinkPage@ Page) {
//     if (Page is null)
//         return;

//     CGameManialinkFrame@ PrevDay = cast<CGameManialinkFrame@>(Page.GetFirstChild("frame-previous-day"));
//     if (PrevDay is null || !PrevDay.Visible)
//         return;

//     CGameManialinkLabel@ DayLabel = cast<CGameManialinkLabel@>(PrevDay.GetFirstChild("label-day"));
//     if (DayLabel is null)
//         return;

//     const string date = string(DayLabel.Value).SubStr(19).Replace("%1\u0091", "");
//     UI::Text(date);

//     uint month = 0;

//     const uint day = Text::ParseUInt(date.SubStr(date.Length - 2));
//     UI::Text(tostring(day));

//     CGameManialinkFrame@ MedalStack = cast<CGameManialinkFrame@>(PrevDay.GetFirstChild("frame-medal-stack"));
//     if (MedalStack is null || !MedalStack.Visible)
//         return;

//     UI::Text("medal stack");
// }

void DrawOverPlaygroundPage(CGameManialinkPage@ Page, PlaygroundPageType type = PlaygroundPageType::Start, CGameManialinkPage@ ScoresTable = null) {
    if (Page is null)
        return;

    if (type == PlaygroundPageType::Pause) {
        CTrackMania@ App = cast<CTrackMania@>(GetApp());
        CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);
        if (!Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed)
            return;

        CGameManialinkFrame@ Settings = cast<CGameManialinkFrame@>(Page.GetFirstChild("frame-settings"));
        if (Settings !is null && Settings.Visible)
            return;

        if (ScoresTable !is null) {
            CGameManialinkFrame@ TableLayer = cast<CGameManialinkFrame@>(ScoresTable.GetFirstChild("frame-scorestable-layer"));
            if (TableLayer !is null && TableLayer.Visible)
                return;
        }
    } else {
        CGameManialinkFrame@ Global = cast<CGameManialinkFrame@>(Page.GetFirstChild("frame-global"));
        if (Global is null || !Global.Visible)
            return;
    }

    const bool banner = type == PlaygroundPageType::Record;

    CGameManialinkControl@ Medal = Page.GetFirstChild(banner ? "quad-medal" : "ComponentMedalStack_frame-global");
    if (false
        || Medal is null
        || !Medal.Visible
        || (banner && (false
            || !Medal.Parent.Visible  // not visible in campaign mode, probably others
            || Medal.AbsolutePosition_V3.x < -170.0f  // off screen
        ))
    )
        return;

    const float w      = Draw::GetWidth();
    const float h      = Draw::GetHeight();
    const vec2  center = vec2(w * 0.5f, h * 0.5f);
    const float hUnit  = h / 180.0f;
    const vec2  scale  = vec2((w / h > 16.0f / 9.0f) ? hUnit : w / 320.0f, -hUnit);
    const vec2  size   = vec2(banner ? 21.9f : 19.584f) * hUnit;
    const vec2  offset = vec2(banner ? -size.x * 0.5f : 0.0f, -size.y * 0.5f);
    const vec2  coords = center + offset + scale * (Medal.AbsolutePosition_V3 + vec2(banner ? 0.0f : 12.16f, 0.0f));

    const bool end = type == PlaygroundPageType::End;

    CGameManialinkFrame@ MenuContent;
    if (end)
        @MenuContent = cast<CGameManialinkFrame@>(Page.GetFirstChild("frame-menu-content"));

    if (false
        || !end
        || (MenuContent !is null && MenuContent.Visible)
    ) {
        nvg::BeginPath();
        nvg::FillPaint(nvg::TexturePattern(coords, size, 0.0f, iconUI, 1.0f));
        nvg::Fill();
    }

    CGameManialinkFrame@ NewMedal = cast<CGameManialinkFrame@>(Page.GetFirstChild("frame-new-medal"));
    if (NewMedal is null || !NewMedal.Visible)
        return;

    CGameManialinkQuad@ QuadMedal = cast<CGameManialinkQuad@>(NewMedal.GetFirstChild("quad-medal-anim"));
    if (false
        || QuadMedal is null
        || !QuadMedal.Visible
        || QuadMedal.AbsolutePosition_V3.x > -85.0f  // end race menu still hidden
    )
        return;

    const vec2 quadMedalOffset = vec2(-size.x, -size.y) * 1.15f;
    const vec2 quadMedalCoords = center + quadMedalOffset + scale * QuadMedal.AbsolutePosition_V3;
    const vec2 quadMedalSize   = vec2(45.0f * hUnit);

    nvg::BeginPath();
    nvg::FillPaint(nvg::TexturePattern(quadMedalCoords, quadMedalSize, 0.0f, iconUI, 1.0f));
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

    int8[] indicesToShow;
    Campaign@ campaign = GetCampaign(CampaignUid(monthName));
    if (campaign !is null) {
        for (uint i = 0; i < campaign.mapsArr.Length; i++) {
            WarriorMedals::Map@ map = campaign.mapsArr[i];
            if (map is null)
                continue;

            if (map.hasWarrior)
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

        const float w         = Draw::GetWidth();
        const float h         = Draw::GetHeight();
        const vec2  center    = vec2(w * 0.5f, h * 0.5f);
        const float unit      = (w / h < 16.0f / 9.0f) ? w / 320.0f : h / 180.0f;
        const vec2  scale     = vec2(unit, -unit);
        const vec2  offset    = vec2(-118.2f, 1.2f);
        const vec2  colOffset = vec2(29.1f, 0.0f) * (i % 7);
        const vec2  rowOffset = vec2(-2.02f, -11.5f) * (i / 7);
        const vec2  coords    = center + scale * (offset + colOffset + rowOffset);

        nvg::BeginPath();
        nvg::FillPaint(nvg::TexturePattern(coords, vec2(unit * 9.15f), 0.0f, iconUI, 1.0f));
        nvg::Fill();
    }
}

void DrawOverTrainingPage(CGameManialinkPage@ Page) {
    if (Page is null)
        return;

    DrawCampaign(cast<CGameManialinkFrame@>(Page.GetFirstChild("frame-maps")), CampaignUid("training"), true);
}
