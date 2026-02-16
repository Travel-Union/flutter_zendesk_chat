package com.travelunion.flutter_zendesk_chat;

import androidx.annotation.NonNull;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import zendesk.messaging.android.push.PushNotifications;
import zendesk.messaging.android.push.PushResponsibility;

public class ZendeskMessagingService extends FirebaseMessagingService {

    @Override
    public void onNewToken(@NonNull String newToken) {
        PushNotifications.updatePushNotificationToken(newToken);
    }

    @Override
    public void onMessageReceived(@NonNull RemoteMessage remoteMessage) {
        PushResponsibility responsibility =
                PushNotifications.shouldBeDisplayed(remoteMessage.getData());

        switch (responsibility) {
            case MESSAGING_SHOULD_DISPLAY:
                PushNotifications.displayNotification(this, remoteMessage.getData());
                return;

            case MESSAGING_SHOULD_NOT_DISPLAY:
                return;

            case NOT_FROM_MESSAGING:
            default:
                // Not a Zendesk push -> let other handlers deal with it.
                // If you have another SDK, call it here.
                // Example: MyOtherPushSdk.handleMessage(remoteMessage);
                break;
        }
    }
}
