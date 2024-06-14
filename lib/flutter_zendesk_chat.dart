import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_zendesk_chat/enums/account_status.dart';
import 'package:flutter_zendesk_chat/enums/chat_rating.dart';
import 'package:flutter_zendesk_chat/enums/connection_status.dart';
import 'package:flutter_zendesk_chat/models/agent.dart';
import 'package:flutter_zendesk_chat/models/chat_item.dart';
import 'package:flutter_zendesk_chat/helpers/enum.dart';

class FlutterZendeskChat {
  static FlutterZendeskChat? _instance;

  static const MethodChannel _channel =
      const MethodChannel('flutter_zendesk_chat');
  static const EventChannel _connectionStatusEventsChannel =
      EventChannel('flutter_zendesk_chat/connection_status_events');
  static const EventChannel _accountStatusEventsChannel =
      EventChannel('flutter_zendesk_chat/account_status_events');
  static const EventChannel _agentEventsChannel =
      EventChannel('flutter_zendesk_chat/agent_events');
  static const EventChannel _chatItemsEventsChannel =
      EventChannel('flutter_zendesk_chat/chat_items_events');

  Stream<ConnectionStatus>? _connectionStatusEventsStream;
  Stream<AccountStatus>? _accountStatusEventsStream;
  Stream<List<Agent>>? _agentEventsStream;
  Stream<List<ChatItem>>? _chatItemsEventsStream;

  factory FlutterZendeskChat() {
    if (_instance == null) {
      _instance = FlutterZendeskChat._();
    }
    return _instance!;
  }

  FlutterZendeskChat._();

  Future<bool?> startChat(String visitorName,
      {String? accountKey,
      String? appId,
      String? visitorEmail,
      String? visitorPhone,
      String? department,
      String? pushToken,
      List<String>? tags}) async {
    return await _channel.invokeMethod('start', <String, dynamic>{
      'accountKey': accountKey,
      'appId': appId,
      'name': visitorName,
      'email': visitorEmail,
      'phoneNumber': visitorPhone,
      'department': department,
      'pushToken': pushToken,
      'tags': tags,
    });
  }

  Future<void> endChat() async {
    return await _channel.invokeMethod('endChat');
  }

  Future<void> sendMessage(String message) async {
    return await _channel
        .invokeMethod('sendMessage', <String, dynamic>{'message': message});
  }

  Future<void> resendMessage(String messageId) async {
    return await _channel.invokeMethod(
        'resendMessage', <String, dynamic>{'messageId': messageId});
  }

  Future<void> resendFailedAttachment(String messageId) async {
    return await _channel.invokeMethod(
        'resendFailedAttachment', <String, dynamic>{'messageId': messageId});
  }

  Future<void> sendComment(String comment) async {
    return await _channel
        .invokeMethod('sendComment', <String, dynamic>{'comment': comment});
  }

  Future<bool> sendAttachment(String pathname) async {
    return await _channel.invokeMethod('sendAttachment', <String, dynamic>{
      'pathname': pathname,
    });
  }

  Future<void> sendChatRating(ChatRating chatRating, {String? comment}) async {
    return await _channel.invokeMethod('sendChatRating',
        <String, dynamic>{'rating': chatRating.toString(), 'comment': comment});
  }

  Future<bool?> sendOfflineMessage(String message) async {
    return await _channel.invokeMethod(
        'sendOfflineMessage', <String, dynamic>{'message': message});
  }

  Stream<ConnectionStatus>? get onConnectionStatusChanged {
    if (_connectionStatusEventsStream == null) {
      _connectionStatusEventsStream = _connectionStatusEventsChannel
          .receiveBroadcastStream()
          .map((dynamic event) => EnumHelper.asConnectionStatus(event));
    }
    return _connectionStatusEventsStream;
  }

  Stream<AccountStatus>? get onAccountStatusChanged {
    if (_accountStatusEventsStream == null) {
      _accountStatusEventsStream = _accountStatusEventsChannel
          .receiveBroadcastStream()
          .map((dynamic event) => EnumHelper.asAccountStatus(event));
    }
    return _accountStatusEventsStream;
  }

  Stream<List<Agent>>? get onAgentsChanged {
    if (_agentEventsStream == null) {
      _agentEventsStream = _agentEventsChannel
          .receiveBroadcastStream()
          .map((dynamic event) => Agent.parseJson(event));
    }
    return _agentEventsStream;
  }

  Stream<List<ChatItem>>? get onChatItemsChanged {
    if (_chatItemsEventsStream == null) {
      _chatItemsEventsStream = _chatItemsEventsChannel
          .receiveBroadcastStream()
          .map((dynamic event) => ChatItem.parseJson(event));
    }
    return _chatItemsEventsStream;
  }
}
