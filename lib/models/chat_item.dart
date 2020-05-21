import 'package:flutter_zendesk_chat/enums/chat_item_type.dart';
import 'package:flutter_zendesk_chat/enums/chat_participant.dart';
import 'package:flutter_zendesk_chat/enums/chat_rating.dart';
import 'package:flutter_zendesk_chat/enums/delivery_status.dart';
import 'package:flutter_zendesk_chat/helpers/enum.dart';
import 'package:flutter_zendesk_chat/models/attachment.dart';
import 'package:flutter_zendesk_chat/models/main.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

class ChatItem extends MainModel {
  ChatItem(Map attributes, [@visibleForTesting String os])
      : super(attributes, os);

  String get id => attribute('id');

  DateTime get createTimestamp =>
      DateTime.fromMillisecondsSinceEpoch(attribute('create_timestamp'),
          isUtc: false);

  DateTime get modifyTimestamp =>
      DateTime.fromMillisecondsSinceEpoch(attribute('modify_timestamp'),
          isUtc: false);

  ChatItemType get type => EnumHelper.asChatItemType(attribute('type'));

  DeliveryStatus get deliveryStatus => EnumHelper.asDeliveryStatus(attribute('delivery_status'));

  String get displayName => attribute('display_name');

  String get nick => attribute('nick');

  ChatParticipant get participant => EnumHelper.asChatParticipant(attribute('participant'));

  String get message => attribute('message');

  Attachment get attachment {
    dynamic raw = attribute('attachment');
    return (raw != null && raw is Map) ? Attachment(raw) : null;
  }

  int get uploadProgress => attribute('upload_progress');

  ChatRating get rating => EnumHelper.asChatRating(attribute('previous_rating'));

  ChatRating get newRating => EnumHelper.asChatRating(attribute('current_rating'));

  String get previousComment => attribute('previous_comment');

  String get newComment => attribute('current_comment');

  static List<ChatItem> parseJson(String json,
      [@visibleForTesting String os]) {
    var out = List<ChatItem>();
    jsonDecode(json).forEach((value) {
      out.add(ChatItem(value, os));
    });
    return out;
  }
}