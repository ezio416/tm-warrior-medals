// c 2024-07-22
// m 2024-07-22

dictionary@ campaigns = dictionary();

class Campaign {
    dictionary@           maps = dictionary();
    WarriorMedals::Map@[] mapsArr;
    string                name;

    Campaign() { }
    Campaign(const string &in name) {
        this.name = name;
    }

    void AddMap(WarriorMedals::Map@ map) {
        if (map is null)
            return;

        maps[map.uid] = @map;
        mapsArr.InsertLast(@map);
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
