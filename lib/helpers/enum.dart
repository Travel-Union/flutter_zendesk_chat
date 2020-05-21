import 'package:flutter_zendesk_chat/enums/account_status.dart';
import 'package:flutter_zendesk_chat/enums/chat_item_type.dart';
import 'package:flutter_zendesk_chat/enums/chat_participant.dart';
import 'package:flutter_zendesk_chat/enums/chat_rating.dart';
import 'package:flutter_zendesk_chat/enums/connection_status.dart';
import 'package:flutter_zendesk_chat/enums/delivery_status.dart';

class EnumHelper {
  static ConnectionStatus asConnectionStatus(String val) {
    switch (val) {
      case 'UNREACHABLE':
        return ConnectionStatus.UNREACHABLE;
      case 'RECONNECTING':
        return ConnectionStatus.RECONNECTING;
      case 'DISCONNECTED':
        return ConnectionStatus.DISCONNECTED;
      case 'CONNECTING':
        return ConnectionStatus.CONNECTING;
      case 'CONNECTED':
        return ConnectionStatus.CONNECTED;
      case 'FAILED':
        return ConnectionStatus.FAILED;
      default:
        return ConnectionStatus.UNKNOWN;
    }
  }

  static AccountStatus asAccountStatus(String val) {
    switch (val) {
      case 'ONLINE':
        return AccountStatus.ONLINE;
      case 'OFFLINE':
        return AccountStatus.OFFLINE;
      default:
        return AccountStatus.UNKNOWN;
    }
  }

  static ChatItemType asChatItemType(String val) {
    switch (val) {
      case 'MEMBER_JOIN':
        return ChatItemType.MEMBER_JOIN;
      case 'MEMBER_LEAVE':
        return ChatItemType.MEMBER_LEAVE;
      case 'MESSAGE':
        return ChatItemType.MESSAGE;
      case 'RATING_REQUEST':
        return ChatItemType.RATING_REQUEST;
      case 'RATING':
        return ChatItemType.RATING;
      case 'COMMENT':
        return ChatItemType.COMMENT;
      case 'ATTACHMENT_MESSAGE':
        return ChatItemType.ATTACHMENT_MESSAGE;
      default:
        return ChatItemType.UNKNOWN;
    }
  }

  static DeliveryStatus asDeliveryStatus(String val) {
    switch (val) {
      case 'CANCELLED':
        return DeliveryStatus.CANCELLED;
      case 'DELIVERED':
        return DeliveryStatus.DELIVERED;
      case 'FAILED_FILE_SENDING_DISABLED':
        return DeliveryStatus.FAILED_FILE_SENDING_DISABLED;
      case 'FAILED_FILE_SIZE_TOO_LARGE':
        return DeliveryStatus.FAILED_FILE_SIZE_TOO_LARGE;
      case 'FAILED_INTERNAL_SERVER_ERROR':
        return DeliveryStatus.FAILED_INTERNAL_SERVER_ERROR;
      case 'FAILED_RESPONSE_TIMEOUT':
        return DeliveryStatus.FAILED_RESPONSE_TIMEOUT;
      case 'FAILED_UNKNOWN_REASON':
        return DeliveryStatus.FAILED_UNKNOWN_REASON;
      case 'FAILED_UNSUPPORTED_FILE_TYPE':
        return DeliveryStatus.FAILED_UNSUPPORTED_FILE_TYPE;
      case 'PENDING':
        return DeliveryStatus.PENDING;
      default:
        return DeliveryStatus.UNKNOWN;
    }
  }

  static ChatParticipant asChatParticipant(String val) {
    switch (val) {
      case 'VISITOR':
        return ChatParticipant.VISITOR;
      case 'AGENT':
        return ChatParticipant.AGENT;
      case 'TRIGGER':
        return ChatParticipant.TRIGGER;
      case 'SYSTEM':
        return ChatParticipant.SYSTEM;
      default:
        return ChatParticipant.UNKNOWN;
    }
  }

  static ChatRating asChatRating(String val) {
    switch (val) {
      case 'GOOD':
        return ChatRating.GOOD;
      case 'BAD':
        return ChatRating.BAD;
      default:
        return ChatRating.UNKNOWN;
    }
  }
}