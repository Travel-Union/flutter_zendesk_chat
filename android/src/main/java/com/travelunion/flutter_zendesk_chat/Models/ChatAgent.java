package com.travelunion.flutter_zendesk_chat.Models;

import zendesk.chat.Agent;

public class ChatAgent {
    public String displayName;
    public String nick;
    public String avatarPath;
    public boolean isTyping;

    ChatAgent(String displayName, String nick, String avatarPath, boolean isTyping) {
        this.displayName = displayName;
        this.nick = nick;
        this.avatarPath = avatarPath;
        this.isTyping = isTyping;
    }

    public static ChatAgent fromAgent(Agent agent) {
        String displayName = agent.getDisplayName();
        String nick = agent.getNick();
        String avatarPath = agent.getAvatarPath();
        boolean isTyping = agent.isTyping();

        return new ChatAgent(displayName, nick, avatarPath, isTyping);
    }
}
