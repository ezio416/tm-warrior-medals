// c 2024-07-18
// m 2024-10-23

namespace API {
    const string baseUrl = "https://e416.dev/api";
    bool         getting = false;
    dictionary@  missing = dictionary();

    Net::HttpRequest@ GetAsync(const string &in url, bool start = true) {
        getting = true;

        if (start) {
            Net::HttpRequest@ req = Net::HttpGet(url);

            while (!req.Finished())
                yield();

            getting = false;
            return req;
        }

        Net::HttpRequest@ req = Net::HttpRequest();
        req.Method = Net::HttpMethod::Get;
        req.Url = url;

        getting = false;
        return req;
    }

    Net::HttpRequest@ GetEdevAsync(const string &in endpoint, bool start = true) {
        while (getting)
            yield();

        return GetAsync(baseUrl + endpoint, start);
    }

    void CheckVersionAsync() {
        Net::HttpRequest@ req = GetEdevAsync("/tm/warrior/plugin-version");

        if (req.ResponseCode() == 426) {
            const string msg = "Please update through the Plugin Manager at the top. Your plugin version will soon be unsupported!";
            warn(msg);
            UI::ShowNotification(title, msg, vec4(colorVec * 0.5f, 1.0f), 10000);
        }
    }

    void GetAllMapInfosAsync() {
        startnew(TryGetCampaignIndicesAsync);

        const uint64 start = Time::Now;
        trace("getting all map infos");

        Net::HttpRequest@ req = GetEdevAsync("/tm/warrior/all");

        const int respCode = req.ResponseCode();
        if (respCode != 200) {
            error("getting all map infos failed after " + (Time::Now - start) + "ms: code: " + respCode + " | msg: " + req.String().Replace("\n", " "));
            return;
        }

        Json::Value@ data = req.Json();
        if (!WarriorMedals::CheckJsonType(data, Json::Type::Object, "data")) {
            error("getting all map infos failed after " + (Time::Now - start) + "ms");
            return;
        }

        yield();

        string[]@ uids = data.GetKeys();
        for (uint i = 0; i < uids.Length; i++) {
            const string uid = uids[i];

            WarriorMedals::Map@ map = WarriorMedals::Map(data[uid]);
            maps[uid] = @map;
        }

        trace("got all map infos after " + (Time::Now - start) + "ms");

        GetAllPBsAsync();
        Files::LoadPBs();
        BuildCampaigns();
        Files::SavePBs();
    }

