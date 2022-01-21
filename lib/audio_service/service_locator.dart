


import 'package:appaudios/audio_service/audio_manager.dart';
import 'package:appaudios/utils/helper/navigator_helper.dart';
import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';

import 'audio_handler.dart';

GetIt getIt = GetIt.instance;


Future<void> setupServiceLocator()async{
  getIt.registerSingleton<AudioHandler>(await initAudioService());

  /// audio manager
  getIt.registerLazySingleton<AudioManager>(() => AudioManager());
  /// global navigator
  getIt.registerLazySingleton(() => NavigationService());
}