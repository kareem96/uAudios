


import 'package:appaudios/audio_service/audio_manager.dart';
import 'package:appaudios/audio_service/notifiers/play_button_notifier.dart';
import 'package:appaudios/audio_service/service_locator.dart';
import 'package:appaudios/screen/media_player/media_player.dart';
import 'package:appaudios/utils/helper/media_helper.dart';
import 'package:appaudios/utils/helper/navigator_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomMediaPlayer extends StatefulWidget {
  const BottomMediaPlayer({Key? key}) : super(key: key);

  @override
  _BottomMediaPlayerState createState() => _BottomMediaPlayerState();
}

class _BottomMediaPlayerState extends State<BottomMediaPlayer> {
  AudioManager? _audioManager;

  @override
  void initState() {
    _audioManager = getIt<AudioManager>();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    Color? backgroundColor = isDarkTheme ? Colors.grey[800] : Colors.grey[300];
    //
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    bool isBigScreen = (height * 0.1 >= 50);
    bool isBiggerScreen = (height * 0.1 >= 70);
    bool isSmallerScreen = (height * 0.1 >= 30);
    if(isSmallerScreen){
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }

    return ValueListenableBuilder<List<String>>(
        valueListenable: _audioManager!.queueNotifier,
        builder: (context, queueList, snapshot){
          final running = queueList.isNotEmpty && _audioManager!.mediaTypeNotifier.value != MediaType.radio;
          if(!running){
            return const SizedBox(height: 0, width: 0,);
          }
          return ValueListenableBuilder<List<String>>(
              valueListenable: _audioManager!.queueNotifier,
              builder: (context, queueList, snapshot){
                if(queueList == null || queueList.isNotEmpty){
                  return const SizedBox(height: 0, width: 0,);
                }
                return GestureDetector(
                  onTap: (){
                    getIt<NavigationService>().navigateTo(MediaPlayer.route);
                  },
                  child: Container(
                    height: (isBiggerScreen) ? height * 0.80 : height * 0.1,
                    width: width,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      border: Border(
                        top: BorderSide(
                          color: isDarkTheme ? Colors.grey : Colors.white,
                        )
                      )
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(
                            height: 40,
                            width: 40,
                            child: Image(
                              fit: BoxFit.cover,
                              alignment: Alignment(0, -1),
                              image: AssetImage('assetName'),
                            ),
                          ),
                          ValueListenableBuilder<String>(
                              valueListenable: _audioManager!.currentSongTitleNotifier,
                              builder: (context, mediaTitle, child){
                                if(mediaTitle == ''){
                                  mediaTitle = 'loading media...';
                                }
                                return SizedBox(
                                  width: width * 0.65,
                                  child: Text(
                                    mediaTitle,
                                    textAlign: TextAlign.start,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                );
                              }
                          ),
                          ValueListenableBuilder<PlayButtonState>(
                              valueListenable: _audioManager!.playButtonNotifier,
                              builder: (context, playState, snapshot){
                                final playing = (playState == PlayButtonState.playing);
                                return playing ? pauseButton() : playButton();
                              }
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }
          );
        }
    );
  }

  IconButton playButton() => IconButton(
    icon: const Icon(CupertinoIcons.play),
    splashRadius: 24,
    iconSize: 25,
    onPressed: _audioManager?.play,
  );

  IconButton pauseButton() => IconButton(
    icon:  const Icon(CupertinoIcons.pause),
    splashRadius: 24,
    iconSize: 25,
    onPressed: _audioManager?.pause,
  );
}
