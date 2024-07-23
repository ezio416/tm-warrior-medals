// c 2024-07-22
// m 2024-07-23

class Campaign {
    uint                        colorIndex = uint(-1);
    uint                        index      = uint(-1);
    dictionary@                 maps       = dictionary();
    WarriorMedals::Map@[]       mapsArr;
    uint                        month;
    string                      name;
    string                      nameLower;
    WarriorMedals::CampaignType type       = WarriorMedals::CampaignType::Unknown;
    uint                        year;

    Campaign(const string &in name) {
        this.name = name;
        nameLower = name.ToLower();
    }

    void AddMap(WarriorMedals::Map@ map) {
        if (map is null || maps.Exists(map.uid))
            return;

        maps[map.uid] = @map;
        mapsArr.InsertLast(@map);

        if (type == WarriorMedals::CampaignType::Unknown)
            type = map.campaignType;

        if (index != uint(-1))
            return;

        year = Text::ParseUInt(map.campaign.SubStr(map.campaign.Length - 4)) - 2020;

        if (type == WarriorMedals::CampaignType::Seasonal) {
            if (map.campaign.StartsWith("Summer")) {
                index = 0 + 4 * year;
                colorIndex = 2;
            } else if (map.campaign.StartsWith("Fall")) {
                index = 1 + 4 * year;
                colorIndex  =3;
            } else if (map.campaign.StartsWith("Winter")) {
                index = 2 + 4 * (year - 1);
                colorIndex = 0;
            } else {
                index = 3 + 4 * (year - 1);
                colorIndex = 1;
            }
        } else if (type == WarriorMedals::CampaignType::TrackOfTheDay) {
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
        } else
            SetOtherCampaignIndex();
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

    void SetOtherCampaignIndex() {
        if (campaignIndices !is null && campaignIndices.HasKey(nameLower))
            index = uint(campaignIndices[nameLower]);
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

        Campaign@ campaign = GetCampaign(map.campaign.ToLower());
        if (campaign !is null) {
            campaign.AddMap(map);
            continue;
        }

        @campaign = Campaign(map.campaign);
        campaign.AddMap(map);
        campaigns[campaign.nameLower] = @campaign;
        campaignsArr.InsertLast(@campaign);
    }

    SortCampaigns();

    trace("building campaigns done");
}

Campaign@ GetCampaign(const string &in name) {
    if (!campaigns.Exists(name))
        return null;

    return cast<Campaign@>(campaigns[name]);
}

void SortCampaigns() {
    for (uint i = 0; i < campaignsArr.Length; i++) {
        Campaign@ campaign = campaignsArr[i];
        if (campaign is null || campaign.mapsArr.Length < 2)
            continue;

        campaign.mapsArr.Sort(function(a, b) { return a.index < b.index; });
    }

    if (campaignsArr.Length < 2)
        return;

    campaignsArr.Sort(function(a, b) { return a.index > b.index; });
}
