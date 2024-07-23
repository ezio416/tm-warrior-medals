// c 2024-07-21
// m 2024-07-23

/*
Exports from the Warrior Medals plugin.
*/
namespace WarriorMedals {
    /*
    Enum describing the type a campaign is or the type of campaign a map is a part of.
    */
    shared enum CampaignType {
        Seasonal,
        TrackOfTheDay,
        Other,
        Unknown
    }

    /*
    Simple function for checking if a given Json::Value@ is of the correct type.
    Only shared to make the compiler happy.
    */
    shared bool CheckJsonType(Json::Value@ value, Json::Type desired, const string &in name, bool warning = true) {
        if (value is null) {
            if (warning)
                warn(name + " is null");
            return false;
        }

        const Json::Type type = value.GetType();
        if (type != desired) {
            if (warning)
                warn(name + " is a(n) " + tostring(type) + ", not a(n) " + tostring(desired));
            return false;
        }

        return true;
    }

    /*
    Simple function to get a month's name from its number.
    Only shared to make the compiler happy.
    */
    shared string MonthName(uint num) {
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
    Data container for a map with a Warrior medal.
    */
    shared class Map {
        private bool gettingUrl = false;

        private uint _pb = uint(-1);
        uint get_pb() { return _pb; }
        private void set_pb(uint p) { _pb = p; }

        private uint _author;
        uint get_author() { return _author; }
        private void set_author(uint a) { _author = a; }

        private string _campaign;
        string get_campaign() { return _campaign; }
        private void set_campaign(const string &in c) { _campaign = c; }

        private CampaignType _campaignType;
        CampaignType get_campaignType() { return _campaignType; }
        private void set_campaignType(CampaignType c) { _campaignType = c; }

        private uint _custom = 0;
        uint get_custom() { return _custom; }
        private void set_custom(uint c) { _custom = c; }

        private string _date;
        string get_date() { return _date; }
        private void set_date(const string &in d) { _date = d; }

        private string _downloadUrl;
        string get_downloadUrl() { return _downloadUrl; }
        private void set_downloadUrl(const string &in d) { _downloadUrl = d; }

        // private uint8 _index = uint8(-1);
        // uint8 get_index() { return _index; }
        // private void set_index(uint8 i) { _index = i; }
        uint8 index = uint8(-1);

        private bool _loading = false;
        bool get_loading() { return _loading; }
        private void set_loading(bool l) { _loading = l; }

        private string _name;
        string get_name() { return _name; }
        private void set_name(const string &in n) { _name = n; }

        private string _reason;
        string get_reason() { return _reason; }
        private void set_reason(const string &in r) { _reason = r; }

        private string _uid;
        string get_uid() { return _uid; }
        private void set_uid(const string &in u) { _uid = u; }

        private uint _warrior;
        uint get_warrior() { return _warrior; }
        private void set_warrior(uint w) { _warrior = w; }

        private uint _worldRecord;
        uint get_worldRecord() { return _worldRecord; }
        private void set_worldRecord(uint w) { _worldRecord = w; }

        Map() { }
        Map(Json::Value@ map) {
            author      = uint(  map["authorTime"]);
            name        = string(map["name"]).Trim();
            uid         = string(map["uid"]);
            warrior     = uint(  map["warriorTime"]);
            worldRecord = uint(  map["worldRecord"]);

            campaignType = CampaignType::Seasonal;

            if (map.HasKey("campaign")) {
                campaignType = CampaignType::Other;

                Json::Value@ campaign = map["campaign"];
                if (CheckJsonType(campaign, Json::Type::String, "campaign", false))
                    this.campaign = string(campaign);

                Json::Value@ index = map["campaignIndex"];
                if (CheckJsonType(index, Json::Type::Number, "index", false))
                    this.index = uint8(index);
            }

            Json::Value@ custom = map["custom"];
            if (CheckJsonType(custom, Json::Type::Number, "custom", false))
                this.custom = uint(custom);

            if (map.HasKey("date")) {
                campaignType = CampaignType::TrackOfTheDay;

                Json::Value@ date = map["date"];
                if (CheckJsonType(date, Json::Type::String, "date", false)) {
                    this.date = string(date);

                    campaign = MonthName(Text::ParseUInt(this.date.SubStr(5, 2))) + " " + this.date.SubStr(0, 4);
                    index = uint8(Text::ParseUInt(this.date.SubStr(this.date.Length - 2)) - 1);
                }
            }

            Json::Value@ reason = map["reason"];
            if (CheckJsonType(reason, Json::Type::String, "reason", false))
                this.reason = reason;

            if (campaignType == CampaignType::Seasonal) {
                campaign = name.SubStr(0, name.Length - 5);
                index = uint8(Text::ParseUInt(name.SubStr(name.Length - 2)) - 1);
            }
        }

        void GetPB() {
            CTrackMania@ App = cast<CTrackMania@>(GetApp());

            if (false
                || App.MenuManager is null
                || App.MenuManager.MenuCustom_CurrentManiaApp is null
                || App.MenuManager.MenuCustom_CurrentManiaApp.ScoreMgr is null
                || App.UserManagerScript is null
                || App.UserManagerScript.Users.Length == 0
                || App.UserManagerScript.Users[0] is null
            )
                pb = uint(-1);

            pb = App.MenuManager.MenuCustom_CurrentManiaApp.ScoreMgr.Map_GetRecord_v2(App.UserManagerScript.Users[0].Id, uid, "PersonalBest", "", "TimeAttack", "");
        }

        void GetUrlAsync() {
            if (gettingUrl)
                return;

            gettingUrl = true;

            const uint64 start = Time::Now;
            trace("getting URL for " + name);

            if (uid.Length != 26 && uid.Length != 27) {
                warn("getting URL for " + name + " failed: bad uid: " + uid);
                gettingUrl = false;
                return;
            }

            CTrackMania@ App = cast<CTrackMania@>(GetApp());

            CTrackManiaMenus@ Menus = cast<CTrackManiaMenus@>(App.MenuManager);
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
                || Title.UserMgr is null
                || Title.UserMgr.Users.Length == 0
                || Title.UserMgr.Users[0] is null
                || Title.DataFileMgr is null
            ) {
                warn("getting URL for " + name + " failed: something is null/empty");
                gettingUrl = false;
                return;
            }

            CWebServicesTaskResult_NadeoServicesMapScript@ task = Title.DataFileMgr.Map_NadeoServices_GetFromUid(Title.UserMgr.Users[0].Id, uid);

            while (task.IsProcessing)
                yield();

            if (task !is null && task.HasSucceeded) {
                CNadeoServicesMap@ Map = task.Map;
                if (Map !is null) {
                    downloadUrl = Map.FileUrl;
                    trace("getting URL for " + name + " done after " + (Time::Now - start) + "ms");
                }

                if (Title !is null && Title.DataFileMgr !is null)
                    Title.DataFileMgr.TaskResult_Release(task.Id);
            } else
                warn("getting URL for " + name + " failed after " + (Time::Now - start) + "ms");

            gettingUrl = false;
        }

        void PlayAsync() {
            if (!Permissions::PlayLocalMap()) {  // extra safeguard because this is shared
                warn("user doesn't have permission to play local maps");
                return;
            }

            if (loading)
                return;

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

            CTrackMania@ App = cast<CTrackMania@>(GetApp());
            App.ManiaTitleControlScriptAPI.PlayMap(downloadUrl, "TrackMania/TM_PlayMap_Local", "");

            sleep(5000);

            loading = false;
        }

        private void ReturnToMenuAsync() {
            CTrackMania@ App = cast<CTrackMania@>(GetApp());

            if (App.Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed)
                App.Network.PlaygroundInterfaceScriptHandler.CloseInGameMenu(CGameScriptHandlerPlaygroundInterface::EInGameMenuResult::Quit);

            App.BackToMainMenu();

            while (!App.ManiaTitleControlScriptAPI.IsReady)
                yield();
        }
    }
}
