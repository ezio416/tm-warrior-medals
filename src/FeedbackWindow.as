// c 2024-12-23
// m 2024-12-24

bool   feedbackAnon   = true;
bool   feedbackLocked = false;
string feedbackMessage;
bool   feedbackShown  = false;
string feedbackSubject;

void FeedbackWindow() {
    if (false
        || !feedbackShown
        || !UI::IsGameUIVisible()
        || !UI::IsOverlayShown()
    )
        return;

    UI::SetNextWindowSize(300, 250);
    if (UI::Begin(title + " \\$FA3Feedback###warrior-medals-feedback", feedbackShown, UI::WindowFlags::AlwaysAutoResize)) {
        UI::BeginDisabled(API::requesting);

        UI::AlignTextToFramePadding();
        UI::Text("subject");
        UI::SameLine();
        UI::SetNextItemWidth(UI::GetContentRegionAvail().x / scale);
        feedbackSubject = UI::InputText("##input-subject", feedbackSubject);

        UI::AlignTextToFramePadding();
        UI::Text("message");
        UI::SameLine();
        UI::SetNextItemWidth(UI::GetContentRegionAvail().x / scale);
        feedbackMessage = UI::InputTextMultiline("##input-message", feedbackMessage, vec2(), UI::InputTextFlags::NoHorizontalScroll);

        if (InMap())
            UI::Text("\\$AAAmap uid: " + GetApp().RootMap.EdChallengeId);

        feedbackAnon = !UI::Checkbox("Include account ID", !feedbackAnon);

        UI::SameLine();
        UI::BeginDisabled(feedbackSubject.Length == 0 || feedbackMessage.Length == 0 || feedbackLocked);
        if (UI::Button(Icons::PaperPlane + " Send Feedback", vec2(UI::GetContentRegionAvail().x, scale * 25.0f)))
            startnew(SendFeedbackAsync);
        UI::EndDisabled();
        if (feedbackLocked)
            HoverTooltip("Calm down on the feedback!");
        else
            HoverTooltip(
                "What you're sending to the plugin author's server:\n\n    - subject, message, and UID (if you're in a map) above"
                + "\n    - your game version\n    - your Openplanet version" + (feedbackAnon ? "" : "\n    - your account ID")
            );

        UI::EndDisabled();
    }
    UI::End();
}

void SendFeedbackAsync() {
    const bool success = API::SendFeedbackAsync(feedbackSubject, feedbackMessage, feedbackAnon);
    if (success) {
        const string msg = "Thanks for the feedback!";
        print("\\$0F0" + msg);
        UI::ShowNotification(title, msg);

        feedbackSubject = "";
        feedbackMessage = "";
    }
}
