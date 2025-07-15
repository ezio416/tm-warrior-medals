// c 2024-07-21
// m 2025-07-15

/*
Exports from the Warrior Medals plugin.
*/
namespace WarriorMedals {
    /*
    Enum describing the type a campaign is or the type of campaign a map is a part of.
    */
    shared enum CampaignType {
        Seasonal,
        Weekly,
        TrackOfTheDay,
        Other,
        Unknown
    }

    /*
    Simple function for checking if a given Json::Value@ is of the correct type.
    Only shared to make the compiler happy.
    */
    shared bool CheckJsonType(Json::Value@ value, const Json::Type desired, const string&in name, const bool warning = true) {
        if (value is null) {
            if (warning) {
                warn(name + " is null");
            }
            return false;
        }

        const Json::Type type = value.GetType();
        if (type != desired) {
            if (warning) {
                warn(name + " is a(n) " + tostring(type) + ", not a(n) " + tostring(desired));
            }
            return false;
        }

        return true;
    }

    /*
    Simple function to get a month's name from its number.
    Only shared to make the compiler happy.
    */
    shared string MonthName(const uint num) {
        switch (num) {
            case 1:  return "January";
            case 2:  return "February";
            case 3:  return "March";
            case 4:  return "April";
            case 5:  return "May";
            case 6:  return "June";
            case 7:  return "July";
            case 8:  return "August";
            case 9:  return "September";
            case 10: return "October";
            case 11: return "November";
            default: return "December";
        }
    }

    /*
    Simple function to format a string for Openplanet's format codes and trim the string.
    Only shared to make the compiler happy.
    */
    shared string OpenplanetFormatCodes(const string&in s) {
        return Text::OpenplanetFormatCodes(s).Trim();
    }

    /*
    Simple function to strip a string of format codes and trim the string.
    Only shared to make the compiler happy.
    */
    shared string StripFormatCodes(const string&in s) {
        return Text::StripFormatCodes(s).Trim();
    }

