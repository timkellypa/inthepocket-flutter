import 'package:flutter/services.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:wave_builder/wave_builder.dart';

const int DEFAULT_TEMPO_FILE_LENGTH_MINUTES = 3;

class MetronomeWriter extends WaveBuilder {
  List<int>? _primaryBytes;
  List<int>? _secondaryBytes;

  Future<List<int>> get primaryBytes async {
    _primaryBytes ??= getDataChunk(
        (await rootBundle.load('sounds/primary.wav')).buffer.asUint8List());
    return _primaryBytes!;
  }

  Future<List<int>> get secondaryBytes async {
    _secondaryBytes ??= getDataChunk(
        (await rootBundle.load('sounds/secondary.wav')).buffer.asUint8List());
    return _secondaryBytes!;
  }

  Future<void> addTempo(Tempo tempo) async {
    final int tempoNumBars = tempo.numberOfBars!.ceil();
    final int numberOfBars = tempoNumBars == 0
        ? tempo.bpm! * DEFAULT_TEMPO_FILE_LENGTH_MINUTES ~/ tempo.beatsPerBar!
        : tempoNumBars;
    for (int bar = 0; bar < numberOfBars; ++bar) {
      for (int beat = 1; beat <= tempo.beatsPerBar!; ++beat) {
        // check to see if we are using primary or secondary
        if ((beat - 1) % (tempo.beatsPerBar! / tempo.accentBeatsPerBar!) == 0) {
          appendFileContents(await primaryBytes, findDataChunk: false);
        } else {
          appendFileContents(await secondaryBytes, findDataChunk: false);
        }
        appendSilence(
            60000 ~/ tempo.bpm!, WaveBuilderSilenceType.BeginningOfLastSample);
      }
    }
  }
}
