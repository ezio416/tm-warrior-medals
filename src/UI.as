const float stdRatio                = 16.0f / 9.0f;
uint        valueOverlayConfirmQuit = 0;
uint        valueOverlaySettings    = 0;

enum PlaygroundPageType {
    Record,
    Start,
    Pause,
    End
}

void DrawOverUI() {
    if (false
        or !S_UIMedals
        or iconWarriorNvg is null
        or (true
            and !S_UIMedalsSoloMenu
            and !S_UIMedalsSeasonalCampaign
            and !S_UIMedalsLiveCampaign
            and !S_UIMedalsLiveTotd
            and !S_UIMedalsTotd
            and !S_UIMedalsClubCampaign
            and !S_UIMedalsWeekly
            and !S_UIMedalBanner
            and !S_UIMedalStart
            and !S_UIMedalPause
            and !S_UIMedalEnd
        )
    ) {
        return;
    }

    auto App = cast<CTrackMania>(GetApp());

    if (false
        or App.Editor !is null
        or App.Viewport is null
        or App.Viewport.Overlays.Length == 0
        or (true
            and App.LoadProgress !is null
            and App.LoadProgress.State != NGameLoadProgress::EState::Disabled
        )
    ) {
        return;
    }

    for (int i = App.Viewport.Overlays.Length - 1; i >= 0; i--) {
        CHmsZoneOverlay@ Overlay = App.Viewport.Overlays[i];
        if (false
            or Overlay is null
            or Overlay.m_CorpusVisibles.Length == 0
            or Overlay.m_CorpusVisibles[0] is null
            or Overlay.m_CorpusVisibles[0].Item is null
            or Overlay.m_CorpusVisibles[0].Item.SceneMobil is null
        ) {
            continue;
        }

        if (false
            or (true
                and valueOverlayConfirmQuit > 0
                and valueOverlayConfirmQuit == Overlay.m_CorpusVisibles[0].Item.SceneMobil.Id.Value
            )
            or (true
                and valueOverlaySettings > 0
                and valueOverlaySettings == Overlay.m_CorpusVisibles[0].Item.SceneMobil.Id.Value
                and Overlay.m_CorpusVisibles.Length > 300
                and Overlay.m_CorpusVisibles[0].Item.IsVisible
            )
        ) {
            return;
        }

        if (Overlay.m_CorpusVisibles[0].Item.SceneMobil.IdName == "FrameConfirmQuit") {
            valueOverlayConfirmQuit = Overlay.m_CorpusVisibles[0].Item.SceneMobil.Id.Value;
            return;
        }

        if (Overlay.m_CorpusVisibles[0].Item.SceneMobil.IdName == "InterfaceRoot") {
            auto Mobil = cast<CControlFrameStyled>(Overlay.m_CorpusVisibles[0].Item.SceneMobil);
            if (true
                and Mobil !is null
                and Mobil.Childs.Length > 0
                and Mobil.Childs[0] !is null
                and Mobil.Childs[0].IdName == "FrameManialinkPageContainer"
            ) {
                valueOverlaySettings = Mobil.Id.Value;
            }
        }
    }

    auto Network = cast<CTrackManiaNetwork>(App.Network);
    auto ServerInfo = cast<CTrackManiaNetworkServerInfo>(Network.ServerInfo);

    if (InMap()) {
        if (false
            or !UI::IsGameUIVisible()
            or (true
                and !S_UIMedalsAlwaysPlayground
                and !maps.Exists(App.RootMap.EdChallengeId)
            )
        ) {
            return;
        }

        if (!S_UIMedalsAlwaysPlayground) {
            auto map = cast<WarriorMedals::Map>(maps[App.RootMap.EdChallengeId]);
            if (false
                or map is null
                or !map.hasWarrior
            ) {
                return;
            }
        }

        CGameManiaAppPlayground@ CMAP = Network.ClientManiaAppPlayground;
        if (false
            or CMAP is null
            or CMAP.UILayers.Length < 23
            or CMAP.UI is null
        ) {
            return;
        }

        const bool endSequence = CMAP.UI.UISequence == CGamePlaygroundUIConfig::EUISequence::EndRound;

        const bool startSequence = false
            or CMAP.UI.UISequence == CGamePlaygroundUIConfig::EUISequence::Intro
            or CMAP.UI.UISequence == CGamePlaygroundUIConfig::EUISequence::RollingBackgroundIntro
            or endSequence
        ;

        const bool lookForBanner = false
            or ServerInfo.CurGameModeStr.Contains("_Online")
            or ServerInfo.CurGameModeStr.Contains("PlayMap")
        ;

        CGameManialinkPage@ ScoresTable;
        CGameManialinkPage@ Record;
        CGameManialinkPage@ Start;
        CGameManialinkPage@ Pause;
        CGameManialinkPage@ End;

        const bool pauseDisplayed = true
            and S_UIMedalPause
            and Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed
        ;

        int start, end;
        string pageName;

        for (uint i = 0; i < CMAP.UILayers.Length; i++) {
            if (true
                and !(true
                    and Record is null
                    and S_UIMedalBanner
                    and lookForBanner
                )
                and !(true
                    and Start is null
                    and S_UIMedalStart
                    and startSequence
                )
                and !(true
                    and Pause is null
                    and pauseDisplayed
                )
                and !(true
                    and End is null
                    and S_UIMedalEnd
                    and endSequence
                )
            ) {
                break;
            }

            CGameUILayer@ Layer = CMAP.UILayers[i];
            if (false
                or Layer is null
                or !Layer.IsVisible
                or (true
                    and Layer.Type != CGameUILayer::EUILayerType::Normal
                    and Layer.Type != CGameUILayer::EUILayerType::InGameMenu
                )
                or Layer.ManialinkPageUtf8.Length == 0
            ) {
                continue;
            }

            start = Layer.ManialinkPageUtf8.IndexOf("<");
            end = Layer.ManialinkPageUtf8.IndexOf(">");
            if (false
                or start == -1
                or end == -1
                or end <= start + 1
            ) {
                continue;
            }
            pageName = Layer.ManialinkPageUtf8.SubStr(start + 1, end - start - 1);

            if (true
                and pauseDisplayed
                and ScoresTable is null
                and Layer.Type == CGameUILayer::EUILayerType::Normal
                and pageName.Contains("_Race_ScoresTable")
            ) {
                @ScoresTable = Layer.LocalPage;
                continue;
            }

            if (true
                and lookForBanner
                and !startSequence
                and S_UIMedalBanner
                and Record is null
                and Layer.Type == CGameUILayer::EUILayerType::Normal
                and pageName.Contains("_Race_Record")
            ) {
                @Record = Layer.LocalPage;
                continue;
            }

            if (true
                and startSequence
                and S_UIMedalStart
                and Start is null
                and Layer.Type == CGameUILayer::EUILayerType::Normal
                and pageName.Contains("_StartRaceMenu")
            ) {
                @Start = Layer.LocalPage;
                continue;
            }

            if (true
                and S_UIMedalPause
                and Pause is null
                and Layer.Type == CGameUILayer::EUILayerType::InGameMenu
                and pageName.Contains("_PauseMenu")
            ) {
                @Pause = Layer.LocalPage;
                continue;
            }

            if (true
                and endSequence
                and S_UIMedalEnd
                and End is null
                and Layer.Type == CGameUILayer::EUILayerType::Normal
                and pageName.Contains("_EndRaceMenu")
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

    if (ServerInfo.CurGameModeStr.Length > 0) {
        return;
    }

    auto Menus = cast<CTrackManiaMenus>(App.MenuManager);
    if (Menus is null) {
        return;
    }

    CGameManiaAppTitle@ Title = Menus.MenuCustom_CurrentManiaApp;
    if (false
        or Title is null
        or Title.UILayers.Length == 0
    ) {
        return;
    }

    CGameManialinkPage@ Solo;
    CGameManialinkPage@ Campaign;
    CGameManialinkPage@ LiveCampaign;
    CGameManialinkPage@ LiveTotd;
    CGameManialinkPage@ Totd;

    int start, end;
    string pageName;

    for (uint i = 0; i < Title.UILayers.Length; i++) {
        if (true
            and !(true
                and Campaign is null
                and (false
                    or S_UIMedalsSeasonalCampaign
                    or S_UIMedalsClubCampaign
                    or S_UIMedalsWeekly
                )
            )
            and !(true
                and LiveCampaign is null
                and S_UIMedalsLiveCampaign
            )
            and !(true
                and Totd is null
                and S_UIMedalsTotd
            )
            and !(true
                and LiveTotd is null
                and S_UIMedalsLiveTotd
            )
        ) {
            break;
        }

        CGameUILayer@ Layer = Title.UILayers[i];
        if (false
            or Layer is null
            or Layer.LocalPage is null
            or !Layer.IsVisible
            or Layer.Type != CGameUILayer::EUILayerType::Normal
            or Layer.ManialinkPageUtf8.Length == 0
        ) {
            continue;
        }

        start = Layer.ManialinkPageUtf8.IndexOf("<");
        end = Layer.ManialinkPageUtf8.IndexOf(">");
        if (false
            or start == -1
            or end == -1
            or end <= start + 1
        ) {
            continue;
        }
        pageName = Layer.ManialinkPageUtf8.SubStr(start + 1, end - start - 1);

        if (pageName.Contains("Overlay_ReportSystem")) {  // 2025-07-04_14_15 index 7
            auto Frame = cast<CGameManialinkFrame>(Layer.LocalPage.GetFirstChild("frame-report-system"));
            if (true
                and Frame !is null
                and Frame.Visible
            ) {
                return;
            }
        }

        if (true
            and S_UIMedalsSoloMenu
            and Solo is null
            and pageName.Contains("Page_Solo")  // 2025-07-04_14_15 index 15
        ) {
            @Solo = Layer.LocalPage;
            continue;
        }

        if (true
            and S_UIMedalsLiveTotd
            and LiveTotd is null
            and pageName.Contains("Page_TOTDChannelDisplay")  // 2025-07-04_14_15 index 25
        ) {
            @LiveTotd = Layer.LocalPage;
            continue;
        }

        if (true
            and (false
                or S_UIMedalsSeasonalCampaign
                or S_UIMedalsClubCampaign
                or S_UIMedalsWeekly
            )
            and Campaign is null
            and pageName.Contains("Page_CampaignDisplay")  // 2025-07-04_14_15 index 28
        ) {
            @Campaign = Layer.LocalPage;
            continue;
        }

        if (true
            and S_UIMedalsTotd
            and Totd is null
            and pageName.Contains("Page_MonthlyCampaignDisplay")  // 2025-07-04_14_15 index 29
        ) {
            @Totd = Layer.LocalPage;
            continue;
        }

        if (true
            and S_UIMedalsLiveCampaign
            and LiveCampaign is null
            and pageName.Contains("Page_RoomCampaignDisplay")  // 2025-07-04_14_15 index 39
        ) {
            @LiveCampaign = Layer.LocalPage;
            continue;
        }
    }

    if (true
        and Campaign is null
        and Totd is null
    ) {
        DrawOverSoloPage(Solo);
    }
    DrawOverCampaignPage(Campaign);
    DrawOverLiveCampaignPage(LiveCampaign);
    DrawOverLiveTotdPage(LiveTotd);
    DrawOverTotdPage(Totd);
}

void DrawCampaign(CGameManialinkFrame@ Maps, const string&in uid, const bool club = false, const bool live = false) {
    if (false
        or Maps is null
        or uid.Length == 0
    ) {
        return;
    }

    Campaign@ campaign = GetCampaign(uid);
    if (campaign is null) {
        return;
    }

    int8[] indicesToShow;
    for (uint i = 0; i < campaign.mapsArr.Length; i++) {
        WarriorMedals::Map@ map = campaign.mapsArr[i];
        if (map is null) {
            continue;
        }

        if (false
            or map.hasWarrior
            or S_UIMedalsAlwaysMenu
        ) {
            indicesToShow.InsertLast(map.index);
        }
    }

    const string medalStackName = live ? "frame-medalstack" : "frame-medal-stack";

    const float w      = Math::Max(1, Draw::GetWidth());
    const float h      = Math::Max(1, Draw::GetHeight());
    const vec2  center = vec2(w * 0.5f, h * 0.5f);
    const float unit   = (w / h < stdRatio) ? w / 320.0f : h / 180.0f;
    const vec2  scale  = vec2(unit, -unit);
    const vec2  size   = vec2(unit * 9.6f);
    const vec2  offset = vec2(-99.8f, 1.05f) + (club ? vec2(0.4f, 2.51f) : vec2());

    for (uint i = 0; i < Maps.Controls.Length; i++) {
        if (indicesToShow.Length == 0) {
            break;
        }

        if (indicesToShow.Find(i) == -1) {
            continue;
        }

        auto Map = cast<CGameManialinkFrame>(Maps.Controls[i]);
        if (false
            or Map is null
            or !Map.Visible
        ) {
            continue;
        }

        auto MedalStack = cast<CGameManialinkFrame>(Map.GetFirstChild(medalStackName));
        if (false
            or MedalStack is null
            or !MedalStack.Visible
        ) {
            continue;
        }

        const vec2 rowOffset = vec2(-2.02f, -11.5f) * (i % 5);
        const vec2 colOffset = vec2(36.0f, 0.0f) * (i / 5);
        const vec2 coords    = center + scale * (offset + rowOffset + colOffset);

        nvg::BeginPath();
        nvg::FillPaint(nvg::TexturePattern(coords, size, 0.0f, iconWarriorNvg, 1.0f));
        nvg::Fill();
    }
}

void _DrawWeekly(CGameManialinkPage@ Page, const string&in campaignName) {
    if (!S_UIMedalsWeekly) {
        return;
    }

    uint week = 0;
    if (!Text::TryParseUInt(campaignName.SubStr(11), week)) {
        return;
    }

    Campaign@ campaign = GetCampaign(CampaignUid("week " + week));
    if (campaign is null) {
        return;
    }

    int8[] indicesToShow;
    for (uint i = 0; i < campaign.mapsArr.Length; i++) {
        WarriorMedals::Map@ map = campaign.mapsArr[i];
        if (map is null) {
            continue;
        }

        if (false
            or map.hasWarrior
            or S_UIMedalsAlwaysMenu
        ) {
            indicesToShow.InsertLast(map.index);
        }
    }

    auto Maps = cast<CGameManialinkFrame>(Page.GetFirstChild("frame-short-maps"));
    if (Maps is null) {
        return;
    }

    const float w      = Math::Max(1, Draw::GetWidth());
    const float h      = Math::Max(1, Draw::GetHeight());
    const vec2  center = vec2(w * 0.5f, h * 0.5f);
    const float unit   = (w / h < stdRatio) ? w / 320.0f : h / 180.0f;
    const vec2  scale  = vec2(unit, -unit);
    const vec2  size   = vec2(unit * 12.04f);
    const vec2  offset = vec2(size.x * 0.015f, -size.y * 0.5f);

    for (uint i = 0; i < Maps.Controls.Length; i++) {
        if (indicesToShow.Length == 0) {
            break;
        }

        if (indicesToShow.Find(i) == -1) {
            continue;
        }

        auto Map = cast<CGameManialinkFrame>(Maps.Controls[i]);
        if (false
            or Map is null
            or !Map.Visible
        ) {
            continue;
        }

        auto MedalStack = cast<CGameManialinkFrame>(Map.GetFirstChild("frame-medal-stack"));
        if (false
            or MedalStack is null
            or !MedalStack.Visible
        ) {
            continue;
        }

        const vec2 coords = center + offset + scale * MedalStack.AbsolutePosition_V3;

        nvg::BeginPath();
        nvg::FillPaint(nvg::TexturePattern(coords, size, 0.0f, iconWarriorNvg, 1.0f));
        nvg::Fill();
    }
}

void DrawOverCampaignPage(CGameManialinkPage@ Page) {
    if (Page is null) {
        return;
    }

    string campaignName;
    auto CampaignLabel = cast<CGameManialinkLabel>(Page.GetFirstChild("label-title"));
    if (CampaignLabel !is null) {
        campaignName = CampaignLabel.Value;
    }

    if (campaignName.StartsWith("\u0091Week %1\u0091")) {
        _DrawWeekly(Page, campaignName);
        return;
    }

    string clubName;
    auto ClubLink = cast<CGameManialinkFrame>(Page.GetFirstChild("button-club"));
    if (true
        and ClubLink !is null
        and ClubLink.Visible
    ) {
        auto ClubLabel = cast<CGameManialinkLabel>(ClubLink.GetFirstChild("menu-libs-expendable-button_label-button-text"));
        if (ClubLabel !is null) {
            clubName = ClubLabel.Value.SubStr(15);
        }
    }
    const bool club = clubName.Length > 0;

    if (club) {
        if (!S_UIMedalsClubCampaign) {
            return;
        }
    } else {
        if (!S_UIMedalsSeasonalCampaign) {
            return;
        }
        campaignName = campaignName.SubStr(19).Replace("\u0091", " ");
    }

    DrawCampaign(cast<CGameManialinkFrame>(Page.GetFirstChild("frame-maps")), CampaignUid(campaignName, clubName), club);
}

void DrawOverLiveCampaignPage(CGameManialinkPage@ Page) {
    if (Page is null) {
        return;
    }

    string campaignName;
    CGameManialinkLabel@ CampaignLabel = cast<CGameManialinkLabel>(Page.GetFirstChild("label-title"));
    if (CampaignLabel !is null) {
        campaignName = string(CampaignLabel.Value).SubStr(19).Replace("\u0091", " ");
    }

    DrawCampaign(cast<CGameManialinkFrame>(Page.GetFirstChild("frame-maps")), CampaignUid(campaignName), live:true);
}

void DrawOverLiveTotdPage(CGameManialinkPage@ Page) {  // should shift the medal stack left, figure out later?
    if (false
        or Page is null
        or previousTotd is null
        or (true
            and !previousTotd.hasWarrior
            and !S_UIMedalsAlwaysMenu
        )
    ) {
        return;
    }

    auto PrevDay = cast<CGameManialinkFrame>(Page.GetFirstChild("frame-previous-day"));
    if (false
        or PrevDay is null
        or !PrevDay.Visible
    ) {
        return;
    }

    auto MedalStack = cast<CGameManialinkFrame>(PrevDay.GetFirstChild("frame-medal-stack"));
    if (false
        or MedalStack is null
        or !MedalStack.Visible
    ) {
        return;
    }

    auto DayLabel = cast<CGameManialinkLabel>(PrevDay.GetFirstChild("label-day"));
    if (DayLabel is null) {
        return;
    }

    const string date = string(DayLabel.Value).SubStr(19).Replace("%1\u0091", "");

    string[]@ previousParts = previousTotd.date.Split("-");
    if (false
        or previousParts.Length < 3
        or Text::ParseUInt(date.SubStr(date.Length - 2)) != Text::ParseUInt(previousParts[2])
    ) {
        return;
    }

    string previousMonth;
    switch (Text::ParseUInt(previousParts[1])) {
        case 1:  previousMonth = "Jan"; break;
        case 2:  previousMonth = "Feb"; break;
        case 3:  previousMonth = "Mar"; break;
        case 4:  previousMonth = "Apr"; break;
        case 5:  previousMonth = "May"; break;
        case 6:  previousMonth = "Jun"; break;
        case 7:  previousMonth = "Jul"; break;
        case 8:  previousMonth = "Aug"; break;
        case 9:  previousMonth = "Sep"; break;
        case 10: previousMonth = "Oct"; break;
        case 11: previousMonth = "Nov"; break;
        case 12: previousMonth = "Dev"; break;
        default: return;
    }

    if (date.SubStr(0, 3) != previousMonth) {
        return;
    }

    const float w      = Math::Max(1, Draw::GetWidth());
    const float h      = Math::Max(1, Draw::GetHeight());
    const vec2  center = vec2(w * 0.5f, h * 0.5f);
    const float unit   = (w / h < stdRatio) ? w / 320.0f : h / 180.0f;
    const vec2  scale  = vec2(unit, -unit);
    const vec2  size   = vec2(unit * 19.0f);
    const vec2  offset = vec2(size.x * 0.013f, -size.y * 0.5f);
    const vec2  coords = center + offset + scale * MedalStack.AbsolutePosition_V3;

    nvg::BeginPath();
    nvg::FillPaint(nvg::TexturePattern(coords, size, 0.0f, iconWarriorNvg, 1.0f));
    nvg::Fill();
}

const string[] pgFrames = {
    "frame-help",
    "frame-map-list",
    "frame-options",
    "frame-prestige",
    "frame-profile",
    "frame-report-system",
    "frame-server",
    "frame-settings",
    "frame-teams",
    "popupmultichoice-leave-match"
};

void DrawOverPlaygroundPage(CGameManialinkPage@ Page, const PlaygroundPageType type = PlaygroundPageType::Start, CGameManialinkPage@ ScoresTable = null) {
    if (Page is null) {
        return;
    }

    if (type == PlaygroundPageType::Pause) {
        if (!GetApp().Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed) {
            return;
        }

        if (ScoresTable !is null) {
            auto TableLayer = cast<CGameManialinkFrame>(ScoresTable.GetFirstChild("frame-scorestable-layer"));
            if (true
                and TableLayer !is null
                and TableLayer.Visible
            ) {
                return;
            }
        }

        for (uint i = 0; i < pgFrames.Length; i++) {
            auto Frame = cast<CGameManialinkFrame>(Page.GetFirstChild(pgFrames[i]));
            if (true
                and Frame !is null
                and Frame.Visible
            ) {
                return;
            }
        }

    } else {
        if (type == PlaygroundPageType::Start) {
            auto OpponentsList = cast<CGameManialinkFrame>(Page.GetFirstChild("frame-more-opponents-list"));
            if (true
                and OpponentsList !is null
                and OpponentsList.Visible
            ) {
                return;
            }
        }

        auto Global = cast<CGameManialinkFrame>(Page.GetFirstChild("frame-global"));
        if (false
            or Global is null
            or !Global.Visible
        ) {
            return;
        }
    }

    const bool banner = type == PlaygroundPageType::Record;

    CGameManialinkControl@ Medal = Page.GetFirstChild(banner ? "quad-medal" : "ComponentMedalStack_frame-global");
    if (false
        or Medal is null
        or !Medal.Visible
        or (true
            and banner
            and (false
                or !Medal.Parent.Visible  // not visible in campaign mode, probably others
                or Medal.AbsolutePosition_V3.x < -170.0f  // off screen
            )
        )
    ) {
        return;
    }

    const float w      = Math::Max(1, Draw::GetWidth());
    const float h      = Math::Max(1, Draw::GetHeight());
    const vec2  center = vec2(w * 0.5f, h * 0.5f);
    const float hUnit  = h / 180.0f;
    const vec2  scale  = vec2((w / h > stdRatio) ? hUnit : w / 320.0f, -hUnit);
    const vec2  size   = vec2(banner ? 21.9f : 19.584f) * hUnit;
    const vec2  offset = vec2(banner ? -size.x * 0.5f : 0.0f, -size.y * 0.5f);
    const vec2  coords = center + offset + scale * (Medal.AbsolutePosition_V3 + vec2(banner ? 0.0f : 12.16f, 0.0f));

    const bool end = type == PlaygroundPageType::End;

    CGameManialinkFrame@ MenuContent;
    if (end) {
        @MenuContent = cast<CGameManialinkFrame>(Page.GetFirstChild("frame-menu-content"));
        if (MenuContent is null) {  // must be in PlayMap mode?
            @MenuContent = cast<CGameManialinkFrame>(Page.GetFirstChild("frame-auto-hide"));
        }
    }

    if (false
        or !end
        or (true
            and MenuContent !is null
            and MenuContent.Visible
        )
    ) {
        nvg::BeginPath();
        nvg::FillPaint(nvg::TexturePattern(coords, size, 0.0f, iconWarriorNvg, 1.0f));
        nvg::Fill();
    }

    auto NewMedal = cast<CGameManialinkFrame>(Page.GetFirstChild("frame-new-medal"));
    if (false
        or NewMedal is null
        or !NewMedal.Visible
    ) {
        return;
    }

    auto QuadMedal = cast<CGameManialinkQuad>(NewMedal.GetFirstChild("quad-medal-anim"));
    if (false
        or QuadMedal is null
        or !QuadMedal.Visible
        or QuadMedal.AbsolutePosition_V3.x > -85.0f  // end race menu still hidden
    ) {
        return;
    }

    const vec2 quadMedalOffset = vec2(-size.x, -size.y) * 1.15f;
    const vec2 quadMedalCoords = center + quadMedalOffset + scale * QuadMedal.AbsolutePosition_V3;
    const vec2 quadMedalSize   = vec2(45.0f * hUnit);

    nvg::BeginPath();
    nvg::FillPaint(nvg::TexturePattern(quadMedalCoords, quadMedalSize, 0.0f, iconWarriorNvg, 1.0f));
    nvg::Fill();
}

void _DrawSoloMedal(CGameManialinkFrame@ MedalStack) {
    if (false
        or MedalStack is null
        or !MedalStack.Visible
    ) {
        return;
    }

    const float w      = Math::Max(1, Draw::GetWidth());
    const float h      = Math::Max(1, Draw::GetHeight());
    const vec2  center = vec2(w * 0.5f, h * 0.5f);
    const float unit   = (w / h < stdRatio) ? w / 320.0f : h / 180.0f;
    const vec2  scale  = vec2(unit, -unit);
    const vec2  size   = vec2(unit * 12.04f);
    const vec2  offset = vec2(size.x * 0.825f, -size.y * 0.5f);
    const vec2  coords = center + offset + scale * MedalStack.AbsolutePosition_V3;

    nvg::BeginPath();
    nvg::FillPaint(nvg::TexturePattern(coords, size, 0.0f, iconWarriorNvg, 1.0f));
    nvg::Fill();
}

void _DrawSoloCampaign(CGameManialinkPage@ Page) {
    auto Camp = cast<CGameManialinkFrame>(Page.GetFirstChild("frame-campaign"));
    if (Camp is null) {
        return;
    }

    auto Label = cast<CGameManialinkLabel>(Camp.GetFirstChild("Trackmania_Button_label-value"));
    if (Label is null) {
        return;
    }

    string[]@ parts = string(Label.Value).Split("|");
    if (parts.Length == 0) {
        return;
    }

    Campaign@ campaign = GetCampaign(CampaignUid(parts[parts.Length - 1].Replace("\u0091", " ")));
    if (false
        or campaign is null
        or (true
            and campaign.countWarrior < 25
            and !S_UIMedalsAlwaysMenu
        )
    ) {
        return;
    }

    _DrawSoloMedal(cast<CGameManialinkFrame>(Camp.GetFirstChild("frame-medal-stack-quarterly")));
}

void _DrawSoloTotd(CGameManialinkPage@ Page) {
    if (latestTotd is null) {
        return;
    }

    auto Totd = cast<CGameManialinkFrame>(Page.GetFirstChild("frame-totd"));
    if (Totd is null) {
        return;
    }

    auto Date = cast<CGameManialinkLabel>(Totd.GetFirstChild("label-totd-date"));
    if (Date is null) {
        return;
    }

    // UI::Text("date: " + string(Date.Value));
    // UI::Text("latest: " + latestTotd.date);

    // doesn't match latest totd after midnight - the tile says the current day even if totd for today isn't available yet :yek:
    try {
        if (
            Text::ParseUInt(string(Date.Value).Split(" ")[1].Split(",")[0])
            != Text::ParseUInt(latestTotd.date.Split("-")[2])
        ) {
            return;
        }
    } catch {
        return;
    }

    if (true
        and !latestTotd.hasWarrior
        and !S_UIMedalsAlwaysMenu
    ) {
        return;
    }

    _DrawSoloMedal(cast<CGameManialinkFrame>(Totd.GetFirstChild("frame-medal-stack-totd")));
}

void DrawOverSoloPage(CGameManialinkPage@ Page) {
    if (Page is null) {
        return;
    }

    _DrawSoloCampaign(Page);
    _DrawSoloTotd(Page);
}

void DrawOverTotdPage(CGameManialinkPage@ Page) {
    if (Page is null) {
        return;
    }

    auto Maps = cast<CGameManialinkFrame>(Page.GetFirstChild("frame-maps"));
    if (Maps is null) {
        return;
    }

    string monthName;
    auto MonthLabel = cast<CGameManialinkLabel>(Page.GetFirstChild("label-title"));
    if (MonthLabel !is null) {
        monthName = string(MonthLabel.Value).SubStr(12).Replace("%1\u0091", "");
    }

    int8[] indicesToShow;
    Campaign@ campaign = GetCampaign(CampaignUid(monthName));
    if (campaign !is null) {
        for (uint i = 0; i < campaign.mapsArr.Length; i++) {
            WarriorMedals::Map@ map = campaign.mapsArr[i];
            if (map is null) {
                continue;
            }

            if (false
                or map.hasWarrior
                or S_UIMedalsAlwaysMenu
            ) {
                indicesToShow.InsertLast(map.index);
            }
        }
    }

    const float w      = Math::Max(1, Draw::GetWidth());
    const float h      = Math::Max(1, Draw::GetHeight());
    const vec2  center = vec2(w * 0.5f, h * 0.5f);
    const float unit   = (w / h < stdRatio) ? w / 320.0f : h / 180.0f;
    const vec2  scale  = vec2(unit, -unit);
    const vec2  size   = vec2(unit * 9.15f);
    const vec2  offset = vec2(-118.2f, 1.2f);

    uint indexOffset = 0;
    for (uint i = 0; i < Maps.Controls.Length; i++) {
        if (indexOffset > 6) {
            break;
        }

        if (indicesToShow.Length == 0) {
            break;
        }

        auto Map = cast<CGameManialinkFrame>(Maps.Controls[i]);
        if (false
            or Map is null
            or !Map.Visible
        ) {
            indexOffset++;
            continue;
        }

        if (indicesToShow.Find(i - indexOffset) == -1) {  // needs to be here dumbass :)
            continue;
        }

        auto MedalStack = cast<CGameManialinkFrame>(Map.GetFirstChild("frame-medalstack"));
        if (false
            or MedalStack is null
            or !MedalStack.Visible
        ) {
            continue;
        }

        const vec2 colOffset = vec2(29.1f, 0.0f) * (i % 7);
        const vec2 rowOffset = vec2(-2.02f, -11.5f) * (i / 7);
        const vec2 coords    = center + scale * (offset + colOffset + rowOffset);

        nvg::BeginPath();
        nvg::FillPaint(nvg::TexturePattern(coords, size, 0.0f, iconWarriorNvg, 1.0f));
        nvg::Fill();
    }
}
