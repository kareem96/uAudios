




import 'package:appaudios/audio_service/service_locator.dart';
import 'package:appaudios/screen/media_player/media_player.dart';
import 'package:appaudios/screen/media_player/playing_queue.dart';
import 'package:appaudios/utils/helper/media_helper.dart';
import 'package:appaudios/utils/helper/navigator_helper.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';



Future<AudioHandler> initAudioService() async{
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.kareemdev.uAudios',
      androidNotificationChannelName: 'uAudios',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler{
  final _player = AudioPlayer();
  final _queue = ConcatenatingAudioSource(children: []);
  var _mediaType = MediaType.radio;

  MyAudioHandler(){
    _listenToNotificationClickEvent();
  }

  _listenToNotificationClickEvent() {
    AudioService.notificationClicked.listen((clicked) {
      if(clicked && _mediaType == MediaType.media){
        if(!getIt<NavigationService>().isCurrentRoute(MediaPlayer.route)){
          if(getIt<NavigationService>().isCurrentRoute(PlayingQueue.route)){
            getIt<NavigationService>().popUntil(MediaPlayer.route);
          }else{
            getIt<NavigationService>().navigateTo(MediaPlayer.route);
          }
        }
      }else if(clicked && _mediaType == MediaType.radio){
        getIt<NavigationService>().popToBase();
      }
    });
  }

  /// initialized before playing
  _initAudioHandler(){
    _loadEmptyPlayList();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForCurrentSongIndexChanges();
    _listenForDurationChanges();
    _listenForSequenceStateChanges();
  }

  Future<void> _loadEmptyPlayList() async{
    try{
      await _player.setAudioSource(_queue, initialPosition: Duration.zero);
    }catch (e){
      ///
      debugPrint('Error: $e');
    }
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(__getPlaybackState(event, playing));
    });
  }

  PlaybackState __getPlaybackState(PlaybackEvent event, bool playing) {
    if(_mediaType == MediaType.radio){
      return playbackState.value.copyWith(
        controls: [
          (playing) ? MediaControl.pause : MediaControl.play,
          MediaControl.stop
        ],
        systemActions: const{},
        androidCompactActionIndices: const[0, 1],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      );
    }else{
      return playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          (playing) ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const[0,1,2],
        processingState: const{
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        repeatMode: const{
          LoopMode.off: AudioServiceRepeatMode.none,
          LoopMode.one: AudioServiceRepeatMode.one,
          LoopMode.all: AudioServiceRepeatMode.all,
        }[_player.loopMode]!,
        shuffleMode: (_player.shuffleModeEnabled) ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      );
    }
  }

  void _listenForCurrentSongIndexChanges() {
    _player.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if(index == null || playlist.isEmpty)return;
      if(_player.shuffleModeEnabled){
        index = _player.shuffleIndices![index];
      }
      try{
        mediaItem.add(playlist[index]);
      }catch(_){

      }
    });
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      var index = _player.currentIndex;
      final newQueue = queue.value;
      if(index == null || newQueue.isEmpty) return;
      if(_player.shuffleModeEnabled){
        index = _player.shuffleIndices![index];
      }
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if(sequence == null || sequence.isEmpty) return;
      final items = sequence.map((source) => source.tag as MediaItem);
      queue.add(items.toList());
    });
  }
}