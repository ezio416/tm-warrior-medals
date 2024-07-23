// c 2024-07-22
// m 2024-07-23

const vec3 colorFall   = vec3(1.0f, 0.5f, 0.0f);
const vec3 colorSpring = vec3(0.3f, 0.9f, 0.3f);
const vec3 colorSummer = vec3(1.0f, 0.8f, 0.0f);
const vec3 colorWinter = vec3(0.0f, 0.8f, 1.0f);

class Campaign {
    vec3                        color;
    uint                        index = uint(-1);
    dictionary@                 maps  = dictionary();
    WarriorMedals::Map@[]       mapsArr;
    string                      name;
    string                      nameLower;
    WarriorMedals::CampaignType type  = WarriorMedals::CampaignType::Unknown;

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

        const uint year = Text::ParseUInt(map.campaign.SubStr(map.campaign.Length - 4)) - 2020;

        if (type == WarriorMedals::CampaignType::Seasonal) {
            if (map.campaign.StartsWith("Summer")) {
                index = 0 + 4 * year;
                color = colorSummer;
            } else if (map.campaign.StartsWith("Fall")) {
                index = 1 + 4 * year;
                color = colorFall;
            } else if (map.campaign.StartsWith("Winter")) {
                index = 2 + 4 * (year - 1);
                color = colorWinter;
            } else {
                index = 3 + 4 * (year - 1);
                color = colorSpring;
            }
        } else if (type == WarriorMedals::CampaignType::TrackOfTheDay) {
            const uint month = Text::ParseUInt(map.date.SubStr(5, 2));
            index = ((month + 5) % 12) + 12 * (year - (month < 7 ? 1 : 0));
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
