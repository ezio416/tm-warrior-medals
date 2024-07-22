// c 2024-07-22
// m 2024-07-22

void DrawOverUI() {
    if (false
        || icon is null
        || !S_MedalsInUI
        || (true
            && !S_MedalsSeasonalCampaign
            && !S_MedalsClubCampaign
            // && !S_MedalsTotd
            && !S_MedalsTraining
        )
    )
        return;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    NGameLoadProgress_SMgr@ LoadProgress = App.LoadProgress;
    if (LoadProgress !is null && LoadProgress.State != NGameLoadProgress::EState::Disabled)
        return;

    CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);
    CTrackManiaNetworkServerInfo@ ServerInfo = cast<CTrackManiaNetworkServerInfo@>(Network.ServerInfo);
    if (ServerInfo.CurGameModeStr.Length > 0)
        return;

    if (InMap()) {
        CGameManiaAppPlayground@ CMAP = Network.ClientManiaAppPlayground;
        if (CMAP is null || CMAP.UILayers.Length == 0)
            return;

        ;

        return;
    }

    CTrackManiaMenus@ Menus = cast<CTrackManiaMenus@>(App.MenuManager);
    if (Menus is null)
        return;

    CGameManiaAppTitle@ Title = Menus.MenuCustom_CurrentManiaApp;
    if (Title is null || Title.UILayers.Length == 0)
        return;

    CGameManialinkPage@ Campaign;
    CGameManialinkPage@ Training;

    for (uint i = 0; i < Title.UILayers.Length; i++) {
        if (true
            && Campaign !is null
            && Training !is null
        )
            break;

        CGameUILayer@ Layer = Title.UILayers[i];
        if (false
            || Layer is null
            || !Layer.IsVisible
            || Layer.Type != CGameUILayer::EUILayerType::Normal
        )
            continue;

        const string pageName = Layer.ManialinkPageUtf8.Trim();

        if ((S_MedalsSeasonalCampaign || S_MedalsClubCampaign) && pageName.SubStr(17, 20) == "Page_CampaignDisplay") {
            @Campaign = Layer.LocalPage;
            continue;
        }

        if (S_MedalsTraining && pageName.SubStr(17, 20) == "Page_TrainingDisplay") {
            @Training = Layer.LocalPage;
            continue;
        }
    }

    DrawOverCampaignPage(Campaign);
    DrawOverTrainingPage(Training);
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

    DrawCampaign(cast<CGameManialinkFrame@>(Page.GetFirstChild("frame-maps")), club);
}

void DrawOverTrainingPage(CGameManialinkPage@ Page) {
    if (Page is null)
        return;

    DrawCampaign(cast<CGameManialinkFrame@>(Page.GetFirstChild("frame-maps")), true);
}

void DrawCampaign(CGameManialinkFrame@ Maps, bool club = false) {
    if (Maps is null)
        return;

    for (uint i = 0; i < Maps.Controls.Length; i++) {
        CGameManialinkFrame@ Map = cast<CGameManialinkFrame@>(Maps.Controls[i]);
        if (Map is null)
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
        nvg::FillPaint(nvg::TexturePattern(coords, vec2(116.0f), 0.0f, icon, 1.0f));
        nvg::Fill();
    }
}
