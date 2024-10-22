// c 2024-10-22
// m 2024-10-22

Json::Value@ pbs = Json::Object();

namespace Files {
    const string pbsPath = IO::FromStorageFolder("pbs.json").Replace("\\", "/");

    void AddPB(const string &in uid, uint pb) {
        if (pb == uint(-1) || pb == 0)
            return;

        pbs[uid] = pb;
    }

    void AddPB(WarriorMedals::Map@ map) {
        if (map is null)
            return;

        AddPB(map.uid, map.pb);
    }

    uint GetPB(const string &in uid) {
        if (pbs.HasKey(uid))
            return JsonExt::GetUint(pbs, uid);

        return uint(-1);
    }

    void LoadPBs() {
        trace("loading pbs.json");

        if (!IO::FileExists(pbsPath)) {
            warn("pbs.json not found");
            @pbs = Json::Object();
            return;
        }

        try {
            @pbs = Json::FromFile(pbsPath);
            trace("loaded");
        } catch {
            warn("pbs.json failed to load: " + getExceptionInfo());
            @pbs = Json::Object();
        }

        if (!JsonExt::CheckType(pbs)) {
            warn("pbs.json wrong type");
            @pbs = Json::Object();
        }
    }

    void SavePB(const string &in uid, uint pb) {
        AddPB(uid, pb);
        SavePBs();
    }

    void SavePB(WarriorMedals::Map@ map) {
        if (map is null)
            return;

        SavePB(map.uid, map.pb);
    }

    void SavePBs() {
        trace("saving pbs.json");

        try {
            Json::ToFile(pbsPath, pbs);
        } catch {
            warn("pbs.json failed to save: " + getExceptionInfo());
        }

        trace("saved");
    }
}
