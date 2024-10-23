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
        const uint64 start = Time::Now;
        trace("loading pbs.json");

        if (!IO::FileExists(pbsPath)) {
            warn("pbs.json not found");
            @pbs = Json::Object();
            return;
        }

        try {
            @pbs = Json::FromFile(pbsPath);
        } catch {
            warn("pbs.json failed to load: " + getExceptionInfo());
            @pbs = Json::Object();
        }

        if (!JsonExt::CheckType(pbs)) {
            warn("pbs.json wrong type");
            @pbs = Json::Object();
        }

        uint missing = 0;
        string[]@ uids = pbs.GetKeys();
        string uid;

        for (uint i = 0; i < uids.Length; i++) {
            uid = uids[i];

            if (maps.Exists(uid)) {
                WarriorMedals::Map@ map = cast<WarriorMedals::Map@>(maps[uid]);

                if (map !is null) {
                    const uint score = uint(pbs[uid]);

                    if (score != uint(-1) && score > 0)
                        map.pb = score;
                } else
                    warn("map is null: " + uid);
            } else {
                warn("missing key in maps: " + uid);
                missing++;
            }
        }

        trace("loaded " + pbs.Length + " PBs" + (missing > 0 ? " (" + missing + " missing)" : "") + " after " + (Time::Now - start) + "ms");
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
        const uint64 start = Time::Now;
        trace("saving pbs.json with " + pbs.Length + " elements");

        try {
            Json::ToFile(pbsPath, pbs);
            trace("saved after " + (Time::Now - start) + "ms");
        } catch {
            warn("pbs.json failed to save after " + (Time::Now - start) + "ms: " + getExceptionInfo());
        }
    }
}