    /*
    Data container for a map with a Warrior medal.
    */
    shared class Map {
        private bool gettingPB  = false;
        private bool gettingUrl = false;

        private uint _pb = uint(-1);
        uint get_pb() { return _pb; }
        void set_pb(const uint p) { _pb = p; }

        private uint _author;
        uint get_author() { return _author; }
        private void set_author(const uint a) { _author = a; }

        private int _campaignId = -1;
        int get_campaignId() { return _campaignId; }
        private void set_campaignId(const int c) { _campaignId = c; }

        private string _campaignName;
        string get_campaignName() { return _campaignName; }
        private void set_campaignName(const string&in c) { _campaignName = c; }

        private CampaignType _campaignType;
        CampaignType get_campaignType() { return _campaignType; }
        private void set_campaignType(const CampaignType c) { _campaignType = c; }

        private int _clubId = -1;
        int get_clubId() { return _clubId; }
        private void set_clubId(const int c) { _clubId = c; }

        private string _clubName;
        string get_clubName() { return _clubName; }
        private void set_clubName(const string&in c) { _clubName = c; }

        private uint _custom = 0;
        uint get_custom() { return _custom; }
        private void set_custom(const uint c) { _custom = c; }

        private string _date;
        string get_date() { return _date; }
        private void set_date(const string&in d) { _date = d; }

        private string _downloadUrl;
        string get_downloadUrl() { return _downloadUrl; }
        private void set_downloadUrl(const string&in d) { _downloadUrl = d; }

        bool get_hasWarrior() {
            return true
                and pb != uint(-1)
                and pb <= (custom > 0 ? custom : warrior)
            ;
        }

        private string _id;
        string get_id() { return _id; }
        private void set_id(const string&in i) { _id = i; }

        // private uint8 _index = uint8(-1);
        // uint8 get_index() { return _index; }
        // private void set_index(uint8 i) { _index = i; }
        int8 index = -1;

        private bool _loading = false;
        bool get_loading() { return _loading; }
        private void set_loading(const bool l) { _loading = l; }

        private string _name;
        string get_name() { return _name; }
        private void set_name(const string&in n) { _name = n; }

        private string _nameFormatted;
        string get_nameFormatted() { return _nameFormatted; }
        private void set_nameFormatted(const string&in n) { _nameFormatted = n; }

        private string _nameStripped;
        string get_nameStripped() { return _nameStripped; }
        private void set_nameStripped(const string&in n) { _nameStripped = n; }

        private int _number = -1;  // weekly only
        int get_number() { return _number; }
        private void set_number(const int n) { _number = n; }

        private string _reason;
        string get_reason() { return _reason; }
        private void set_reason(const string&in r) { _reason = r; }

        private string _uid;
        string get_uid() { return _uid; }
        private void set_uid(const string&in u) { _uid = u; }

        private uint _warrior;
        uint get_warrior() { return _warrior; }
        private void set_warrior(const uint w) { _warrior = w; }

        private int _week = -1;  // weekly only
        int get_week() { return _week; }
        private void set_week(const int w) { _week = w; }

        private uint _worldRecord;
        uint get_worldRecord() { return _worldRecord; }
        private void set_worldRecord(const uint w) { _worldRecord = w; }

        Map() { }
        Map(Json::Value@ map) {  // single map
            author        = uint(map["authorTime"]);
            id            = string(map["mapId"]);
            name          = string(map["name"]).Trim();
            nameFormatted = OpenplanetFormatCodes(name);
            nameStripped  = StripFormatCodes(name);
            uid           = string(map["mapUid"]);
            warrior       = uint(map["warriorTime"]);
            worldRecord   = uint(map["worldRecord"]);

            campaignType = CampaignType::Seasonal;

            if (map.HasKey("campaignId")) {
                Json::Value@ campaignId = map["campaignId"];
                if (CheckJsonType(campaignId, Json::Type::Number, "campaignId", false)) {
                    this.campaignId = uint(campaignId);
                }
            }

            if (map.HasKey("campaignName")) {
                campaignType = CampaignType::Other;

                Json::Value@ campaignName = map["campaignName"];
                if (CheckJsonType(campaignName, Json::Type::String, "campaignName", false)) {
                    this.campaignName = string(campaignName);
                }

                Json::Value@ index = map["campaignIndex"];
                if (CheckJsonType(index, Json::Type::Number, "index", false)) {
                    this.index = int8(index);
                }
            }

            if (map.HasKey("clubId")) {
                Json::Value@ clubId = map["clubId"];
                if (CheckJsonType(clubId, Json::Type::Number, "clubId", false)) {
                    this.clubId = int(clubId);
                }
            }

            if (map.HasKey("clubName")) {
                Json::Value@ clubName = map["clubName"];
                if (CheckJsonType(clubName, Json::Type::String, "clubName", false)) {
                    this.clubName = string(clubName);
                }
            }

            Json::Value@ custom = map["custom"];
            if (CheckJsonType(custom, Json::Type::Number, "custom", false)) {
                this.custom = uint(custom);
            }

            if (map.HasKey("date")) {
                campaignType = CampaignType::TrackOfTheDay;

                Json::Value@ date = map["date"];
                if (CheckJsonType(date, Json::Type::String, "date", false)) {
                    this.date = string(date);

                    campaignName = MonthName(Text::ParseUInt(this.date.SubStr(5, 2))) + " " + this.date.SubStr(0, 4);
                    index = int8(Text::ParseUInt(this.date.SubStr(this.date.Length - 2)) - 1);
                }
            }

            Json::Value@ reason = map["reason"];
            if (CheckJsonType(reason, Json::Type::String, "reason", false)) {
                this.reason = reason;
            }

            if (campaignType == CampaignType::Seasonal) {
                campaignName = name.SubStr(0, name.Length - 5);
                index = int8(Text::ParseUInt(name.SubStr(name.Length - 2)) - 1);
            }
        }
        Map(Json::Value@ map, const string&in type) {  // full list
            author        = uint(map["authorTime"]);
            id            = string(map["mapId"]);
            name          = string(map["name"]).Trim();
            nameFormatted = OpenplanetFormatCodes(name);
            nameStripped  = StripFormatCodes(name);
            uid           = string(map["mapUid"]);
            warrior       = uint(map["warriorTime"]);
            worldRecord   = uint(map["worldRecord"]);

            Json::Value@ custom = map["custom"];
            if (CheckJsonType(custom, Json::Type::Number, "custom", false)) {
                this.custom = uint(custom);
            }

            Json::Value@ reason = map["reason"];
            if (CheckJsonType(reason, Json::Type::String, "reason", false)) {
                this.reason = reason;
            }

            if (type == "Seasonal") {
                campaignType = CampaignType::Seasonal;
                campaignId = int(map["campaignId"]);
                campaignName = name.SubStr(0, name.Length - 5);
                index = int8(Text::ParseUInt(name.SubStr(name.Length - 2)) - 1);

            } else if (type == "Weekly") {
                campaignType = CampaignType::Weekly;
                number = int(map["number"]);
                week = (number - 1) / 5 + 1;
                campaignName = "Week " + week;
                index = int8((number - 1) % 5);

            } else if (type == "Totd") {
                campaignType = CampaignType::TrackOfTheDay;
                date = string(map["date"]);
                campaignName = MonthName(Text::ParseUInt(date.SubStr(5, 2))) + " " + date.SubStr(0, 4);
                index = int8(Text::ParseUInt(date.SubStr(date.Length - 2)) - 1);

            } else if (type == "Other") {
                campaignType = CampaignType::Other;
                campaignId = int(map["campaignId"]);
                campaignName = string(map["campaignName"]);
                clubId = int(map["clubId"]);
                clubName = string(map["clubName"]);
                index = int8(map["mapIndex"]);

            } else {
                throw("invalid map type: " + type);
            }
        }

        void GetPB() {
            auto App = cast<CTrackMania>(GetApp());

            if (false
                or App.MenuManager is null
                or App.MenuManager.MenuCustom_CurrentManiaApp is null
                or App.MenuManager.MenuCustom_CurrentManiaApp.ScoreMgr is null
                or App.UserManagerScript is null
                or App.UserManagerScript.Users.Length == 0
                or App.UserManagerScript.Users[0] is null
            ) {
                pb = uint(-1);
                return;
            }

            pb = App.MenuManager.MenuCustom_CurrentManiaApp.ScoreMgr.Map_GetRecord_v2(App.UserManagerScript.Users[0].Id, uid, "PersonalBest", "", "TimeAttack", "");
        }

        void GetPBAsync() {
            if (gettingPB) {
                return;
            }

            gettingPB = true;

            GetPB();

            sleep(500);

            gettingPB = false;
        }

        void GetUrlAsync() {
            if (gettingUrl) {
                return;
            }

            gettingUrl = true;

            const uint64 start = Time::Now;
            trace("getting URL for " + name);

            if (false
                or uid.Length < 24  // incredibly rare but possible
                or uid.Length > 27
            ) {
                warn("getting URL for " + name + " failed: bad uid: " + uid);
                gettingUrl = false;
                return;
            }

            auto Menus = cast<CTrackManiaMenus>(cast<CTrackMania>(GetApp()).MenuManager);
            if (Menus is null) {
                warn("getting URL for " + name + " failed: null Menus");
                gettingUrl = false;
                return;
            }

            CGameManiaAppTitle@ Title = Menus.MenuCustom_CurrentManiaApp;
            if (Title is null) {
                warn("getting URL for " + name + " failed: null Title");
                gettingUrl = false;
                return;
            }

            if (false
                or Title.UserMgr is null
                or Title.UserMgr.Users.Length == 0
                or Title.UserMgr.Users[0] is null
                or Title.DataFileMgr is null
            ) {
                warn("getting URL for " + name + " failed: something is null/empty");
                gettingUrl = false;
                return;
            }

            CWebServicesTaskResult_NadeoServicesMapScript@ task = Title.DataFileMgr.Map_NadeoServices_GetFromUid(Title.UserMgr.Users[0].Id, uid);

            while (task.IsProcessing) {
                yield();
            }

            if (true
                and task !is null
                and task.HasSucceeded
            ) {
                if (task.Map !is null) {
                    downloadUrl = task.Map.FileUrl;
                    trace("getting URL for " + name + " done after " + (Time::Now - start) + "ms");
                }

                if (true
                    and Title !is null
                    and Title.DataFileMgr !is null
                ) {
                    Title.DataFileMgr.TaskResult_Release(task.Id);
                }
            } else {
                warn("getting URL for " + name + " failed after " + (Time::Now - start) + "ms");
            }

            gettingUrl = false;
        }

        void PlayAsync() {
            if (!Permissions::PlayLocalMap()) {  // extra safeguard because this is shared
                warn("user doesn't have permission to play local maps");
                return;
            }

            if (loading) {
                return;
            }

            if (downloadUrl.Length == 0) {
                GetUrlAsync();

                if (downloadUrl.Length == 0) {
                    warn("can't play " + name + ": blank url");
                    return;
                }
            }

            loading = true;
            trace("loading " + name);

            ReturnToMenuAsync();

            cast<CTrackMania>(GetApp()).ManiaTitleControlScriptAPI.PlayMap(
                downloadUrl,
                "TrackMania/TM_PlayMap_Local",
                ""
            );

            sleep(5000);

            loading = false;
        }

        private void ReturnToMenuAsync() {
            auto App = cast<CTrackMania>(GetApp());

            if (App.Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed) {
                App.Network.PlaygroundInterfaceScriptHandler.CloseInGameMenu(CGameScriptHandlerPlaygroundInterface::EInGameMenuResult::Quit);
            }

            App.BackToMainMenu();

            while (!App.ManiaTitleControlScriptAPI.IsReady) {
                yield();
            }
        }

        void SetPBFromAPI(Json::Value@ json) {
            if (false
                or (true
                    and _pb != uint(-1)
                    and _pb != 0
                )
                or !json.HasKey("score")
                or json["score"].GetType() != Json::Type::Number
            ) {
                return;
            }

            const uint score = uint(json["score"]);
            if (true
                and score != uint(-1)
                and score != 0
                and score < pb
            ) {
                pb = score;
            }
        }
    }
}
