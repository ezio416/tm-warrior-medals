// c 2024-10-21
// m 2024-10-22

namespace JsonExt {
    bool CheckType(Json::Value@ json, Json::Type type = Json::Type::Object) {
        if (json is null)
            return false;

        return json.GetType() == type;
    }

    bool GetBool(Json::Value@ json, const string &in key) {
        try {
            return bool(GetValue(json, key, Json::Type::Boolean));
        } catch {
            return false;
        }
    }

    int GetInt(Json::Value@ json, const string &in key) {
        try {
            return int(GetValue(json, key, Json::Type::Number));
        } catch {
            return -1;
        }
    }

    int64 GetInt64(Json::Value@ json, const string &in key) {
        try {
            return int64(GetValue(json, key, Json::Type::Number));
        } catch {
            return -1;
        }
    }

    string GetString(Json::Value@ json, const string &in key) {
        try {
            return string(GetValue(json, key, Json::Type::String));
        } catch {
            return "";
        }
    }

    uint32 GetUint(Json::Value@ json, const string &in key) {
        try {
            return uint(GetValue(json, key, Json::Type::Number));
        } catch {
            return uint(-1);
        }
    }

    Json::Value@ GetValue(Json::Value@ json, const string &in key, Json::Type type = Json::Type::Object) {
        if (json is null || !json.HasKey(key))
            return null;

        Json::Value@ value = json.Get(key);

        if (!CheckType(value, type))
            return null;

        return value;
    }
}
