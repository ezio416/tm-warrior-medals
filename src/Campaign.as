class Campaign {
    int                         clubId     = -1;
    string                      clubName;
    string                      clubNameFormatted;
    string                      clubNameStripped;
    uint8                       colorIndex = uint8(-1);
    int                         id         = -1;
    int                         index      = -1;
    dictionary                  maps;
    WarriorMedals::Map@[]       mapsArr;
    uint                        month;
    string                      name;
    string                      nameFormatted;
    string                      nameStripped;
    bool                        requesting = false;
    WarriorMedals::CampaignType type       = WarriorMedals::CampaignType::Unknown;
    string                      uid;
    uint                        week;
    uint                        year;

    uint get_countWarrior() {
        uint count = 0;

        for (uint i = 0; i < mapsArr.Length; i++) {
            WarriorMedals::Map@ map = mapsArr[i];
            if (true
                and map !is null
                and map.hasWarrior
            ) {
                count++;
            }
        }

        return count;
    }

    bool get_official() {
        return false
            or clubId == 0
            or clubId == 150
        ;  // 0 training/seasonal, 150 ubisoft nadeo
    }

    Campaign(WarriorMedals::Map@ map) {
        clubId            = map.clubId;
        clubName          = map.clubName;
        clubNameFormatted = WarriorMedals::OpenplanetFormatCodes(clubName);
        clubNameStripped  = WarriorMedals::StripFormatCodes(clubName);
        id                = map.campaignId;
        name              = map.campaignName;
        nameFormatted     = WarriorMedals::OpenplanetFormatCodes(name);
        nameStripped      = WarriorMedals::StripFormatCodes(name);
        uid               = CampaignUid(name, clubName);
    }

    void AddMap(WarriorMedals::Map@ map) {
        if (false
            or map is null
            or maps.Exists(map.uid)
        ) {
            return;
        }

        maps[map.uid] = @map;
        mapsArr.InsertLast(@map);

        if (type == WarriorMedals::CampaignType::Unknown) {
            type = map.campaignType;
        }

        if (index != -1) {
            return;
        }

        year = Text::ParseUInt(map.campaignName.SubStr(map.campaignName.Length - 4)) - 2020;

        switch (type) {
            case WarriorMedals::CampaignType::Seasonal:
                if (map.campaignName.StartsWith("Summer")) {
                    index = 0 + 4 * year;
                    colorIndex = 2;
                } else if (map.campaignName.StartsWith("Fall")) {
                    index = 1 + 4 * year;
                    colorIndex = 3;
                } else if (map.campaignName.StartsWith("Winter")) {
                    index = 2 + 4 * (year - 1);
                    colorIndex = 0;
                } else {
                    index = 3 + 4 * (year - 1);
                    colorIndex = 1;
                }

                break;

            case WarriorMedals::CampaignType::Weekly:
                index = map.number - 1;
                week = map.week;
                year = 4 + ((week + 48) / 52);  // breaks at week 212 (end of 2028)
                break;

            case WarriorMedals::CampaignType::TrackOfTheDay: {
                month = Text::ParseUInt(map.date.SubStr(5, 2));

                index = ((month + 5) % 12) + 12 * (year - (month < 7 ? 1 : 0));

                switch (month) {
                    case 1: case 2: case 3:
                        colorIndex = 0;
                        break;
                    case 4: case 5: case 6:
                        colorIndex = 1;
                        break;
                    case 7: case 8: case 9:
                        colorIndex = 2;
                        break;
                    default:
                        colorIndex = 3;
                }

                break;
            }

            default:
                SetOtherCampaignIndex();
        }
    }

    WarriorMedals::Map@ GetMap(const string&in uid) {
        if (!maps.Exists(uid)) {
            return null;
        }

        return cast<WarriorMedals::Map>(maps[uid]);
    }

    void GetPBsAsync() {
        while (requesting) {
            yield();
        }

        requesting = true;

        const uint64 start = Time::Now;
        trace("getting PBs for " + nameStripped);

        Json::Value@ body = Json::Object();
        body["maps"] = Json::Array();

        for (uint i = 0; i < mapsArr.Length; ++i) {
            Json::Value@ map = Json::Object();
            map["groupUid"] = "Personal_Best";
            map["mapUid"] = mapsArr[i].uid;
            body["maps"].Add(map);
        }

        Net::HttpRequest@ req = API::Nadeo::PostLiveAsync("/api/token/leaderboard/group/map", Json::Write(body));
        // warn("setting clipboard");
        // IO::SetClipboard(req.String());

        const int respCode = req.ResponseCode();
        if (respCode != 200) {
            error("getting PBs for " + nameStripped + " failed after " + (Time::Now - start) + "ms: code: " + respCode + " | msg: " + req.String().Replace("\n", " "));
            return;
        }

        Json::Value@ data = req.Json();
        if (!WarriorMedals::CheckJsonType(data, Json::Type::Array, "data")) {
            error("getting PBs for " + nameStripped + " failed after " + (Time::Now - start) + "ms");
            return;
        }

        string uid;

        for (uint i = 0; i < data.Length; i++) {
            Json::Value@ map_api = data[i];
            if (!WarriorMedals::CheckJsonType(map_api, Json::Type::Object, "map_api")) {
                continue;
            }

            uid = JsonExt::GetString(map_api, "mapUid");

            WarriorMedals::Map@ map = GetMap(uid);
            if (map !is null) {
                map.SetPBFromAPI(map_api);
                if (int(map.pb) > 0) {
                    pbsById[map.id] = map.pb;
                }
            }
        }

        requesting = false;

        trace("got PBs for " + nameStripped + " after " + (Time::Now - start) + "ms");

        SetTotals();
    }

    void SetOtherCampaignIndex() {
        const string indexId = tostring(clubId) + "-" + id;

        if (true
            and campaignIndices !is null
            and campaignIndices.HasKey(indexId)
        ) {
            index = int(campaignIndices[indexId]);
        }
    }
}

