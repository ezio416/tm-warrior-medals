// c 2025-10-30
// m 2025-10-31

string newMessage;
string newSubject;
bool   showMessages = false;

void MessagesWindow() {
    if (false
        or !showMessages
        or !UI::IsGameUIVisible()
        or !UI::IsOverlayShown()
    ) {
        return;
    }

    const float scale = UI::GetScale();

    UI::SetNextWindowSize(400, 250, UI::Cond::FirstUseEver);
    if (UI::Begin(
        pluginTitle + "\\$666 v" + pluginMeta.Version + "\\$38C Messages###warrior-medals-messages",
        showMessages,
        UI::WindowFlags::None
    )) {
        UI::BeginTabBar("##tabbar-warrior-messages");

        if (UI::BeginTabItem(Icons::Inbox + " Inbox" + (unreadMessages > 0 ? " (" + unreadMessages + ")" : "") + "###tab-warrior-inbox")) {
            UI::BeginDisabled(API::requesting);
            if (UI::Button(Icons::Refresh)) {
                startnew(API::GetMessagesAsync);
            }
            UI::SetTooltip("refresh");
            UI::EndDisabled();  // API::requesting

            UI::SameLine();
            if (UI::Button(Icons::Envelope)) {
                for (uint i = 0; i < messages.Length; i++) {
                    if (!messages[i].hidden) {
                        messages[i].Unread();
                    }
                }
            }
            UI::SetTooltip("mark all unread");

            UI::SameLine();
            if (UI::Button(Icons::EnvelopeOpen)) {
                for (uint i = 0; i < messages.Length; i++) {
                    if (!messages[i].hidden) {
                        messages[i].Read();
                    }
                }
            }
            UI::SetTooltip("mark all read");

            UI::Separator();

            UI::BeginChild("##child-inbox");

            for (uint i = 0; i < messages.Length; i++) {
                Message@ message = messages[i];
                if (message.hidden) {
                    continue;
                }

                if (UI::TreeNode((message.read ? "" : "* ") + message.subject + "\\$888 #" + message.id + "###message-tree" + message.id, UI::TreeNodeFlags::Framed)) {
                    if (message.read) {
                        if (UI::Button(Icons::EnvelopeO + "##" + i)) {
                            message.Unread();
                        }
                        UI::SetTooltip("mark as unread");
                    } else {
                        if (UI::Button(Icons::EnvelopeOpenO + "##" + i)) {
                            message.Read();
                        }
                        UI::SetTooltip("mark as read");
                    }

                    UI::SameLine();
                    if (UI::Button(Icons::EyeSlash + "##" + i)) {
                        message.Hide();
                    }
                    UI::SetTooltip("hide");

                    if (message.notice) {
                        UI::SameLine();
                        UI::BeginDisabled();
                        UI::Button(Icons::ExclamationCircle);
                        UI::SetTooltip("message is a notice");
                        UI::EndDisabled();
                    }

                    UI::TextWrapped(message.message);
                    UI::TextDisabled(Time::FormatString("%F %T", message.timestamp));

                    UI::TreePop();
                }
            }

            UI::EndChild();

            UI::EndTabItem();
        }

        const bool dirty = false
            or newMessage.Length > 0
            or newSubject.Length > 0
        ;

        if (UI::BeginTabItem(Icons::Pencil + " Compose", dirty ? UI::TabItemFlags::UnsavedDocument : UI::TabItemFlags::None)) {
            UI::TextWrapped("Messages are \\$FA0NOT \\$Gencrypted. Never send sensitive information!");

            UI::Separator();

            UI::AlignTextToFramePadding();
            UI::Text("subject");
            UI::SameLine();
            UI::SetNextItemWidth(UI::GetContentRegionAvail().x / scale);
            newSubject = UI::InputText("##input-subject", newSubject);

            UI::AlignTextToFramePadding();
            UI::Text("message");
            UI::SameLine();
            const vec2 avail = UI::GetContentRegionAvail();
            newMessage = UI::InputTextMultiline(
                "##input-message",
                newMessage,
                vec2(avail.x / scale, (avail.y - 32.0f) / scale),
                UI::InputTextFlags::NoHorizontalScroll
            );

            UI::BeginDisabled(false
                or newSubject.Length == 0
                or newMessage.Length == 0
                or API::requesting
            );
            if (UI::Button(Icons::PaperPlane + " Send Message", vec2(UI::GetContentRegionAvail().x, scale * 25.0f))) {
                Message message;
                message.subject = newSubject;
                message.message = newMessage;
                startnew(API::SendMessageAsync, message);
            }
            UI::EndDisabled();  // empty subject/message

            UI::EndTabItem();
        }

        UI::EndTabBar();
    }
    UI::End();
}
