import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/services.dart';
import 'package:in_the_pocket/classes/click_info.dart';
import 'package:soundpool/soundpool.dart';

/// Plays a metronome click when appropriate by listening to the click state stream.
/// This is only for standalone metronome implementations, because the track player
/// uses a dedicated .wav file generated for each track,
/// to allow for media controls and reduce possibilities of latency.
class MetronomeClickPlayer {
  MetronomeClickPlayer({required this.clickStateStream});

  static Future<void> setup() async {
    final ByteData primaryAsset = await rootBundle.load('sounds/primary.wav');
    final ByteData secondaryAsset =
        await rootBundle.load('sounds/secondary.wav');
    primarySoundId = await soundpool.load(primaryAsset);
    secondarySoundId = await soundpool.load(secondaryAsset);

    // also setup audio session to allow soundpool to play sound.
    final AudioSession session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
    ));
    await session.setActive(true);
  }

  // Use high maxStreams to allow for quick successive clicks without skipping.
  // Use notification stream type to allow sound to play with the least latency.
  static Soundpool soundpool = Soundpool.fromOptions(
      options: const SoundpoolOptions(
          maxStreams: 15, streamType: StreamType.notification));

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
