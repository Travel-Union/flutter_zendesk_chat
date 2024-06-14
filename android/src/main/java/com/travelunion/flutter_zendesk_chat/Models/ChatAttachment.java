package com.travelunion.flutter_zendesk_chat.Models;

import java.io.File;

import zendesk.chat.Attachment;

public class ChatAttachment {
    public ChatAttachmentMetadata metadata;
    public File file;
    public String mimeType;
    public String name;
    public long size;
    public String url;

    ChatAttachment(ChatAttachmentMetadata metadata, File file, String mimeType, String name, long size, String url) {
        this.metadata = metadata;
        this.file = file;
        this.mimeType = mimeType;
        this.name = name;
        this.size = size;
        this.url = url;
    }

    public static ChatAttachment fromAttachment(Attachment attachment) {
        ChatAttachmentMetadata metadata = null; // Initialize metadata as null
        if (attachment.getMetadata() != null) {
            metadata = ChatAttachmentMetadata.fromMetadata(attachment.getMetadata());
        }
        File file = attachment.getFile();
        String mimeType = attachment.getMimeType();
        String name = attachment.getName();
        long size = attachment.getSize();
        String url = attachment.getUrl();

        return new ChatAttachment(metadata, file, mimeType, name, size, url);
    }
}
