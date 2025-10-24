// c 2024-07-18
// m 2025-10-23

namespace API {
    const string baseUrl    = "https://e416.dev/api2";
    string       checkingUid;
    dictionary   missing;
    bool         requesting = false;

    enum ResponseCode {
        OK              = 200,
        NoContent       = 204,
        Forbidden       = 403,
        UpgradeRequired = 426,
        TooManyRequests = 429
    }

    string EdevAgent() {
        string executing;
        Meta::Plugin@ pluginExec = Meta::ExecutingPlugin();
        if (pluginExec !is pluginMeta) {
            executing = " (" + pluginExec.ID + " " + pluginExec.Version + ")";
        }

        CSystemPlatformScript@ SysPlat = GetApp().SystemPlatform;
        return reqAgentStart + executing + " / " + SysPlat.ExtraTool_Info.Replace("Openplanet ", "") + " / " + SysPlat.ExeVersion;
    }

    Net::HttpRequest@ GetAsync(const string&in url, const bool start = true, const string&in agent = "") {
        requesting = true;

        Net::HttpRequest@ req = Net::HttpRequest();
        req.Method = Net::HttpMethod::Get;
        req.Url = url;
        if (agent.Length > 0) {
            req.Headers["User-Agent"] = agent;
        }

        if (start) {
            req.Start();
            while (!req.Finished()) {
                yield();
            }
        }

        requesting = false;
        return req;
    }

    Net::HttpRequest@ GetEdevAsync(const string&in endpoint, const bool start = true) {
        while (requesting) {
            yield();
        }

        return GetAsync(baseUrl + endpoint, start, EdevAgent());
    }

    void CheckVersionAsync() {
        Net::HttpRequest@ req = GetEdevAsync("/tm/warrior/plugin-version");

        const int code = req.ResponseCode();
        switch (code) {
            case ResponseCode::OK:
            case ResponseCode::NoContent:
                break;

            case ResponseCode::Forbidden:
                warn("You've been denied access to the plugin. If you believe this is an error, contact Ezio on Discord.");
                break;

            case ResponseCode::UpgradeRequired: {
                const string msg = "Please update through the Plugin Manager at the top. Your plugin version will soon be unsupported!";
                warn(msg);
                UI::ShowNotification(pluginTitle, msg, vec4(colorWarriorVec * 0.5f, 1.0f), 10000);
                break;
            }

            default:
                warn("something went wrong checking the plugin version: " + code + " " + req.String());
        }
    }

    void GetAllMapInfosAsync(bool pbs) {
        startnew(TryGetCampaignIndicesAsync);

        const uint64 start = Time::Now;
        trace("getting all map infos");

        Net::HttpRequest@ req = GetEdevAsync("/tm/warrior/all");

        const int respCode = req.ResponseCode();
        if (respCode != ResponseCode::OK) {
            error("getting all map infos failed after " + (Time::Now - start) + "ms: code: " + respCode + " | msg: " + req.String().Replace("\n", " "));
            return;
        }

        Json::Value@ data = req.Json();
        if (!WarriorMedals::CheckJsonType(data, Json::Type::Object, "data")) {
            error("getting all map infos failed after " + (Time::Now - start) + "ms");
            return;
        }

        yield();

        bool gotNext = false;

        string[]@ types = data.GetKeys();
        for (uint i = 0; i < types.Length; i++) {
            Json::Value@ section = data.Get(types[i]);

            if (types[i] == "next") {  // future proofing, plan to change backend later
                if (WarriorMedals::CheckJsonType(section, Json::Type::Number, "next")) {
                    nextWarriorRequest = int64(section);
                    trace("next request: " + Time::FormatString("%F %T", nextWarriorRequest));
                    gotNext = true;
                }
            } else {
                if (!WarriorMedals::CheckJsonType(section, Json::Type::Array, "section-" + i)) {
                    error("getting all map infos failed after " + (Time::Now - start) + "ms");
                    return;
                }

                for (uint j = 0; j < section.Length; j++) {
                    auto map = WarriorMedals::Map(section[j], types[i]);
                    maps[map.uid] = @map;
                    mapsById[map.id] = @map;
                }
            }

            yield();
        }

        if (!gotNext) {
            trace("didn't find next request time, getting now...");

            try {
                nextWarriorRequest = int64(GetEdevAsync("/tm/warrior/next").Json()[0]);
                trace("next request: " + Time::FormatString("%F %T", nextWarriorRequest));
            } catch {
                error("getting next request time failed");
            }
        }

        trace("got all map infos after " + (Time::Now - start) + "ms");

        if (pbs) {
            Nadeo::GetAllPbsNewAsync();
        }
        BuildCampaigns();
    }

