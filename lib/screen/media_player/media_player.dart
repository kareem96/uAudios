



import 'dart:io';

import 'package:appaudios/audio_service/audio_manager.dart';
import 'package:appaudios/utils/helper/download_helper.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MediaPlayer extends StatefulWidget {
  static const String route = 'mediaPlayer';
  const MediaPlayer({Key? key}) : super(key: key);

  @override
  _MediaPlayerState createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  String _mediaDirectory = '';
  List<DownloadTaskInfo>? _downloadTasks;
  AudioManager? _audioManager;


  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    Color bacgroundColor = Theme.of(context).backgroundColor;

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    bool isBigScreen = (height * 0.1 >= 50);
    bool isSmallerScreen = (height * 0.1 < 30);

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: bacgroundColor,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(),
                  child: Material(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            icon: Icon((Platform.isAndroid) ? Icons.arrow_back_outlined : CupertinoIcons.back),
                            splashRadius: 24,
                            iconSize: 25,
                            onPressed: (){
                              Navigator.maybePop(context);
                            },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [],
                        )
                      ],
                    ),
                  ),
                ),
                Column(),
                ValueListenableBuilder<String>(
                    valueListenable: _audioManager!.currentSongTitleNotifier,
                    builder: (context, mediaTitle, child){
                      double textSize = (isSmallerScreen) ? 15 : 20;
                      return const SizedBox();
                    }
                ),
                ValueListenableBuilder<List<String>>(
                    valueListenable: _audioManager!.queueNotifier,
                    builder: (context, queueList, child){
                      final queue = queueList;
                      if(queue == null || queue.isEmpty){
                        Navigator.maybePop(context);
                      }
                      double iconSize = width / 9;
                      return ValueListenableBuilder(
                          valueListenable: _audioManager!.currentSongTitleNotifier,
                          builder: (context, mediaTitle, child){
                            return Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Material(

                              ),
                            );
                          }
                      );
                    }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QueueState{
  final List<MediaItem> queue;
  final MediaItem mediaItem;
  QueueState(this.queue, this.mediaItem);
}

class MediaState{
  final MediaItem mediaItem;
  final Duration position;
  final PlaybackState playbackState;
  MediaState(this.mediaItem, this.playbackState, this.position);
}
