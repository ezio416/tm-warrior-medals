// c 2024-07-21
// m 2024-07-22

/*
Exports from the Warrior Medals plugin.
*/
namespace WarriorMedals {
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
            case 1:  return "january";
            case 2:  return "february";
            case 3:  return "march";
            case 4:  return "april";
            case 5:  return "may";
            case 6:  return "june";
            case 7:  return "july";
            case 8:  return "august";
            case 9:  return "september";
            case 10: return "october";
            case 11: return "november";
            default: return "december";
        }
    }

    /*
    Data container for a map with a Warrior medal.
    */
    shared class Map {
        private uint _pb = uint(-1);
        uint get_pb() { return _pb; }
        private void set_pb(uint p) { _pb = p; }

        private uint _author;
        uint get_author() { return _author; }
        private void set_author(uint a) { _author = a; }

        private string _campaign;
        string get_campaign() { return _campaign; }
        private void set_campaign(const string &in c) { _campaign = c.ToLower(); }

        private uint _custom = 0;
        uint get_custom() { return _custom; }
        private void set_custom(uint c) { _custom = c; }

        private string _date;
        string get_date() { return _date; }
        private void set_date(const string &in d) { _date = d; }

        private uint8 _index = uint8(-1);
        uint8 get_index() { return _index; }
        private void set_index(uint8 i) { _index = i; }

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
            name        = string(map["name"]);
            uid         = string(map["uid"]);
            warrior     = uint(  map["warriorTime"]);
            worldRecord = uint(  map["worldRecord"]);

            bool seasonal = true;

            if (map.HasKey("campaign")) {
                seasonal = false;

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
                seasonal = false;

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

            if (seasonal) {
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
    }
}