    bool GetCampaignIndicesAsync() {
        const uint64 start = Time::Now;
        trace("getting campaign indices");

        Net::HttpRequest@ req = GetEdevAsync("/tm/warrior/campaign-indices");

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

        if (missing.Exists(uid)) {
            if (Time::Stamp < int64(missing[uid]))
                return;

            missing.Delete(uid);
        }

        if (maps.Exists(uid))
            return;

        const uint64 start = Time::Now;
        trace("getting map info for " + uid);

        Net::HttpRequest@ req = GetEdevAsync("/tm/warrior?uid=" + uid);

        const int respCode = req.ResponseCode();
        switch (respCode) {
            case 200:
                break;
            case 429:
                error("getting map info for " + uid + " failed after " + (Time::Now - start) + "ms: too many requests");
                return;
            default:
                error("getting map info for " + uid + " failed after " + (Time::Now - start) + "ms: code: " + respCode + " | msg: " + req.String().Replace("\n", " "));
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

    namespace Nadeo {
        string       allCampaignsProgress;
        const string audienceCore = "NadeoServices";
        const string audienceLive = "NadeoLiveServices";
        bool         cancel       = false;
        uint64       lastRequest  = 0;
        const uint64 minimumWait  = 1000;
        bool         requesting   = false;

        string get_urlCore() { return NadeoServices::BaseURLCore(); }
        string get_urlLive() { return NadeoServices::BaseURLLive(); }
        string get_urlMeet() { return NadeoServices::BaseURLMeet(); }

        void GetAllCampaignPBsAsync() {
            const uint64 start = Time::Now;
            trace("getting PBs on all campaigns...");

            allCampaignsProgress = "Getting PBs...\n0 / " + campaignsArr.Length + "\n0 %";

            for (uint i = 0; i < campaignsArr.Length; i++) {
                Campaign@ campaign = campaignsArr[i];

                campaign.GetPBsAsync();

                allCampaignsProgress = "Getting PBs...\n" + (i + 1) + " / " + campaignsArr.Length
                    + "\n" + Text::Format("%.1f", float(i + 1) * 100.0f / campaignsArr.Length) + "%"
                    + "\n" + Time::Format((campaignsArr.Length - (i + 1)) * 1100) + " left";

                if (cancel) {
                    trace("got some PBs (cancelled) after " + (Time::Now - start) + "ms");
                    cancel = false;
                    return;
                }
            }

            trace("got all PBs after " + (Time::Now - start) + "ms");
        }

        Net::HttpRequest@ GetAsync(const string &in audience, const string &in url, bool start = true) {
            NadeoServices::AddAudience(audience);

            while (!NadeoServices::IsAuthenticated(audience) || requesting)
                yield();

            if (start)
                requesting = true;

            WaitAsync();

            Net::HttpRequest@ req = NadeoServices::Get(audience, url);
            if (start) {
                req.Start();
                while (!req.Finished())
                    yield();

                requesting = false;
            }

            return req;
        }

        Net::HttpRequest@ GetCoreAsync(const string &in endpoint, bool start = true) {
            return GetAsync(audienceCore, urlCore + endpoint, start);
        }

        Net::HttpRequest@ GetLiveAsync(const string &in endpoint, bool start = true) {
            return GetAsync(audienceLive, urlLive + endpoint, start);
        }

        Net::HttpRequest@ GetMeetAsync(const string &in endpoint, bool start = true) {
            return GetAsync(audienceLive, urlMeet + endpoint, start);
        }

        Net::HttpRequest@ PostAsync(const string &in audience, const string &in url, const string &in body = "", bool start = true) {
            NadeoServices::AddAudience(audience);

            while (!NadeoServices::IsAuthenticated(audience) || requesting)
                yield();

            if (start)
                requesting = true;

            WaitAsync();

            Net::HttpRequest@ req = NadeoServices::Post(audience, url, body);
            if (start) {
                req.Start();
                while (!req.Finished())
                    yield();

                requesting = false;
            }

            return req;
        }

        Net::HttpRequest@ PostAsync(const string &in audience, const string &in url, Json::Value@ body = null, bool start = true) {
            return PostAsync(audience, url, Json::Write(body), start);
        }

        Net::HttpRequest@ PostCoreAsync(const string &in endpoint, const string &in body = "", bool start = true) {
            return PostAsync(audienceCore, urlCore + endpoint, body, start);
        }

        Net::HttpRequest@ PostCoreAsync(const string &in endpoint, Json::Value@ body = null, bool start = true) {
            return PostAsync(audienceCore, urlCore + endpoint, body, start);
        }

        Net::HttpRequest@ PostLiveAsync(const string &in endpoint, const string &in body = "", bool start = true) {
            return PostAsync(audienceLive, urlLive + endpoint, body, start);
        }

        Net::HttpRequest@ PostLiveAsync(const string &in endpoint, Json::Value@ body = null, bool start = true) {
            return PostAsync(audienceLive, urlLive + endpoint, body, start);
        }

        Net::HttpRequest@ PostMeetAsync(const string &in endpoint, const string &in body = "", bool start = true) {
            return PostAsync(audienceLive, urlMeet + endpoint, body, start);
        }

        Net::HttpRequest@ PostMeetAsync(const string &in endpoint, Json::Value@ body = null, bool start = true) {
            return PostAsync(audienceLive, urlMeet + endpoint, body, start);
        }

        void WaitAsync() {
            uint64 now;

            while ((now = Time::Now) - lastRequest < minimumWait)
                yield();

            lastRequest = now;
        }
    }
}
