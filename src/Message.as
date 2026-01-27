class Message {
    bool   hidden    = false;
    int    id        = -1;
    string mapUid;
    string message;
    bool   notice    = false;
    bool   read      = false;
    string subject;
    int64  timestamp = 0;
    string type;

    bool get_big() {
        return false
            or subject.Length > 1000
            or message.Length > 10000
        ;
    }

    bool get_shown() {
        return !hidden;
    }

    bool get_unread() {
        return !read;
    }

    Message() { }
    Message(Json::Value@ message) {
        this.message = string(message["message"]);
        this.subject = string(message["subject"]);

        Json::Value@ id = message["id"];
        if (id.GetType() == Json::Type::Number) {
            this.id = int(id);
        }

        Json::Value@ mapUid = message["mapUid"];
        if (mapUid.GetType() == Json::Type::String) {
            this.mapUid = string(mapUid);
        }

        Json::Value@ timestamp = message["timestamp"];
        if (id.GetType() == Json::Type::Number) {
            this.timestamp = int64(timestamp);
        } else {
            this.timestamp = Time::Stamp;
        }

        Json::Value@ type = message["type"];
        if (type.GetType() == Json::Type::String) {
            this.type = string(type);
            if (this.type == "notice") {
                notice = true;
            }
        }
    }

    Message@ GetMap() {
        mapUid = InMap() ? GetApp().RootMap.EdChallengeId : "";
        return this;
    }

    Message@ Hide() {
        if (hidden) {
            return this;
        }

        hidden = true;
        unhiddenMessages--;

        if (hiddenMessages.Find(id) == -1) {
            hiddenMessages.InsertLast(id);

            Json::Value@ hidden = Json::Array();
            for (uint i = 0; i < hiddenMessages.Length; i++) {
                hidden.Add(Json::Value(hiddenMessages[i]));
            }
            trace("writing hidden.json");
            Json::ToFile(IO::FromStorageFolder("hidden.json"), hidden);
        }

        return Read();
    }

    Message@ Notify() {
        UI::ShowNotification(pluginTitle + ' - "' + subject + '"', message, 30000);
        return Read();
    }

    Message@ Read() {
        if (read) {
            return this;
        }

        read = true;
        unreadMessages--;

        if (readMessages.Find(id) == -1) {
            readMessages.InsertLast(id);

            Json::Value@ read = Json::Array();
            for (uint i = 0; i < readMessages.Length; i++) {
                read.Add(Json::Value(readMessages[i]));
            }
            trace("writing read.json");
            Json::ToFile(IO::FromStorageFolder("read.json"), read);
        }

        return this;
    }

    Message@ Send() {
        startnew(API::SendMessageAsync, this);
        return this;
    }

    Message@ Show() {
        if (shown) {
            return this;
        }

        hidden = false;
        unhiddenMessages++;

        const int index = hiddenMessages.Find(id);
        if (index > -1) {
            hiddenMessages.RemoveAt(index);

            Json::Value@ hidden = Json::Array();
            for (uint i = 0; i < hiddenMessages.Length; i++) {
                hidden.Add(Json::Value(hiddenMessages[i]));
            }
            trace("writing hidden.json");
            Json::ToFile(IO::FromStorageFolder("hidden.json"), hidden);
        }

        return this;
    }

    Json::Value@ ToJson() {
        Json::Value json = Json::Object();
        json["hidden"]    = hidden;
        json["id"]        = id;
        json["mapUid"]    = mapUid;
        json["message"]   = message;
        json["read"]      = read;
        json["subject"]   = subject;
        json["timestamp"] = timestamp;
        return json;
    }

    string ToString() {
        return Json::Write(ToJson());
    }

    Message@ Unread() {
        if (unread) {
            return this;
        }

        read = false;
        unreadMessages++;

        const int index = readMessages.Find(id);
        if (index > -1) {
            readMessages.RemoveAt(index);

            Json::Value@ read = Json::Array();
            for (uint i = 0; i < readMessages.Length; i++) {
                read.Add(Json::Value(readMessages[i]));
            }
            trace("writing read.json");
            Json::ToFile(IO::FromStorageFolder("read.json"), read);
        }

        return this;
    }
}