    bool GetCampaignIndicesAsync() {
        const uint64 start = Time::Now;
        trace("getting campaign indices");

        Net::HttpRequest@ req = GetEdevAsync("/tm/warrior/campaign-indices");

        const int respCode = req.ResponseCode();
        if (respCode != ResponseCode::OK) {
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
        auto App = cast<CTrackMania>(GetApp());

        if (false
            or App.RootMap is null
            or !App.RootMap.MapType.Contains("TM_Race")
        ) {
            return;
        }

        GetMapInfoAsync(App.RootMap.EdChallengeId);
    }

    void GetMapInfoAsync(const string&in uid) {
        if (false
            or uid.Length == 0
            or uid == checkingUid
            or maps.Exists(uid)
        ) {
            return;
        }

        if (missing.Exists(uid)) {
            if (Time::Stamp < int64(missing[uid])) {
                return;
            }

            missing.Delete(uid);
        }

        const uint64 start = Time::Now;
        trace("getting map info for " + uid);
        checkingUid = uid;

        Net::HttpRequest@ req = GetEdevAsync("/tm/warrior?uid=" + uid);

        const int respCode = req.ResponseCode();
        switch (respCode) {
            case ResponseCode::OK:
                break;

            case ResponseCode::Forbidden:
                warn("You've been denied access to the plugin. If you believe this is an error, contact Ezio on Discord.");
                return;

            case ResponseCode::TooManyRequests:
                error("getting map info for " + uid + " failed after " + (Time::Now - start) + "ms: too many requests");
                checkingUid = "";
                return;

            default:
                error("getting map info for " + uid + " failed after " + (Time::Now - start) + "ms: code: " + respCode + " | msg: " + req.String().Replace("\n", " "));
                checkingUid = "";
                return;
        }

        Json::Value@ mapInfo = req.Json();
        if (true
            and WarriorMedals::CheckJsonType(mapInfo, Json::Type::Object, "mapInfo")
            and mapInfo.GetKeys().Length > 0
        ) {
            auto map = WarriorMedals::Map(mapInfo);
            map.GetPB();
            maps[uid] = @map;

            trace("getting map info for " + uid + " done after " + (Time::Now - start) + "ms");
        } else {
            warn("map info not found for " + uid + " after " + (Time::Now - start) + "ms");
            missing[uid] = Time::Stamp + 600;  // wait 10 minutes to check map again
        }

        checkingUid = "";
    }

    Net::HttpRequest@ PostAsync(const string&in url, const string&in body = "", const bool start = true, const string&in agent = "") {
        requesting = true;

        Net::HttpRequest@ req = Net::HttpRequest();
        req.Method = Net::HttpMethod::Post;
        req.Url = url;
        req.Body = body;
        req.Headers["Content-Type"] = "application/json";
        if (agent.Length > 0) {
            req.Headers["User-Agent"] = agent;
        }

        if (start) {
            req.Start();
            while (!req.Finished()) {
                yield();
            }
        }

        requesting = false;
        return req;
    }

    Net::HttpRequest@ PostEdevAsync(const string&in endpoint, const string&in body = "", const bool start = true) {
        while (requesting) {
            yield();
        }

        return PostAsync(baseUrl + endpoint, body, start, EdevAgent());
    }

    bool SendFeedbackAsync(const string&in subject, const string&in message, const bool anonymous = false) {
        if (false
            or subject.Length > 1000
            or message.Length > 10000
        ) {
            warn("shorten your subject or message.");
            return false;
        }

        Json::Value@ body = Json::Object();
        body["subject"] = subject;
        body["message"] = message;

        if (InMap()) {
            body["mapUid"] = GetApp().RootMap.EdChallengeId;
        }

        auto App = cast<CTrackMania>(GetApp());
        if (true
            and !anonymous
            and App.LocalPlayerInfo !is null
        ) {
            body["accountId"] = App.LocalPlayerInfo.WebServicesUserId;
        }

        Net::HttpRequest@ req = PostEdevAsync("/tm/warrior/feedback", Json::Write(body));

        const int code = req.ResponseCode();
        switch (code) {
            case ResponseCode::OK:
            case ResponseCode::NoContent:
                print(Icons::InfoCircle + " sent: " + req.Body);
                return true;

            case ResponseCode::Forbidden:
                warn("You've been denied access to the plugin. If you believe this is an error, contact Ezio on Discord.");
                return false;

            case ResponseCode::TooManyRequests: {
                const string msg = "You've sent enough feedback for today.";
                warn(msg);
                UI::ShowNotification(pluginTitle, msg, vec4(1.0f, 0.6f, 0.0f, 0.8f));
                feedbackLocked = true;
                return false;
            }

            default:
                warn(Icons::ExclamationTriangle + " failed (" + code + "), can't send: " + Json::Write(body));
                warn(req.String());
                UI::ShowNotification(pluginTitle, "Something went wrong, check the log!", vec4(1.0f, 0.3f, 0.0f, 0.8f));
                return false;
        }
    }

    void TryGetCampaignIndicesAsync() {
        while (true) {
            if (GetCampaignIndicesAsync()) {
                break;
            }

            sleep(5000);
        }

        for (uint i = 0; i < campaignsArr.Length; i++) {
            Campaign@ campaign = campaignsArr[i];
            if (false
                or campaign is null
                or campaign.type != WarriorMedals::CampaignType::Other
            ) {
                continue;
            }

            campaign.SetOtherCampaignIndex();
        }

        SortCampaigns();
    }

    namespace Nadeo {
        string       allCampaignsProgress;
        bool         allPbsNew    = false;
        bool         allWeekly    = false;
        const string audienceCore = "NadeoServices";
        const string audienceLive = "NadeoLiveServices";
        bool         cancel       = false;
        uint64       lastRequest  = 0;
        const uint64 minimumWait  = 1000;
        bool         requesting   = false;

        void GetAllPbsNewAsync() {
            allPbsNew = true;
            const uint64 start = Time::Now;
            trace("getting all PBs...");

            uint offset = 0;
            Json::Value@ pbs = Json::Object();
            Net::HttpRequest@ req;

            while (true) {
                trace("getting PBs with offset " + offset);

                @req = GetCoreAsync("/v2/accounts/" + GetApp().LocalPlayerInfo.WebServicesUserId + "/mapRecords/?offset=" + offset);

                const int respCode = req.ResponseCode();
                if (respCode != ResponseCode::OK) {
                    error("getting all PBs (offset " + offset + ") failed after " + (Time::Now - start) + "ms: code: " + respCode + " | msg: " + req.String().Replace("\n", " "));
                    continue;
                }

                Json::Value@ data = req.Json();
                if (!WarriorMedals::CheckJsonType(data, Json::Type::Array, "data")) {
                    error("getting all PBs (offset " + offset + ") failed after " + (Time::Now - start) + "ms");
                    continue;
                }

                if (data.Length == 0) {
                    break;
                }

                string mapId;
                for (uint i = 0; i < data.Length; i++) {
                    if (i % 1000 == 0) {
                        yield();
                    }

                    try {
                        mapId = string(data[i]["mapId"]);
                        Json::Value@ time = data[i]["recordScore"]["time"];

                        pbs[mapId] = time;
                        try {
                            cast<WarriorMedals::Map>(mapsById[mapId]).pb = uint(time);
                        } catch { }

                    } catch {
                        error("error on map " + i + " of offset " + offset + ": " + getExceptionInfo() + " | " + Json::Write(data[i]));
                    }
                }

                offset += 1000;
            }

            try {
                Json::ToFile(IO::FromStorageFolder("pbs2.json"), pbs, true);
            } catch {
                error("error writing all PBs to file: " + getExceptionInfo());
            }

            trace("got all PBs (" + pbs.Length + ") after " + (Time::Now - start) + "ms");

            allPbsNew = false;
        }

        Net::HttpRequest@ GetAsync(const string&in audience, const string&in url, const bool start = true) {
            NadeoServices::AddAudience(audience);

            while (false
                or !NadeoServices::IsAuthenticated(audience)
                or requesting
            ) {
                yield();
            }

            if (start) {
                requesting = true;
            }

            WaitAsync();

            Net::HttpRequest@ req = NadeoServices::Get(audience, url);
            if (start) {
                req.Start();
                while (!req.Finished()) {
                    yield();
                }

                requesting = false;
            }

            return req;
        }

        Net::HttpRequest@ GetCoreAsync(const string&in endpoint, const bool start = true) {
            return GetAsync(audienceCore, NadeoServices::BaseURLCore() + endpoint, start);
        }

        Net::HttpRequest@ PostAsync(const string&in audience, const string&in url, const string&in body = "", const bool start = true) {
            NadeoServices::AddAudience(audience);

            while (false
                or !NadeoServices::IsAuthenticated(audience)
                or requesting
            ) {
                yield();
            }

            if (start) {
                requesting = true;
            }

            WaitAsync();

            Net::HttpRequest@ req = NadeoServices::Post(audience, url, body);
            if (start) {
                req.Start();
                while (!req.Finished()) {
                    yield();
                }

                requesting = false;
            }

            return req;
        }

        Net::HttpRequest@ PostLiveAsync(const string&in endpoint, const string&in body = "", const bool start = true) {
            return PostAsync(audienceLive, NadeoServices::BaseURLLive() + endpoint, body, start);
        }

        void WaitAsync() {
            uint64 now;

            while ((now = Time::Now) - lastRequest < minimumWait) {
                yield();
            }

            lastRequest = now;
        }
    }
}
