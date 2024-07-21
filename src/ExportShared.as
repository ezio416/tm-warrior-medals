// c 2024-07-21
// m 2024-07-21

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
    Data container for a map with a Warrior medal.
    */
    shared class Map {
        private uint _author;
        uint get_author() { return _author; }
        private void set_author(uint a) { _author = a; }

        private string _campaign;
        string get_campaign() { return _campaign; }
        private void set_campaign(const string &in c) { _campaign = c; }

        private uint _custom = 0;
        uint get_custom() { return _custom; }
        private void set_custom(uint c) { _custom = c; }

        private string _date;
        string get_date() { return _date; }
        private void set_date(const string &in d) { _date = d; }

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

            if (map.HasKey("campaign")) {
                Json::Value@ _campaign = map["campaign"];
                if (CheckJsonType(_campaign, Json::Type::String, "_campaign", false))
                    campaign = string(_campaign);
            }

            Json::Value@ _custom = map["custom"];
            if (CheckJsonType(_custom, Json::Type::Number, "_custom", false))
                custom = uint(_custom);

            if (map.HasKey("date")) {
                Json::Value@ _date = map["date"];
                if (CheckJsonType(_date, Json::Type::String, "_date", false))
                    date = string(_date);
            }

            Json::Value@ _reason = map["reason"];
            if (CheckJsonType(_reason, Json::Type::String, "_reason", false))
                reason = _reason;
        }
    }
}
