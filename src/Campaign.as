// c 2024-07-22
// m 2024-07-23

enum CampaignType {
    Seasonal,
    TrackOfTheDay,
    Other,
    Unknown
}

class Campaign {
    dictionary@           maps = dictionary();
    WarriorMedals::Map@[] mapsArr;
    string                name;
    CampaignType          type = CampaignType::Unknown;

    Campaign() { }
    Campaign(const string &in name) {
        this.name = name;
    }

    void AddMap(WarriorMedals::Map@ map) {
        if (map is null || maps.Exists(map.uid))
            return;

        maps[map.uid] = @map;
        mapsArr.InsertLast(@map);

        if (map.campaign.Length > 0)
            type = CampaignType::Other;
        else if (map.date.Length > 0)
            type = CampaignType::TrackOfTheDay;
        else
            type = CampaignType::Seasonal;
    }

    WarriorMedals::Map@ GetMap(const string &in uid) {
        if (!maps.Exists(uid))
            return null;

        return cast<WarriorMedals::Map@>(maps[uid]);
    }

    void GetPBs() {
        const string[]@ uids = maps.GetKeys();

        for (uint i = 0; i < uids.Length; i++) {
            WarriorMedals::Map@ map = cast<WarriorMedals::Map@>(maps[uids[i]]);
            if (map is null)
                continue;

            map.GetPB();
        }
    }
}

void BuildCampaigns() {
    trace("building campaigns");

    campaigns.DeleteAll();

    const string[]@ uids = maps.GetKeys();

    for (uint i = 0; i < uids.Length; i++) {
        WarriorMedals::Map@ map = cast<WarriorMedals::Map@>(maps[uids[i]]);
        if (map is null)
            continue;

        Campaign@ campaign = GetCampaign(map.campaign);
        if (campaign !is null) {
            campaign.AddMap(map);
            continue;
        }

        @campaign = Campaign(map.campaign);
        campaign.AddMap(map);
        campaigns[map.campaign] = @campaign;
    }

    trace("building campaigns done");
}

Campaign@ GetCampaign(const string &in name) {
    if (!campaigns.Exists(name))
        return null;

    return cast<Campaign@>(campaigns[name]);
}
