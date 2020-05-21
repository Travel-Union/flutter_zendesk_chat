import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class MainModel {
  final Map<String, dynamic> _attributes;
  final String _os;

  MainModel(this._attributes, [@visibleForTesting this._os]);

  dynamic attribute(String attrname) {
    return _attributes != null ? _attributes[attrname] : null;
  }

  @visibleForTesting
  String os() {
    return this._os ?? Platform.operatingSystem;
  }

  String toString() => JsonEncoder().convert(_attributes);
}