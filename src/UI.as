// c 2024-07-22
// m 2024-07-22

bool addedThing = false;
bool nodExplored = false;

void DrawOverUI() {
    if (!S_DrawOverUI)
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

        if (Layer.ManialinkPageUtf8.Trim().SubStr(17, 20) == "Page_CampaignDisplay") {
            CGameManialinkPage@ Page = Layer.LocalPage;
            if (Page is null || Page.ControlsCache.Length == 0)
                return;

            CGameManialinkFrame@ Global = cast<CGameManialinkFrame@>(Page.GetFirstChild("frame-global"));
            if (Global is null)
                return;

            CGameManialinkFrame@ Campaign = cast<CGameManialinkFrame@>(Global.GetFirstChild("frame-campaign"));
            if (Campaign is null)
                return;

            CGameManialinkFrame@ Maps = cast<CGameManialinkFrame@>(Campaign.GetFirstChild("frame-maps"));
            if (Maps is null)
                return;

            if (!nodExplored) {
                ExploreNod("frame-maps", Maps);
                nodExplored = true;
            }

            for (uint j = 0; j < Maps.Controls.Length; j++) {
                CGameManialinkFrame@ Map = cast<CGameManialinkFrame@>(Maps.Controls[j]);
                if (Map is null)
                    continue;

                // CGameManialinkQuad@ MedalStack = cast<CGameManialinkQuad@>(Map.GetFirstChild("frame-medalstack"));
                // if (MedalStack is null)
                //     continue;

                // CControlFrame@ StackControl = cast<CControlFrame@>(MedalStack.Control);
                // if (StackControl is null)
                //     continue;

                // if (!addedThing) {
                //     print("adding thing");

                //     StackControl.AddLabel(
                //         "label-id-" + i + j,
                //         Map.AbsolutePosition,
                //         "hello",
                //         CControlStyle()
                //     );

                //     addedThing = true;
                // }

                // nvg::BeginPath();
                // nvg::FillColor(vec4(colorVec, 1.0f));
                // // nvg::Circle(Map.AbsolutePosition_V3, 20.0f);
                // nvg::Circle(RegularCampaignMedalCoords(j), 10.0f);
                // nvg::Fill();
            }
        }
    }
}

// vec2 MenuCoordsToScreenSpace(vec2 coords) {
//     float w = Draw::GetWidth();
//     float h = Draw::GetHeight();

//     float unit = (w / h < 16.0f / 9.0f) ? w / 320.0f : h / 180.0f;

//     return vec2(Draw::GetWidth() * 0.5f, Draw::GetHeight() * 0.5f) + coords * vec2(unit, -unit);
// }

// vec2 RegularCampaignMedalCoords(uint index) {
//     uint row = index % 5;
//     uint column = index / 5;

//     return MenuCoordsToScreenSpace(
//         topLeft + (row * dx) + (column * dy) + vec2(2.2f, -7.8f)
//     );
// }

// const vec2 topLeft = vec2(-126.2056f, 0.25f);
// const vec2 dx      = vec2(-2.0277f,   -11.5f);
// const vec2 dy      = vec2(36.0f,      0.0f);
