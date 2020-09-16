package com.travelunion.flutter_zendesk_chat;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.google.gson.GsonBuilder;
import com.travelunion.flutter_zendesk_chat.Models.ChatAgent;
import com.travelunion.flutter_zendesk_chat.Models.ChatLogEvent;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import zendesk.chat.Account;
import zendesk.chat.Agent;
import zendesk.chat.Chat;
import zendesk.chat.ChatLog;
import zendesk.chat.ChatProvider;
import zendesk.chat.ChatRating;
import zendesk.chat.ChatState;
import zendesk.chat.ConnectionStatus;
import zendesk.chat.ObservationScope;
import zendesk.chat.Observer;
import zendesk.chat.OfflineForm;
import zendesk.chat.ProfileProvider;
import zendesk.chat.VisitorInfo;

import static com.google.gson.FieldNamingPolicy.LOWER_CASE_WITH_UNDERSCORES;

/** FlutterZendeskChatPlugin */
public class FlutterZendeskChatPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private EventChannel connectionStatusEventsChannel;
  private EventChannel accountStatusEventsChannel;
  private EventChannel agentEventsChannel;
  private EventChannel chatItemsEventsChannel;
  private Handler mainHandler = new Handler(Looper.getMainLooper());
  private Activity activity;

  private FlutterZendeskChatPlugin() {
  }

  private ObservationScope connectionScope = null;
  private ObservationScope accountScope = null;
  private ObservationScope chatScope = null;
  private FlutterZendeskChatPlugin.EventChannelStreamHandler connectionStreamHandler = new FlutterZendeskChatPlugin.EventChannelStreamHandler();
  private FlutterZendeskChatPlugin.EventChannelStreamHandler accountStreamHandler = new FlutterZendeskChatPlugin.EventChannelStreamHandler();
  private FlutterZendeskChatPlugin.EventChannelStreamHandler agentsStreamHandler = new FlutterZendeskChatPlugin.EventChannelStreamHandler();
  private FlutterZendeskChatPlugin.EventChannelStreamHandler chatItemsStreamHandler = new FlutterZendeskChatPlugin.EventChannelStreamHandler();

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_zendesk_chat");
    connectionStatusEventsChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_zendesk_chat/connection_status_events");
    accountStatusEventsChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(),"flutter_zendesk_chat/account_status_events");
    agentEventsChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(),"flutter_zendesk_chat/agent_events");
    chatItemsEventsChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(),"flutter_zendesk_chat/chat_items_events");
    connectionStatusEventsChannel.setStreamHandler(this.connectionStreamHandler);
    accountStatusEventsChannel.setStreamHandler(this.accountStreamHandler);
    agentEventsChannel.setStreamHandler(this.agentsStreamHandler);
    chatItemsEventsChannel.setStreamHandler(this.chatItemsStreamHandler);
    channel.setMethodCallHandler(this);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_zendesk_chat");

    final EventChannel connectionStatusEventsChannel = new EventChannel(registrar.messenger(), "flutter_zendesk_chat/connection_status_events");
    final EventChannel accountStatusEventsChannel = new EventChannel(registrar.messenger(),"flutter_zendesk_chat/account_status_events");
    final EventChannel agentEventsChannel = new EventChannel(registrar.messenger(),"flutter_zendesk_chat/agent_events");
    final EventChannel chatItemsEventsChannel = new EventChannel(registrar.messenger(),"flutter_zendesk_chat/chat_items_events");

    FlutterZendeskChatPlugin plugin = new FlutterZendeskChatPlugin();

    channel.setMethodCallHandler(plugin);

    connectionStatusEventsChannel.setStreamHandler(plugin.connectionStreamHandler);
    accountStatusEventsChannel.setStreamHandler(plugin.accountStreamHandler);
    agentEventsChannel.setStreamHandler(plugin.agentsStreamHandler);
    chatItemsEventsChannel.setStreamHandler(plugin.chatItemsStreamHandler);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch(call.method) {
      case "start":
        final String accountKey = call.argument("accountKey");

        try {
          Chat.INSTANCE.init(activity, accountKey);

          ProfileProvider profileProvider = Chat.INSTANCE.providers().profileProvider();
          ChatProvider chatProvider = Chat.INSTANCE.providers().chatProvider();

          VisitorInfo visitorInfo = VisitorInfo.builder()
                  .withPhoneNumber((String)call.argument("phoneNumber"))
                  .withEmail((String)call.argument("email"))
                  .withName((String)call.argument("name"))
                  .build();

          profileProvider.setVisitorInfo(visitorInfo, null);

          String department = call.argument("department");
          List<String> tags = call.argument("tags");

          if (!TextUtils.isEmpty(department)) {
            chatProvider.setDepartment(department, null);
          }
          if (tags != null && tags.size() > 0) {
            profileProvider.addVisitorTags(tags, null);
          }

          bindChatListeners();

          Chat.INSTANCE.providers().connectionProvider().connect();

          result.success(null);
        } catch (Exception e) {
          result.error("UNABLE_TO_INITIALIZE_CHAT_API", e.getMessage(), e);
          break;
        }
        break;
      case "endChat":
        unbindChatListeners();
        Chat.INSTANCE.providers().chatProvider().endChat(null);
        result.success(null);
        break;
      case "sendMessage":
        if (Chat.INSTANCE.providers().connectionProvider().getConnectionStatus() != ConnectionStatus.CONNECTED) {
          result.error("CHAT_NOT_STARTED", null, null);
        } else {
          String message = call.argument("message");
          Chat.INSTANCE.providers().chatProvider().sendMessage(message);
          result.success(null);
        }
        break;
      case "resendMessage":
        if (Chat.INSTANCE.providers().connectionProvider().getConnectionStatus() != ConnectionStatus.CONNECTED) {
          result.error("CHAT_NOT_STARTED", null, null);
        } else {
          String messageId = call.argument("messageId");
          Chat.INSTANCE.providers().chatProvider().resendFailedMessage(messageId);
          result.success(null);
        }
        break;
      case "sendComment":
        if (Chat.INSTANCE.providers().connectionProvider().getConnectionStatus() != ConnectionStatus.CONNECTED) {
          result.error("CHAT_NOT_STARTED", null, null);
        } else {
          String comment = call.argument("comment");
          Chat.INSTANCE.providers().chatProvider().sendChatComment(comment, null);
          result.success(null);
        }
        break;
      case "sendAttachment":
        if (Chat.INSTANCE.providers().connectionProvider().getConnectionStatus() != ConnectionStatus.CONNECTED) {
          result.error("CHAT_NOT_STARTED", null, null);
        } else {
          String pathname = call.argument("pathname");
          if (TextUtils.isEmpty(pathname)) {
            result.error("ATTACHMENT_EMPTY_PATHNAME", null, null);
            return;
          }
          File file = new File(pathname);
          if (!file.isFile()) {
            result.error("ATTACHMENT_NOT_FILE", null, null);
            return;
          }
          Chat.INSTANCE.providers().chatProvider().sendFile(file, null);
          result.success(null);
        }
        break;
      case "sendChatRating": {
        if (Chat.INSTANCE.providers().connectionProvider().getConnectionStatus() != ConnectionStatus.CONNECTED) {
          result.error("CHAT_NOT_STARTED", null, null);
          return;
        }
        ChatRating chatLogRating = null;
        ChatProvider provider = Chat.INSTANCE.providers().chatProvider();
        String rating = call.argument("rating");
        if (!TextUtils.isEmpty(rating)) {
          chatLogRating = toChatLogRating(rating);
        }

        if (chatLogRating != null) {
          provider.sendChatRating(chatLogRating, null);
        }

        String comment = call.argument("comment");
        if (!TextUtils.isEmpty(comment)) {
          provider.sendChatComment(comment, null);
        }
        result.success(null);
        break;
      }
      case "sendOfflineMessage":
        if (Chat.INSTANCE.providers().connectionProvider().getConnectionStatus() != ConnectionStatus.CONNECTED) {
          result.error("CHAT_NOT_STARTED", null, null);
          return;
        }
        VisitorInfo info = Chat.INSTANCE.providers().profileProvider().getVisitorInfo();
        if (TextUtils.isEmpty(info.getEmail())) {
          result.error("VISITOR_EMAIL_MUST_BE PROVIDED", null, null);
          return;
        }

        Chat.INSTANCE.providers().chatProvider().sendOfflineForm(OfflineForm.builder((String)call.argument("message")).withVisitorInfo(info).build(), null);

        result.success(null);

        break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  private void bindChatListeners() {
    unbindChatListeners();

    connectionScope = new ObservationScope();
    Chat.INSTANCE.providers().connectionProvider().observeConnectionStatus(connectionScope, new Observer<ConnectionStatus>() {
      @Override
      public void update(final ConnectionStatus status) {
        mainHandler.post(new Runnable() {
          @Override
          public void run() {
            connectionStreamHandler.success(status.name());
          }
        });
      }
    });

    accountScope = new ObservationScope();
    Chat.INSTANCE.providers().accountProvider().observeAccount(accountScope, new Observer<Account>() {
      @Override
      public void update(final Account account) {
        mainHandler.post(new Runnable() {
          @Override
          public void run() {
            accountStreamHandler.success(account.getStatus().name());
          }
        });
      }
    });

    chatScope = new ObservationScope();
    Chat.INSTANCE.providers().chatProvider().observeChatState(chatScope, new Observer<ChatState>() {
      @Override
      public void update(ChatState chatState) {
        final List<ChatAgent> agents = new ArrayList<>();

        for (Agent agent: chatState.getAgents()) {
          agents.add(ChatAgent.fromAgent(agent));
        }

        mainHandler.post(new Runnable() {
          @Override
          public void run() {
            agentsStreamHandler.success(toJson(agents));
          }
        });

        final List<ChatLogEvent> chatLogs = new ArrayList<>();

        for (ChatLog chatLog: chatState.getChatLogs()) {
          chatLogs.add(ChatLogEvent.fromChatLog(chatLog));
        }

        mainHandler.post(new Runnable() {
          @Override
          public void run() {
            chatItemsStreamHandler.success(toJson(chatLogs));
          }
        });
      }
    });
  }

  private void unbindChatListeners() {
    if (connectionScope != null && !connectionScope.isCancelled()) {
      connectionScope.cancel();
      connectionScope = null;
    }
    if (chatScope != null && !chatScope.isCancelled()) {
      chatScope.cancel();
      chatScope = null;
    }
    if (accountScope != null && !accountScope.isCancelled()) {
      accountScope.cancel();
      accountScope = null;
    }
  }

  private String toJson(Object object) {
    return new GsonBuilder()
            .setFieldNamingPolicy(LOWER_CASE_WITH_UNDERSCORES)
            .create()
            .toJson(object)
            .replaceAll("\\$(string|int|bool)\":", "\":");
  }

  private ChatRating toChatLogRating(String rating) {
    switch (rating) {
      case "ChatRating.GOOD":
        return ChatRating.GOOD;
      case "ChatRating.BAD":
        return ChatRating.BAD;
      default:
        return null;
    }
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    this.activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    this.activity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    this.activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivity() {
    this.activity = null;
  }

  private static class EventChannelStreamHandler implements EventChannel.StreamHandler {
    private EventChannel.EventSink eventSink = null;

    public void success(Object event) {
      if (eventSink != null) {
        eventSink.success(event);
      }
    }

    public void error(String errorCode, String errorMessage, Object errorDetails) {
      if (eventSink != null) {
        eventSink.error(errorCode, errorMessage, errorDetails);
      }
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
      this.eventSink = eventSink;
    }

    @Override
    public void onCancel(Object o) {
      this.eventSink = null;
    }
  }
}
