// c 2024-07-18
// m 2024-07-21

const string e416devApiUrl = "https://e416.dev/api";
bool         getting       = false;
const string githubUrl     = "https://raw.githubusercontent.com/ezio416/warrior-medal-times/main/warriors.json";
dictionary@  missing       = dictionary();

void GetAllMapInfosAsync() {
    getting = true;

    Net::HttpRequest@ req = Net::HttpGet(githubUrl);
    while (!req.Finished())
        yield();

    const int respCode = req.ResponseCode();
    if (respCode != 200) {
        error("GetAllMapInfosAsync: code: " + respCode + " | msg: " + req.String().Replace("\n", " "));
        getting = false;
        return;
    }

    Json::Value@ data = req.Json();
    if (!WarriorMedals::CheckJsonType(data, Json::Type::Object, "data")) {
        getting = false;
        return;
    }

    yield();

    string[]@ uids = data.GetKeys();
    for (uint i = 0; i < uids.Length; i++) {
        const string uid = uids[i];

        WarriorMedals::Map@ map = WarriorMedals::Map(data[uid]);
        maps[uid] = @map;
    }

    getting = false;
}

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

    if (missing.Exists(uid)) {
        if (Time::Stamp < int64(missing[uid]))
            return;

        missing.Delete(uid);
    }

    if (maps.Exists(uid))
        return;

    getting = true;

    trace("getting map info for " + uid);

    Net::HttpRequest@ req = Net::HttpGet(e416devApiUrl + "/tm/warrior?uid=" + uid);
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
    if (WarriorMedals::CheckJsonType(mapInfo, Json::Type::Object, "mapInfo") && mapInfo.GetKeys().Length > 0) {
        WarriorMedals::Map@ map = WarriorMedals::Map(mapInfo);
        maps[uid] = @map;

        trace("got map info for " + uid);
    } else {
        warn("map info not found for " + uid);
        missing[uid] = Time::Stamp + 600;  // wait 10 minutes to check map again
    }

    getting = false;
}