void BuildCampaigns() {
    const uint64 start = Time::Now;
    trace("building campaigns");

    campaigns.DeleteAll();
    campaignsArr = {};

    const string[]@ uids = maps.GetKeys();

    for (uint i = 0; i < uids.Length; i++) {
        auto map = cast<WarriorMedals::Map>(maps[uids[i]]);
        if (map is null) {
            continue;
        }

        WarriorMedals::Map@ duplicate = map.duplicate;
        if (duplicate !is null) {
            // warn("adding duplicate to campaign: " + duplicate.nameStripped);

            Campaign@ campaign = GetCampaign(CampaignUid(duplicate.campaignName, duplicate.clubName));
            if (campaign !is null) {
                campaign.AddMap(duplicate);
            } else {
                @campaign = Campaign(duplicate);
                campaign.AddMap(duplicate);
                campaigns[campaign.uid] = @campaign;
                campaignsArr.InsertLast(@campaign);
            }
        }

        Campaign@ campaign = GetCampaign(CampaignUid(map.campaignName, map.clubName));
        if (campaign !is null) {
            campaign.AddMap(map);
            continue;
        }

        @campaign = Campaign(map);
        campaign.AddMap(map);
        campaigns[campaign.uid] = @campaign;
        campaignsArr.InsertLast(@campaign);
    }

    trace("building campaigns done after " + (Time::Now - start) + "ms");

    SortCampaigns();
}

string CampaignUid(const string&in name, const string&in club = "") {
    const string ret = club + uidSeparator + name;
    return ret.ToLower();
}

Campaign@ GetCampaign(const string&in uid) {
    if (!campaigns.Exists(uid))
        return null;

    return cast<Campaign>(campaigns[uid]);
}

void SortCampaigns() {
    const uint64 start = Time::Now;
    trace("sorting campaigns and maps");

    for (uint i = 0; i < campaignsArr.Length; i++) {
        Campaign@ campaign = campaignsArr[i];
        if (false
            or campaign is null
            or campaign.mapsArr.Length < 2
        ) {
            continue;
        }

        campaign.mapsArr.Sort(function(a, b) { return a.index < b.index; });
    }

    switch (campaignsArr.Length) {
        case 0:
            return;
        case 1:
            break;
        default:
            campaignsArr.Sort(function(a, b) { return a.index > b.index; });
    }

    uint latestTotdCampaignIndex = uint(-1);

    for (uint i = 0; i < campaignsArr.Length; i++) {
        Campaign@ campaign = campaignsArr[i];
        if (false
            or campaign is null
            or campaign.type != WarriorMedals::CampaignType::TrackOfTheDay
            or campaign.mapsArr.Length == 0
        ) {
            continue;
        }

        if (campaign.mapsArr.Length > 1) {
            @previousTotd = campaign.mapsArr[campaign.mapsArr.Length - 2];
        }

        @latestTotd = campaign.mapsArr[campaign.mapsArr.Length - 1];
        latestTotdCampaignIndex = i;
        break;
    }

    if (true
        and previousTotd is null  // latest must be first of the month
        and latestTotdCampaignIndex != uint(-1)
        and latestTotdCampaignIndex > 0
    ) {
        for (uint i = latestTotdCampaignIndex + 1; i < campaignsArr.Length; i++) {
            Campaign@ campaign = campaignsArr[i];
            if (false
                or campaign is null
                or campaign.type != WarriorMedals::CampaignType::TrackOfTheDay
                or campaign.mapsArr.Length == 0
            ) {
                continue;
            }

            @previousTotd = campaign.mapsArr[campaign.mapsArr.Length - 1];
            break;
        }
    }

    if (previousTotd is null) {
        warn("couldn't find a previous TOTD");
    }

    if (latestTotd is null) {
        warn("couldn't find a recent TOTD");
    }

    campaignsArrRev = campaignsArr;
    campaignsArrRev.Reverse();

    trace("sorting campaigns and maps done after " + (Time::Now - start) + "ms");

    activeOtherCampaigns    = {};
    activeSeasonalCampaigns = {};
    activeTotdMonths        = {};
    activeWeeklyWeeks       = {};

    SetTotals();
}
