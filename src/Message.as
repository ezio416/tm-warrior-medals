// c 2025-10-30
// m 2025-10-30

class Message {
    int    id        = -1;
    string message;
    string subject;
    int64  timestamp = 0;
    string type;

    Message(Json::Value@ message) {
        this.message = string(message["message"]);
        this.subject = string(message["subject"]);

        Json::Value@ id = message["id"];
        if (id.GetType() == Json::Type::Number) {
            this.id = int(id);
        }

        Json::Value@ timestamp = message["timestamp"];
        if (id.GetType() == Json::Type::Number) {
            this.timestamp = int64(timestamp);
        } else {
            this.timestamp = Time::Stamp;
        }
    }

    Json::Value@ ToJson() {
        Json::Value json = Json::Object();
        json["id"] = id;
        json["message"] = message;
        json["subject"] = subject;
        json["timestamp"] = timestamp;
        return json;
    }

    void Send() {
        startnew(API::SendMessageAsync, this);
    }

    string ToString() {
        return Json::Write(ToJson());
    }
}
