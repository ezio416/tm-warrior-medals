namespace JsonExt {
    bool CheckType(Json::Value@ json, const Json::Type type = Json::Type::Object) {
        if (json is null) {
            return false;
        }

        return json.GetType() == type;
    }

    string GetString(Json::Value@ json, const string&in key) {
        try {
            return string(GetValue(json, key, Json::Type::String));
        } catch {
            return "";
        }
    }

    Json::Value@ GetValue(Json::Value@ json, const string&in key, const Json::Type type = Json::Type::Object) {
        if (false
            or json is null
            or !json.HasKey(key)
        ) {
            return null;
        }

        Json::Value@ value = json.Get(key);

        if (!CheckType(value, type)) {
            return null;
        }

        return value;
    }
}
