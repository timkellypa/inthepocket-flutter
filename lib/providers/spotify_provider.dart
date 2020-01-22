import 'dart:convert';
import 'dart:io';

import 'package:in_the_pocket/classes/secret.dart';
import 'package:in_the_pocket/classes/secret_loader.dart';
import 'package:in_the_pocket/models/independent/spotify_playlist.dart';
import 'package:in_the_pocket/models/independent/spotify_track.dart';
import 'package:in_the_pocket/oauth/authorization_code_grant_helper.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:path_provider/path_provider.dart';

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

  Future<List<SpotifyPlaylist>> getUserPlaylistsAll() async {
    final List<SpotifyPlaylist> ret = <SpotifyPlaylist>[];
    int index = 0;

    final oauth2.Client client = await login();

    final String result =
        await client.read('https://api.spotify.com/v1/me/playlists');

    final List<dynamic> items = json.decode(result)['items'];

    for (Map<String, dynamic> item in items) {
      final SpotifyPlaylist list = SpotifyPlaylist();
      list.spotifyId = item['id'];
      list.guid = item['id'];
      list.id = index;
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

    final oauth2.Client client = await login();

    final String result = await client.read(
        'https://api.spotify.com/v1/playlists/${playlist.spotifyId}/tracks');

    final List<dynamic> items = json.decode(result)['items'];

    for (Map<String, dynamic> item in items) {
      String audioFeatures = '';
      if (cascade) {
        audioFeatures = await getAudioFeaturesJSON(item['track']['id']);
      }

      final SpotifyTrack track = SpotifyTrack()
        ..id = index
        ..sortOrder = index
        ..spotifyTitle = item['track']['name']
        ..spotifyId = item['track']['id']
        ..guid = item['track']['id']
        ..spotifyAudioFeatures = audioFeatures;

      ret.add(track);
      index++;
    }
    return ret;
  }

  Future<String> getAudioFeaturesJSON(String trackId,
      {oauth2.Client client}) async {
    client ??= await login();

    final String result =
        await client.read('https://api.spotify.com/v1/audio-features/$trackId');

    return result;
  }
}
