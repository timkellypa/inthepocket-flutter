import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:in_the_pocket/classes/secret.dart';
import 'package:in_the_pocket/classes/secret_loader.dart';
import 'package:in_the_pocket/model/setlistdb.dart';

class BpmInfo {
  BpmInfo({
    required this.bpm,
    required this.beatsPerBar,
    required this.beatUnit,
  });

  final double bpm;
  final int beatsPerBar;
  final int beatUnit;
}

/// This class is responsible for fetching BPM information for tracks.
/// The BPM information is fetched based on the song title and artist.
class GetSongBpmProvider {
  Future<Tempo?> getSongTempo(Track track) async {
    final Tempo tempo = Tempo();

    final BpmInfo? info = await getSongBpm(track);
    if (info == null) {
      return null;
    }

    tempo.accentBeatsPerBar = info.beatsPerBar == 4 ? 1 : 2;
    tempo.beatsPerBar = info.beatsPerBar;
    tempo.beatUnit = info.beatUnit;
    tempo.bpm = info.bpm;
    tempo.dottedQuarterAccent = false;
    tempo.numberOfBars = 0;
    tempo.trackId = track.id;

    // Assign an ID here, to ensure it's not null when saved.
    tempo.init();

    return tempo;
  }

  Future<String> get apiKey async {
    final Secret secret =
        await SecretLoader(secretPath: 'api_secrets.json').load();
    return secret.getSongBpmApiKey;
  }

  Future<BpmInfo?> getSongBpm(Track track) async {
    final String? songId = await getSongId(track);

    if (songId == null) {
      return null;
    }

    final Map<String, String> queryParameters = <String, String>{
      'api_key': await apiKey,
      'id': songId
    };

    final http.Response apiReturn =
        await http.get(Uri.https('api.getsong.co', '/song/', queryParameters));

    if (apiReturn.statusCode == 200) {
      final Map<String, dynamic> responseJson = jsonDecode(apiReturn.body);
      final double? bpm = responseJson['song']?['tempo'] != null
          ? double.parse(responseJson['song']?['tempo'])
          : null;

      if (bpm == null) {
        print('BPM is null, no BPM information found for this track.');
        return null;
      }

      // parse beats per bar and beat unit from time signature
      final String timeSignature = responseJson['song']?['time_sig'] ?? '4/4';
      final int beatsPerBar = int.parse(timeSignature.split('/')[0]);
      final int beatUnit = int.parse(timeSignature.split('/')[1]);

      print('BPM: $bpm, Beats per Bar: $beatsPerBar, Beat Unit: $beatUnit');

      return BpmInfo(
        bpm: bpm,
        beatsPerBar: beatsPerBar,
        beatUnit: beatUnit,
      );
    } else {
      return null;
    }
  }

  Future<String?> getSongId(Track track) async {
    final Map<String, String> queryParameters = <String, String>{
      'api_key': await apiKey,
      'type': 'both',
      'lookup': 'song:${track.title}artist:${track.artist}',
    };

    final http.Response apiReturn = await http
        .get(Uri.https('api.getsong.co', '/search/', queryParameters));

    if (apiReturn.statusCode == 200) {
      final Map<String, dynamic> responseJson = jsonDecode(apiReturn.body);
      final String? songId = responseJson['search']?[0]?['id'];
      return songId;
    } else {
      return null;
    }
  }
}
