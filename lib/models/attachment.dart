import 'package:flutter/material.dart';
import 'package:flutter_zendesk_chat/models/main.dart';

class Attachment extends MainModel {
  Attachment(Map attributes, [@visibleForTesting String? os])
      : super(attributes as Map<String, dynamic>, os);

  String? get mimeType {
    return attribute('mime_type');
  }

  String? get name {
    return attribute('name');
  }

  int? get size {
    return attribute('size');
  }

  String? get type {
    return attribute('type');
  }

  String? get url {
    return attribute('url');
  }

  String? get thumbnailUrl {
    return attribute('thumbnail') ?? attribute('thumbnail_url');
  }
}