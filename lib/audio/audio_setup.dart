import 'package:audio_session/audio_session.dart';

Future<void> setupAudio() async {
  // also setup audio session to allow soundpool to play sound.
  final AudioSession session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());
  await session.setActive(true);
}
