import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:in_the_pocket/classes/secret.dart';
import 'package:in_the_pocket/classes/secret_loader.dart';
import 'package:in_the_pocket/model/spotify_playlist.dart';
import 'package:in_the_pocket/model/spotify_track.dart';
import 'package:in_the_pocket/oauth/authorization_code_grant_helper.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class SpotifyProvider {
  Uri get authorizationEndpoint =>
      Uri.parse('https://accounts.spotify.com/authorize');
  Uri get tokenEndpoint => Uri.parse('https://accounts.spotify.com/api/token');

  Future<oauth2.Client> login() async {
    final Secret secret =
        await SecretLoader(secretPath: 'api_secrets.json').load();
    final String localPath = (await getApplicationDocumentsDirectory()).path;

    return await AuthorizationCodeGrantHelper.getClient(secret.spotifyClientId,
        secret.spotifyClientSecret, authorizationEndpoint, tokenEndpoint,
        credentialsFile:
            File('/$localPath/credentials/spotify-credentials.json'));
  }

  Future<oauth2.Client> reLogin() async {
    final String localPath = (await getApplicationDocumentsDirectory()).path;
    final File credentialsFile =
        File('/$localPath/credentials/spotify-credentials.json');

    await credentialsFile.delete();
    return await login();
  }

  /// Wrapper for client.read.
  /// Logs in and tries to read URI.
  /// On authorization exception, releases credentilas file
  /// and calls "login" again.
  Future<String> read(Uri uri) async {
    final oauth2.Client client = await login();
    String result;

    try {
      result = await client.read(uri);
    } on oauth2.AuthorizationException {
      await reLogin();
      result = await client.read(uri);
    }
    return result;
  }

  Future<List<SpotifyPlaylist>> getUserPlaylistsAll() async {
    final List<SpotifyPlaylist> ret = <SpotifyPlaylist>[];
    int index = 0;

    final String result =
        await read(Uri.https('api.spotify.com', '/v1/me/playlists'));

    final List<dynamic> items = json.decode(result)['items'];

    for (Map<String, dynamic> item in items) {
      final SpotifyPlaylist list = SpotifyPlaylist();
      list.spotifyId = item['id'] ?? const Uuid().v4();
      list.id = list.spotifyId;
      list.sortOrder = index;
      list.spotifyTitle = item['name'];
      ret.add(list);
      index++;
    }
    return ret;
  }

  Future<List<SpotifyTrack>> getPlaylistTracksAll(SpotifyPlaylist playlist,
      {bool cascade = false}) async {
    final List<SpotifyTrack> ret = <SpotifyTrack>[];
    int index = 0;

    final String result = await read(Uri.https(
        'api.spotify.com', '/v1/playlists/${playlist.spotifyId}/tracks'));

    final List<dynamic> items = json.decode(result)['items'];

    for (Map<String, dynamic> item in items) {
      String audioFeatures = '';
      if (cascade) {
        audioFeatures = await getAudioFeaturesJSON(item['track']['id']);
      }

      final String id = item['track']['id'] ?? const Uuid().v4();

      final SpotifyTrack track = SpotifyTrack()
        ..id = id
        ..sortOrder = index
        ..spotifyTitle = item['track']['name']
        ..spotifyId = id
        ..spotifyAudioFeatures = audioFeatures;

      ret.add(track);
      index++;
    }
    return ret;
  }

  Future<String> getAudioFeaturesJSON(String trackId) async {
    String result;

    try {
      result = await read(
          Uri.https('api.spotify.com', '/v1/audio-features/$trackId'));
    } on ClientException {
      result = jsonEncode(<String, String>{});
    }

    return result;
  }
}
