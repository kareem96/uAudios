

import 'package:flutter/material.dart';

class Constants extends InheritedWidget{
  static Constants? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<Constants>();

  const Constants({required Widget child, Key? key}) : super(key: key, child: child);


  final Map<String, String> radioStream = const{
    'Asia Stream': 'http://stream.radiosai.net:8002',
    'Africa Stream': 'http://stream.radiosai.net:8004',
    'America Stream': 'http://stream.radiosai.net:8006',
    'Bhajan Stream': 'http://stream.radiosai.net:8000',
    'Discourse Stream': 'http://stream.radiosai.net:8008',
    'Telugu Stream': 'http://stream.radiosai.net:8020'
  };

  final Map<String, String> radioStreamHttps = const {
    'Asia Stream': 'https://stream.sssmediacentre.org:8443/asia',
    'Africa Stream': 'https://stream.sssmediacentre.org:8443/afri',
    'America Stream': 'https://stream.sssmediacentre.org:8443/ameri',
    'Bhajan Stream': 'https://stream.sssmediacentre.org:8443/bhajan',
    'Discourse Stream': 'https://stream.sssmediacentre.org:8443/discourse',
    'Telugu Stream': 'https://stream.sssmediacentre.org:8443/telugu'
  };

  final List<String> menuTitles = const [
    'Schedule',
    'Audio',
    'Settings',
  ];

  final List<String> appThemes = const[
    'Light',
    'Dark',
    'System default'
  ];

  /// list of audio archive images with names
  final Map<String, String> audioArchive = const {
    'assets/audio_archive/baba_sings.jpg': 'Baba Sings',
    'assets/audio_archive/vedam.jpg': 'Vedic Chants',
    'assets/audio_archive/karaoke.jpg': 'Sai Bhajans Karaoke',
    'assets/audio_archive/ringtones.jpg': 'Ringtones & Special Audios',
    'assets/audio_archive/thursday_live.jpg': 'Thursday Live',
    'assets/audio_archive/musings.jpg': 'Musings',
    'assets/audio_archive/medical.jpg': 'Medical Marvels',
    'assets/audio_archive/seva.jpg': 'Service',
    'assets/audio_archive/fleeting_moments.jpg':
    'Fleeting Moments Lasting Memories',
    'assets/audio_archive/study_circle.jpg': 'Study Circle',
    'assets/audio_archive/anecdotes.jpg': 'Anecdotes to Awaken',
    'assets/audio_archive/loving_legend.jpg': 'Loving Legend Living Legacies',
    'assets/audio_archive/bhajan_tutor.jpg': 'Bhajan Tutor',
    'assets/audio_archive/oneness.jpg': 'Moments of Oneness',
    'assets/audio_archive/dramas.jpg': 'Dramas',
    'assets/audio_archive/talks.jpg': 'Talks',
    'assets/audio_archive/tales.jpg': 'Tales that Transform',
    'assets/audio_archive/chinnikatha.jpg': 'Chinna Kathas',
    'assets/audio_archive/sse.jpg': 'SSE on Air',
    'assets/audio_archive/matter.jpg': 'Matter of Conscience',
    'assets/audio_archive/learning_with_love.jpg': 'Learning with Love',
    'assets/audio_archive/tryst.jpg': 'Tryst with Divinity',
  };

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

}