// c 2025-10-23
// m 2025-10-27

class Token {
    int64            expiry  = 0;
    bool             getting = false;
    protected string _token;

    bool get_expired() {
        return Time::Stamp >= expiry;
    }

    string get_token() {
        return _token;
    }

    void set_token(const string&in t) {
        _token = t;
        API::savedToken = t;
    }

    bool get_valid() {
        return true
            and _token.Length == 36
            and !expired
        ;
    }

    string opImplConv() {
        return _token;
    }

    void Clear() {
        token = "";
        expiry = 0;
    }

    void Get() {
        startnew(API::GetTokenAsync);
    }

    Json::Value@ ToJson() {
        Json::Value json = Json::Object();
        json["token"] = _token;
        json["expiry"] = expiry;
        return json;
    }
}
