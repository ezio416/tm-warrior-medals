// c 2024-07-18
// m 2024-07-18

const string apiUrl = "https://e416.dev/api/tm/warrior";

void GetAllWarriorTimesAsync() {
    trace("getting all warrior times");

    Net::HttpRequest@ req = Net::HttpGet(apiUrl);
    while (!req.Finished())
        yield();

    const int respCode = req.ResponseCode();
    switch (respCode) {
        case 200:
            break;
        case 429:
            error("GetAllWarriorTimesAsync: too many requests");
            return;
        default:
            error("GetAllWarriorTimesAsync: code: " + respCode + " | msg: " + req.String().Replace("\n", ""));
            return;
    }

    Json::Value@ all = req.Json();
    if (CheckJsonType(all, Json::Type::Object, "all")) {
        maps.DeleteAll();

        string[]@ uids = all.GetKeys();
        for (uint i = 0; i < uids.Length; i++) {
            const string uid = uids[i];

            Map@ map = Map(all[uid]);
            maps[uid] = @map;
        }
    }

    trace("got all warrior times");
}

void GetCurrentWarriorTimeAsync() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App.RootMap is null)
        return;

    const string uid = App.RootMap.EdChallengeId;

    trace("getting warrior time for " + uid);

    Net::HttpRequest@ req = Net::HttpGet(apiUrl + "?uid=" + uid);
    while (!req.Finished())
        yield();

    const int respCode = req.ResponseCode();
    switch (respCode) {
        case 200:
            break;
        case 429:
            error("GetCurrentWarriorTimeAsync: too many requests");
            return;
        default:
            error("GetCurrentWarriorTimeAsync: code: " + respCode + " | msg: " + req.String().Replace("\n", ""));
            return;
    }

    Json::Value@ single = req.Json();
    if (CheckJsonType(single, Json::Type::Object, "single") && single.GetKeys().Length > 0) {
        Map@ map = Map(single);
        maps[uid] = @map;

        trace("got warrior time for " + uid);
    } else
        warn("warrior time not found for " + uid);
}
