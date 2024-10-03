// c 2024-07-18
// m 2024-10-02

uint ActiveScoreMgrTasks() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (false
        || App.MenuManager is null
        || App.MenuManager.MenuCustom_CurrentManiaApp is null
        || App.MenuManager.MenuCustom_CurrentManiaApp.ScoreMgr is null
    )
        return 0;

    return App.MenuManager.MenuCustom_CurrentManiaApp.ScoreMgr.TaskResults.Length;
}

void CacheUserIdAsync() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    ;
}

void GetAllPBsAsync() {
    const string[]@ uids = maps.GetKeys();

    uint64 lastYield = Time::Now;
    const uint64 maxFrameTime = 50;

    const uint64 start = lastYield;
    trace("getting all PBs");

    string[] uidsLeft;
    for (uint i = 0; i < uids.Length; i++)
        uidsLeft.InsertLast(uids[i]);

    MwFastBuffer<wstring>[] bufs;
    while (uidsLeft.Length > 0) {
        MwFastBuffer<wstring> buf;

        const uint uidsToAdd = Math::Min(uidsLeft.Length, 200);

        for (uint i = 0; i < uidsToAdd; i++)
            buf.Add(uidsLeft[i]);

        bufs.InsertLast(buf);

        uidsLeft.RemoveRange(0, uidsToAdd);
    }

    uint done = 0;
    bool failed = false;
    for (uint i = 0; i < bufs.Length; i++) {
        trace("LoadPBsAsync(bufs[" + i + "])");

        SetLoadingPbText(done, uids.Length);

        if (!LoadPBsAsync(bufs[i]))
            failed = true;
        else
            done += bufs[i].Length;
    }

    if (failed) {
        warn("failed getting all PBs");
        SetLoadingPbText(0, 0, "getting PBs failed");
        return;
    }

    sleep(1000);

    for (uint i = 0; i < uids.Length; i++) {
        const uint64 now = Time::Now;
        if (now - lastYield > maxFrameTime) {
            lastYield = now;
            yield();
        }

        WarriorMedals::Map@ map = cast<WarriorMedals::Map@>(maps[uids[i]]);
        if (map is null)
            continue;

        map.GetPB();
    }

    trace("getting all PBs done after " + (Time::Now - start) + "ms");
    SetLoadingPbText(0, 0);
}

void HoverTooltip(const string &in msg) {
    if (!UI::IsItemHovered())
        return;

    UI::BeginTooltip();
        UI::Text(msg);
    UI::EndTooltip();
}

bool InMap() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    return true
        && App.RootMap !is null
        && App.CurrentPlayground !is null
        && App.Editor is null
    ;
}

bool LoadPBsAsync(MwFastBuffer<wstring> &in uids) {
    const uint64 start = Time::Now;
    // trace("loading PBs (" + uids.Length + ")");

    while (ActiveScoreMgrTasks() > 0)
        yield();

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (false
        || App.MenuManager is null
        || App.MenuManager.MenuCustom_CurrentManiaApp is null
        || App.MenuManager.MenuCustom_CurrentManiaApp.ScoreMgr is null
        || App.UserManagerScript is null
        || App.UserManagerScript.Users.Length == 0
        || App.UserManagerScript.Users[0] is null
    )
        return false;

    CGameScoreAndLeaderBoardManagerScript@ ScoreMgr = App.MenuManager.MenuCustom_CurrentManiaApp.ScoreMgr;

    CWebServicesTaskResult@ result = ScoreMgr.Map_LoadPBScoreList(
        App.UserManagerScript.Users[0].Id,
        uids,
        "TimeAttack",
        ""
    );

    uint i = 1;
    while (result.IsProcessing) {
        if (i++ % 200 == 0)
            trace("still loading");

        yield();
    }

    if (result is null || result.HasFailed || !result.HasSucceeded) {
        warn("loading PBs failed after " + (Time::Now - start) + "ms: " + (result !is null ? string(result.ErrorDescription) : "result null"));

        if (ScoreMgr !is null && result !is null)
            ScoreMgr.TaskResult_Release(result.Id);

        return false;
    }

    // print("result: " + result.ErrorDescription);

    if (ScoreMgr !is null && result !is null)
        ScoreMgr.TaskResult_Release(result.Id);

    trace("loading PBs (" + uids.Length + ") done after " + (Time::Now - start) + "ms");
    return true;
}

void PlayMapAsync(ref@ m) {
    if (!hasPlayPermission) {
        warn("user doesn't have permission to play local maps");
        return;
    }

    WarriorMedals::Map@ map = cast<WarriorMedals::Map@>(m);
    if (map is null) {
        warn("given map is null");
        return;
    }

    loading = true;
    map.PlayAsync();
    loading = false;
}

void SetLoadingPbText(uint done, uint total, const string &in custom = "") {
    const string pre = "  \\$888\\$I";

    if (custom.Length > 0) {
        loadingPbText = pre + custom;
        return;
    }

    if (done == total || (done == 0 && total == 0)) {
        loadingPbText = "";
        return;
    }

    loadingPbText = pre + "loading PBs... (" + done + " / " + total + ")";
}
