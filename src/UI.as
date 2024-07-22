// c 2024-07-22
// m 2024-07-22

void DrawOverUI() {
    if (false
        || icon is null
        || !S_MedalsInUI
        || (true
            && !S_MedalsSeasonalCampaign
            && !S_MedalsTotd
        )
    )
        return;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CTrackManiaMenus@ Menus = cast<CTrackManiaMenus@>(App.MenuManager);
    if (Menus is null)
        return;

    CGameManiaAppTitle@ Title = Menus.MenuCustom_CurrentManiaApp;
    if (Title is null || Title.UILayers.Length == 0)
        return;

    for (uint i = 0; i < Title.UILayers.Length; i++) {
        CGameUILayer@ Layer = Title.UILayers[i];
        if (Layer is null)
            continue;

        if (S_MedalsSeasonalCampaign && Layer.ManialinkPageUtf8.Trim().SubStr(17, 20) == "Page_CampaignDisplay")
            DrawOverSeasonalCampaign(Layer.LocalPage);
    }
}

void DrawOverSeasonalCampaign(CGameManialinkPage@ Page) {
    if (Page is null)
        return;

    CGameManialinkFrame@ Maps = cast<CGameManialinkFrame@>(Page.GetFirstChild("frame-maps"));
    if (Maps is null)
        return;

    for (uint j = 0; j < Maps.Controls.Length; j++) {
        CGameManialinkFrame@ Map = cast<CGameManialinkFrame@>(Maps.Controls[j]);
        if (Map is null)
            continue;

        CGameManialinkFrame@ MedalStack = cast<CGameManialinkFrame@>(Map.GetFirstChild("frame-medalstack"));
        if (MedalStack is null || !MedalStack.Visible)
            continue;

        const float w = Draw::GetWidth();
        const float h = Draw::GetHeight();
        const float unit = (w / h < 16.0f / 9.0f) ? w / 320.0f : h / 180.0f;
        const vec2 coords = vec2(w * 0.5f, h * 0.5f)
            + vec2(unit, -unit) * (
                vec2(-99.8f, 1.05f)
                + ((j % 5) * vec2(-2.02f, -11.5f))
                + ((j / 5) * vec2(36.0f, 0.0f))
            )
        ;

        nvg::BeginPath();
        nvg::FillPaint(nvg::TexturePattern(coords, vec2(116.0f), 0.0f, icon, 1.0f));
        nvg::Fill();
    }
}
