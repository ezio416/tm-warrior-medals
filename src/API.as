namespace API {
    const string baseUrl          = "https://e416.dev/api3";
    string       checkingUid;
    dictionary   missing;
    int64        nadeoAllPbsWait  = 604800;  // 1 week
    bool         requesting       = false;
    bool         shouldGetIndices = true;
    bool         shouldPing       = true;
    bool         shouldUseOldPbs  = false;

[Setting hidden] bool   banned      = false;
[Setting hidden] int64  savedExpiry = 0;
[Setting hidden] string savedToken;

    enum ResponseCode {
        Unknown         = 0,
        OK              = 200,
        NoContent       = 204,
        BadRequest      = 400,
        Unauthorized    = 401,
        Forbidden       = 403,
        UpgradeRequired = 426,
        TooManyRequests = 429,
        InternalServer  = 500
    }

    string EdevAgent() {
        string executing;
        Meta::Plugin@ pluginExec = Meta::ExecutingPlugin();
        if (pluginExec !is pluginMeta) {
            executing = " (" + pluginExec.ID + " " + pluginExec.Version + ")";
        }

        CSystemPlatformScript@ SysPlat = GetApp().SystemPlatform;
        return "Openplanet / Net::HttpRequest / " + pluginMeta.ID + " " + pluginMeta.Version + executing
            + " / " + SysPlat.ExtraTool_Info.Replace("Openplanet ", "") + " / " + SysPlat.ExeVersion;
    }

    Net::HttpRequest@ GetAsync(const string&in url, const bool start = true, const string&in agent = "", const string&in auth = "") {
        requesting = true;

        Net::HttpRequest@ req = Net::HttpRequest();
        req.Method = Net::HttpMethod::Get;
        req.Url = url;
        if (agent.Length > 0) {
            req.Headers["User-Agent"] = agent;
        }
        if (auth.Length > 0) {
            req.Headers["Authorization"] = "Bearer " + auth;
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

        return GetAsync(baseUrl + endpoint, start, EdevAgent(), token.token);
    }

    void GetAllMapInfosAsync() {
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

        string[]@ types = data.GetKeys();
        for (uint i = 0; i < types.Length; i++) {
            Json::Value@ section = data.Get(types[i]);

            if (types[i] == "indices") {
                if (WarriorMedals::CheckJsonType(section, Json::Type::Object, "indices")) {
                    @campaignIndices = section;
                }

            } else if (types[i] == "next") {
                if (WarriorMedals::CheckJsonType(section, Json::Type::Number, "next")) {
                    nextWarriorRequest = int64(section);
                    trace("next request: " + Time::FormatString("%F %T", nextWarriorRequest));
                }

            } else {
                if (!WarriorMedals::CheckJsonType(section, Json::Type::Array, "section-" + i)) {
                    error("getting all map infos failed after " + (Time::Now - start) + "ms");
                    return;
                }

                for (uint j = 0; j < section.Length; j++) {
                    auto map = WarriorMedals::Map(section[j], types[i]);
                    if (maps.Exists(map.uid)) {
                        auto existing = cast<WarriorMedals::Map>(maps[map.uid]);
                        existing.SetDuplicate(map);
                    } else {
                        maps[map.uid] = @map;
                        mapsById[map.id] = @map;
                    }
                }
            }

            yield();
        }

        trace("got all map infos after " + (Time::Now - start) + "ms");

        ReadPBs();

        if (false
            or pbsById.GetType() == Json::Type::Null
            or Nadeo::lastPbRequest == -1
            or Time::Stamp - Nadeo::lastPbRequest > nadeoAllPbsWait
        ) {
            Nadeo::GetAllPbsNewAsync();
        }

        if (shouldGetIndices) {
            GetCampaignIndicesAsync();
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

    void GetMessagesAsync() {
        while (false
            or token.token.Length == 0
            or requesting
        ) {
            yield();
        }

        Net::HttpRequest@ req = GetEdevAsync("/tm/warrior/message");

        const ResponseCode code = ResponseCode(req.ResponseCode());
        switch (code) {
            case ResponseCode::OK:
                messages = {};
                try {
                    Json::Value@ json = req.Json();
                    unhiddenMessages = json.Length;
                    unreadMessages = json.Length;

                    for (uint i = 0; i < json.Length; i++) {
                        auto message = Message(json[i]);

                        if (hiddenMessages.Find(message.id) > -1) {
                            message.hidden = true;
                            unhiddenMessages--;
                        }

                        if (readMessages.Find(message.id) > -1) {
                            message.read = true;
                            unreadMessages--;
                        }

                        messages.InsertLast(@message);
                    }

                    if (messages.Length > 1) {
                        messages.Sort(function(a, b) { return a.id > b.id; });
                    }

                    for (int i = messages.Length - 1; i >= 0; i--) {
                        if (true
                            and messages[i].notice
                            and messages[i].unread
                        ) {
                            messages[i].Notify();
                        }
                    }

                } catch {
                    error("error parsing messages: " + getExceptionInfo());
                }

                break;

            default:
                error("error getting messages (" + tostring(code) + "): " + req.String());
        }
    }

    void GetTokenAsync() {
        if (token.getting) {
            return;
        }
        token.getting = true;

        if (token.valid) {
            trace("using existing token...");

            Net::HttpRequest@ req = GetEdevAsync("/tm/warrior/auth");

            const ResponseCode code = ResponseCode(req.ResponseCode());
            switch (code) {
                case ResponseCode::OK:
                    token.getting = false;
                    try {
                        Json::Value@ json = req.Json();
                        token.expiry = int64(json["expiry"]);

                        if (bool(json["outdated"])) {
                            WarnOutdated();
                        }

                        ParseConfigs(json["config"]);

                        trace("existing token valid :)");
                        return;

                    } catch { }

                default:
                    token.Clear();
                    trace("existing token invalid (" + tostring(code) + ")");
            }
        }

        trace("getting token 1...");

        Auth::PluginAuthTask@ tokenTask = Auth::GetToken();
        while (!tokenTask.Finished()) {
            yield();
        }

        if (!tokenTask.IsSuccess()) {
            error("error getting token 1: " + tokenTask.Error());
            token.getting = false;
            return;
        }

        token.token = tokenTask.Token();

        trace("got token 1, getting token 2...");

        const uint64 start = Time::Now;
        Net::HttpRequest@ req = PostEdevAsync("/tm/warrior/auth", "", false);
        req.Start();
        while (!req.Finished()) {
            yield();

            if (Time::Now - start > 10000) {
                error("error getting token 2: timed out");
                req.Cancel();
                requesting = false;
                token.getting = false;
                return;
            }
        }

        requesting = false;

        const ResponseCode code = ResponseCode(req.ResponseCode());
        switch (code) {
            case ResponseCode::OK:
                banned = false;
                break;

            case ResponseCode::Forbidden:
                error("You've been denied access to the plugin. If you believe this is an error, contact Ezio on Discord.");
                token.getting = false;
                banned = true;
                return;

            default:
                error(
                    "error getting token 2: " + tostring(code)
                    + " | " + req.String().Replace("\n", "\\n")
                );
                token.getting = false;
                banned = false;
                return;
        }

        try {
            Json::Value@ json = req.Json();
            token.token = string(json["token"]);
            token.expiry = int64(json["expiry"]);

            if (bool(json["outdated"])) {
                WarnOutdated();
            }

            ParseConfigs(json["config"]);

            if (token.valid) {
                trace("got token 2");
            } else {
                error("error getting token 2: unknown");
                token.Clear();
            }

        } catch {
            error("error parsing token 2: " + getExceptionInfo());
            token.Clear();
        }

        token.getting = false;
        startnew(CoroutineFunc(token.WatchAsync));
    }

    void ParseConfigs(Json::Value@ config) {
        if (config.GetType() == Json::Type::Object) {
            uint count = 0;

            if (config.HasKey("nadeoAllPbsWait")) {
                nadeoAllPbsWait = int64(config["nadeoAllPbsWait"]);
                count++;
            }

            if (config.HasKey("shouldGetIndices")) {
                shouldGetIndices = bool(config["shouldGetIndices"]);
                count++;
            }

            if (config.HasKey("shouldPing")) {
                shouldPing = bool(config["shouldPing"]);
                count++;
            }

            if (config.HasKey("shouldUseOldPbs")) {
                shouldUseOldPbs = bool(config["shouldUseOldPbs"]);
                count++;
            }

            trace("configs: " + count);
        }
    }

    void PingAsync() {
        if (true
            and !banned
            and shouldPing
        ) {
            const auto code = ResponseCode(GetEdevAsync("/tm/warrior/ping").ResponseCode());
            switch (code) {
                case ResponseCode::OK:
                    break;

                default:
                    warn("can't reach edev | " + tostring(code));
            }
        }
    }

    Net::HttpRequest@ PostAsync(const string&in url, const string&in body = "", const bool start = true, const string&in agent = "", const string&in auth = "") {
        requesting = true;

        Net::HttpRequest@ req = Net::HttpRequest();
        req.Method = Net::HttpMethod::Post;
        req.Url = url;
        req.Body = body;
        req.Headers["Content-Type"] = "application/json";
        if (agent.Length > 0) {
            req.Headers["User-Agent"] = agent;
        }
        if (auth.Length > 0) {
            req.Headers["Authorization"] = "Bearer " + auth;
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

        return PostAsync(baseUrl + endpoint, body, start, EdevAgent(), token.token);
    }

    void SendMessageAsync(Message@ message) {
        if (message is null) {
            warn("null message");
            return;
        }

        if (message.big) {
            warn("shorten your subject or message");
            return;
        }

        while (false
            or token.token.Length == 0
            or requesting
        ) {
            yield();
        }

        Net::HttpRequest@ req = PostEdevAsync("/tm/warrior/message", tostring(message.GetMap()));

        const ResponseCode code = ResponseCode(req.ResponseCode());
        switch (code) {
            case ResponseCode::OK:
            case ResponseCode::NoContent:
                trace("sent message: " + newSubject + " | " + newMessage);
                UI::ShowNotification(pluginTitle + " - sent message", newSubject + " | " + newMessage);
                newMessage = "";
                newSubject = "";
                break;

            default:
                error("failed to send message (" + tostring(code) + "): " + req.String());
                warn(req.String());
                UI::ShowNotification(pluginTitle, "Something went wrong, check the log!", vec4(1.0f, 0.3f, 0.0f, 0.8f));
        }
    }

    void SendMessageAsync(ref@ m) {
        SendMessageAsync(cast<Message>(m));
    }

    namespace Nadeo {
        bool         allPbsNew    = false;
        const string audienceCore = "NadeoServices";
        const string audienceLive = "NadeoLiveServices";
        uint64       lastRequest  = 0;
        const uint64 minimumWait  = 1000;
        bool         requesting   = false;

[Setting hidden] int64 lastPbRequest = -1;

        void GetAllPbsNewAsync() {
            allPbsNew = true;
            const uint64 start = Time::Now;
            trace("getting all PBs...");

            if (shouldUseOldPbs) {
                warn("using old PB system");

                for (uint i = 0; i < campaignsArr.Length; i++) {
                    campaignsArr[i].GetPBsAsync();
                }

                try {
                    Json::ToFile(IO::FromStorageFolder("pbs2.json"), pbsById, true);
                } catch {
                    error("error writing all PBs to file: " + getExceptionInfo());
                }

                trace("got all PBs (" + pbsById.Length + ") after " + (Time::Now - start) + "ms");

                allPbsNew = false;
                lastPbRequest = Time::Stamp;

                return;
            }

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

            @pbsById = Json::Value();
            pbsById = pbs;

            for (uint i = 0; i < campaignsArr.Length; i++) {
                if (true
                    and campaignsArr[i].type == WarriorMedals::CampaignType::Grand
                    and campaignsArr[i].mapsArr.Length > 0
                ) {
                    campaignsArr[i].GetPBsAsync();
                }
            }

            try {
                Json::ToFile(IO::FromStorageFolder("pbs2.json"), pbsById, true);
            } catch {
                error("error writing all PBs to file: " + getExceptionInfo());
            }

            trace("got all PBs (" + pbs.Length + ") after " + (Time::Now - start) + "ms");

            allPbsNew = false;
            lastPbRequest = Time::Stamp;
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
            const uint64 now = Time::Now;
            if (now - lastRequest < minimumWait) {
                sleep(lastRequest + minimumWait - now);
            }
            lastRequest = Time::Now;
        }
    }
}
