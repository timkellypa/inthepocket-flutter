import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';
import '../audio/setlist_audio_handler.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerSingleton<AudioHandler>(await initAudioService());
}