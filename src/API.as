// c 2024-07-18
// m 2024-09-23

const string apiUrl  = "https://e416.dev/api";
bool         getting = false;
dictionary@  missing = dictionary();

void CheckVersionAsync() {
    Net::HttpRequest@ req = Net::HttpGet(apiUrl + "/tm/warrior/plugin-version");
    while (!req.Finished())
        yield();

    if (req.ResponseCode() == 426) {
        const string msg = "Please update through the Plugin Manager at the top. Your plugin version will soon be unsupported!";
        warn(msg);
        UI::ShowNotification(title, msg, vec4(colorVec * 0.5f, 1.0f), 10000);
    }
}

void GetAllMapInfosAsync() {
    startnew(TryGetCampaignIndicesAsync);

    getting = true;

    const uint64 start = Time::Now;
    trace("getting all map infos");

    Net::HttpRequest@ req = Net::HttpGet(apiUrl + "/tm/warrior/all");
    while (!req.Finished())
        yield();

    const int respCode = req.ResponseCode();
    if (respCode != 200) {
        error("getting all map infos failed after " + (Time::Now - start) + "ms: code: " + respCode + " | msg: " + req.String().Replace("\n", " "));
        getting = false;
        return;
    }

    Json::Value@ data = req.Json();
    if (!WarriorMedals::CheckJsonType(data, Json::Type::Object, "data")) {
        error("getting all map infos failed after " + (Time::Now - start) + "ms");
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

    trace("getting all map infos done after " + (Time::Now - start) + "ms");
    getting = false;

    GetAllPBsAsync();
    BuildCampaigns();
}

bool GetCampaignIndicesAsync() {
    const uint64 start = Time::Now;
    trace("getting campaign indices");

    Net::HttpRequest@ req = Net::HttpGet(apiUrl + "/tm/warrior/campaign-indices");
    while (!req.Finished())
        yield();

    const int respCode = req.ResponseCode();
    if (respCode != 200) {
        error("getting campaign indices failed after " + (Time::Now - start) + "ms: code: " + respCode + " | msg: " + req.String().Replace("\n", " "));
        return false;
    }

    @campaignIndices = req.Json();

    if (!WarriorMedals::CheckJsonType(campaignIndices, Json::Type::Object, "campaignIndices", false)) {
        error("getting campaign indices failed after " + (Time::Now - start) + "ms");
        return false;
    }

    trace("getting campaign indices done after " + (Time::Now - start) + "ms");
    return true;
}

void GetMapInfoAsync() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App.RootMap is null || !App.RootMap.MapType.Contains("TM_Race"))
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

    const uint64 start = Time::Now;
    trace("getting map info for " + uid);

    Net::HttpRequest@ req = Net::HttpGet(apiUrl + "/tm/warrior?uid=" + uid);
    while (!req.Finished())
        yield();

    const int respCode = req.ResponseCode();
    switch (respCode) {
        case 200:
            break;
        case 429:
            error("getting map info for " + uid + " failed after " + (Time::Now - start) + "ms: too many requests");
            getting = false;
            return;
        default:
            error("getting map info for " + uid + " failed after " + (Time::Now - start) + "ms: code: " + respCode + " | msg: " + req.String().Replace("\n", " "));
            getting = false;
            return;
    }

    Json::Value@ mapInfo = req.Json();
    if (WarriorMedals::CheckJsonType(mapInfo, Json::Type::Object, "mapInfo") && mapInfo.GetKeys().Length > 0) {
        WarriorMedals::Map@ map = WarriorMedals::Map(mapInfo);
        map.GetPB();
        maps[uid] = @map;

        trace("getting map info for " + uid + " done after " + (Time::Now - start) + "ms");
    } else {
        warn("map info not found for " + uid + " after " + (Time::Now - start) + "ms");
        missing[uid] = Time::Stamp + 600;  // wait 10 minutes to check map again
    }

    getting = false;
}

void TryGetCampaignIndicesAsync() {
    while (true) {
        if (GetCampaignIndicesAsync())
            break;

        sleep(5000);
    }

    for (uint i = 0; i < campaignsArr.Length; i++) {
        Campaign@ campaign = campaignsArr[i];
        if (campaign is null || campaign.type != WarriorMedals::CampaignType::Other)
            continue;

        campaign.SetOtherCampaignIndex();
    }

    SortCampaigns();
}
