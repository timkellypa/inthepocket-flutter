import 'dart:async' show Future;
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;
import 'package:in_the_pocket/classes/secret.dart';

class SecretLoader {
  SecretLoader({this.secretPath});
  final String secretPath;

  Future<Secret> load() {
    return rootBundle.loadStructuredData<Secret>(secretPath,
        (String jsonStr) async {
      final Secret secret = Secret.fromJson(json.decode(jsonStr));
      return secret;
    });
  }
}
