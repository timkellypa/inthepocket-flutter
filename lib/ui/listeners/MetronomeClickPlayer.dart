import 'dart:async';

import 'package:flutter/services.dart';
import 'package:in_the_pocket/classes/click_info.dart';
import 'package:soundpool/soundpool.dart';

/// Plays a metronome click when appropriate by listening to the click state stream.
/// This is only for standalone metronome implementations, because the track player
/// uses a dedicated .wav file generated for each track,
/// to allow for media controls and reduce possibilities of latency.
class MetronomeClickPlayer {
  MetronomeClickPlayer({required this.clickStateStream}) {
    Future<void>.microtask(() async {
      if (primarySoundId != null && secondarySoundId != null) {
        return;
      }
      final ByteData primaryAsset = await rootBundle.load('sounds/primary.wav');
      final ByteData secondaryAsset =
          await rootBundle.load('sounds/secondary.wav');
      primarySoundId = await soundpool.load(primaryAsset);
      secondarySoundId = await soundpool.load(secondaryAsset);
    });
  }

  static Soundpool soundpool =
      Soundpool.fromOptions(options: const SoundpoolOptions(maxStreams: 15));

  Stream<ClickState> clickStateStream;

  StreamSubscription<ClickState>? clickSubscription;

  static int? primarySoundId;
  static int? secondarySoundId;

  ClickState? previousState;

  void listen() {
    clickSubscription = clickStateStream.listen((ClickState clickState) {
      if (clickState.isClicking() && !(previousState?.isClicking() ?? false)) {
        if (clickState.accent && primarySoundId != null) {
          soundpool.play(primarySoundId!);
        } else if (secondarySoundId != null) {
          soundpool.play(secondarySoundId!);
        }
      }
      previousState = clickState;
    });
  }

  void stopListening() {
    clickSubscription?.cancel();
  }

  void dispose() {
    stopListening();
    clickSubscription?.cancel();
  }
}
