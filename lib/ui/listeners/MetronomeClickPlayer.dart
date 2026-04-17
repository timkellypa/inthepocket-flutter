import 'dart:async';

import 'package:in_the_pocket/classes/click_info.dart';
import 'package:just_audio/just_audio.dart';

/// Plays a metronome click when appropriate by listening to the click state stream.
/// This is only for standalone metronome implementations, because the track player
/// uses a dedicated .wav file generated for each track,
/// to allow for media controls and reduce possibilities of latency.
class MetronomeClickPlayer {
  MetronomeClickPlayer({required this.clickStateStream}) {
    Future.wait(<Future<void>>[
      primaryAudioPlayer.setAudioSource(primaryClickSource),
      secondaryAudioPlayer.setAudioSource(secondaryClickSource)
    ]).then((_) => <bool>{audioIsSetup = true});
  }

  AudioSource primaryClickSource = AudioSource.asset('sounds/primary.wav');
  AudioSource secondaryClickSource = AudioSource.asset('sounds/secondary.wav');
  AudioPlayer primaryAudioPlayer = AudioPlayer();
  AudioPlayer secondaryAudioPlayer = AudioPlayer();
  bool audioIsSetup = false;

  Stream<ClickState> clickStateStream;

  StreamSubscription<ClickState>? clickSubscription;

  ClickState? previousState;

  void listen() {
    clickSubscription = clickStateStream.listen((ClickState clickState) {
      if (clickState.isClicking() && !(previousState?.isClicking() ?? false)) {
        if (!audioIsSetup) {
          return;
        }
        if (clickState.accent) {
          primaryAudioPlayer.seek(Duration.zero);
          primaryAudioPlayer.play();
        } else {
          secondaryAudioPlayer.seek(Duration.zero);
          secondaryAudioPlayer.play();
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
    primaryAudioPlayer.dispose();
    secondaryAudioPlayer.dispose();
    clickSubscription?.cancel();
  }
}
