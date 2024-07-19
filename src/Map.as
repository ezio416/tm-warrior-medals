// c 2024-07-18
// m 2024-07-18

class Map {
    uint   author;
    string campaign;
    uint   custom = 0;
    string date;
    string name;
    string reason;
    string uid;
    uint   warrior;
    uint   worldRecord;

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
