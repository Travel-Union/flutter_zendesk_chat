import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_zendesk_chat/models/main.dart';

class Agent extends MainModel {
  Agent(Map attributes, [@visibleForTesting String os])
      : super(attributes, os);

  String get displayName => attribute('display_name');

  String get nick => attribute('nick');

  bool get isTyping => attribute('is_typing');

  String get avatarUri => attribute('avatar_path');

  static List<Agent> parseJson(String json,
      [@visibleForTesting String os]) {
    var out = List<Agent>();
    jsonDecode(json).forEach((value) {
      out.add(Agent(value, os));
    });
    return out;
  }
}