// c 2024-07-18
// m 2024-07-19

const string apiUrl  = "https://e416.dev/api/tm/warrior";
bool         getting = false;

void GetMapInfoAsync() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App.RootMap is null)
        return;

    GetMapInfoAsync(App.RootMap.EdChallengeId);
}

void GetMapInfoAsync(const string &in uid) {
    if (maps.Exists(uid))
        return;

    while (getting)
        yield();

    if (maps.Exists(uid))  // safeguard in case multiple things call this at once
        return;

    getting = true;

    trace("getting map info for " + uid);

    Net::HttpRequest@ req = Net::HttpGet(apiUrl + "?uid=" + uid);
    while (!req.Finished())
        yield();

    const int respCode = req.ResponseCode();
    switch (respCode) {
        case 200:
            break;
        case 429:
            error("GetMapInfoAsync: too many requests");
            getting = false;
            return;
        default:
            error("GetMapInfoAsync: code: " + respCode + " | msg: " + req.String().Replace("\n", " "));
            getting = false;
            return;
    }

    Json::Value@ mapInfo = req.Json();
    if (CheckJsonType(mapInfo, Json::Type::Object, "mapInfo") && mapInfo.GetKeys().Length > 0) {
        Map@ map = Map(mapInfo);
        maps[uid] = @map;

        trace("got map info for " + uid);
    } else
        warn("map info not found for " + uid);

    getting = false;
}
