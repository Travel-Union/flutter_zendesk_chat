package com.travelunion.flutter_zendesk_chat.Models;

import zendesk.chat.ChatLog;
import zendesk.chat.ChatParticipant;
import zendesk.chat.ChatRating;
import zendesk.chat.DeliveryStatus;

public class ChatLogEvent {
    public String id;
    public String type;
    public long createTimestamp;
    public long modifyTimestamp;
    public String deliveryStatus;
    public String displayName;
    public String nick;
    public String participant;
    public String message;
    public String previousRating;
    public String currentRating;
    public String previousComment;
    public String currentComment;
    public ChatAttachment attachment;


    ChatLogEvent(String id,
                 ChatLog.Type type,
                 long createTimestamp,
                 long modifyTimestamp,
                 DeliveryStatus deliveryStatus,
                 String displayName,
                 String nick,
                 ChatParticipant participant,
                 String message,
                 String previousRating,
                 String currentRating,
                 String previousComment,
                 String currentComment,
                 ChatAttachment attachment) {
        this.id = id;
        this.type = type.name();
        this.createTimestamp = createTimestamp;
        this.modifyTimestamp = modifyTimestamp;
        this.deliveryStatus = deliveryStatus.name();
        this.displayName = displayName;
        this.nick = nick;
        this.participant = participant.name();
        this.message = message;
        this.previousRating = previousRating;
        this.currentRating = currentRating;
        this.previousComment = previousComment;
        this.currentComment = currentComment;
        this.attachment = attachment;
    }

    public static ChatLogEvent fromChatLog(ChatLog log) {
        String message = null;
        String previousRating = null;
        String currentRating = null;
        String previousComment = null;
        String currentComment = null;
        ChatAttachment attachment = null;

        String id = log.getId();
        ChatLog.Type type = log.getType();
        long timestamp = log.getCreatedTimestamp();
        long modifyTimestamp = log.getLastModifiedTimestamp();
        DeliveryStatus deliveryStatus = log.getDeliveryStatus();
        String displayName = log.getDisplayName();
        String nick = log.getNick();
        ChatParticipant participant = log.getChatParticipant();

        if(type == ChatLog.Type.MESSAGE) {
            ChatLog.Message event = (ChatLog.Message) log;
            message = event.getMessage();
        } else if(type == ChatLog.Type.RATING) {
            ChatLog.Rating event = (ChatLog.Rating) log;
            ChatRating previous = event.getChatRating();
            ChatRating current = event.getNewChatRating();
            previousRating = previous != null ? previous.name() : null;
            currentRating = current != null ? event.getNewChatRating().name() : null;
        } else if(type == ChatLog.Type.ATTACHMENT_MESSAGE) {
            ChatLog.AttachmentMessage event = (ChatLog.AttachmentMessage) log;
            attachment = ChatAttachment.fromAttachment(event.getAttachment());
        } else if(type == ChatLog.Type.COMMENT) {
            ChatLog.Comment event = (ChatLog.Comment) log;
            previousComment = event.getChatComment();
            currentComment = event.getNewChatComment();
        }

        return new ChatLogEvent(id, type, timestamp, modifyTimestamp, deliveryStatus, displayName, nick, participant, message, previousRating, currentRating, previousComment, currentComment, attachment);
    }
}
