import 'dart:io';

import 'package:in_the_pocket/utilities/temp_server.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:url_launcher/url_launcher_string.dart';

// ignore: avoid_classes_with_only_static_members
class AuthorizationCodeGrantHelper {
  static late TempServer server;

  /// Either load an OAuth2 client from saved credentials or authenticate a new
  /// one.
  static Future<oauth2.Client> getClient(String clientId, String secret,
      Uri authorizationEndpoint, Uri tokenEndpoint,
      {required File credentialsFile}) async {
    final bool exists = credentialsFile.existsSync();

    // If the OAuth2 credentials have already been saved from a previous run, we
    // just want to reload them.
    if (exists) {
      final oauth2.Credentials credentials =
          oauth2.Credentials.fromJson(await credentialsFile.readAsString());
      return oauth2.Client(credentials, identifier: clientId, secret: secret);
    }

    // If we don't have OAuth2 credentials yet, we need to get the resource owner
    // to authorize us. We're assuming here that we're a command-line application.
    final oauth2.AuthorizationCodeGrant grant = oauth2.AuthorizationCodeGrant(
        clientId, authorizationEndpoint, tokenEndpoint,
        secret: secret);

    server = TempServer(port: '8080');

    final Stream<Map<String, String>> onparams =
        await server.queryParamListener();

    // Redirect the resource owner to the authorization URL. This will be a URL on
    // the authorization server (authorizationEndpoint with some additional query
    // parameters). Once the resource owner has authorized, they'll be redirected
    // to `redirectUrl` with an authorization code.
    //
    // `redirect` is an imaginary function that redirects the resource
    // owner's browser.
    await redirect(grant.getAuthorizationUrl(server.uri));

    final Map<String, String> queryParams = await onparams.first;

    url_launcher.closeInAppWebView();

    // Once the user is redirected to `redirectUrl`, pass the query parameters to
    // the AuthorizationCodeGrant. It will validate them and extract the
    // authorization code to create a new Client.
    final oauth2.Client client =
        await grant.handleAuthorizationResponse(queryParams);

    credentialsFile.createSync(recursive: true);
    credentialsFile.writeAsStringSync(client.credentials.toJson());

    return client;
  }

  static Future<void> redirect(Uri uri) async {
    if (await url_launcher.canLaunchUrl(uri)) {
      await url_launcher.launchUrl(uri,
          webViewConfiguration: const WebViewConfiguration(
              enableJavaScript: true, enableDomStorage: true),
          webOnlyWindowName: '_blank');
    } else {
      throw 'could not launch $uri';
    }
  }
}
