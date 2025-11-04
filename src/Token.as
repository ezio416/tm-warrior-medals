// c 2025-10-23
// m 2025-11-04

class Token {
    bool getting = false;

    bool get_expired() {
        return Time::Stamp >= expiry;
    }

    protected int64 _expiry = 0;
    int64 get_expiry() { return _expiry; }
    void set_expiry(const int64 e) {
        _expiry = e;
        API::savedExpiry = e;
    }

    protected string _token;
    string get_token() { return _token; }
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

    void WatchAsync() {
        while (true) {
            sleep(1000);

            if (expired) {
                startnew(API::GetTokenAsync);
                return;
            }
        }
    }
}
