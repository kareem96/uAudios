


import 'dart:isolate';
import 'dart:ui';

import 'package:appaudios/bloc/media/media_screen_bloc.dart';
import 'package:appaudios/utils/helper/media_helper.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

class DownLoadHelper{
  static List<DownloadTaskInfo> downloadTasks = [];
  static ReceivePort port = ReceivePort();
  static GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  static MediaScreenBloc? mediaScreenBloc = MediaScreenBloc();
  static List<DownloadTaskInfo> getDownloadTasks(){
    return downloadTasks;
  }
  static GlobalKey<ScaffoldState> getScaffoldKey(){
    return scaffoldKey;
  }

  static MediaScreenBloc? getMediaScreenBloc(){
    return mediaScreenBloc;
  }
  static void bindBackgroundIsolate(){
    bool isSuccess = IsolateNameServer.registerPortWithName(port.sendPort, 'downloader_send_port');
    if(!isSuccess){
      bindBackgroundIsolate();
      return;
    }
    port.listen((data) {
      String id = data[0];
      int progress = data[2];
      if(downloadTasks != null && downloadTasks.isNotEmpty){
        final task = downloadTasks.firstWhere((element) => element.taskId == id);
        task.progress = progress;

        _showSnackBar(scaffoldKey.currentContext!, 'failed downloading', const Duration(seconds: 1));
        return;
      }
      _showSnackBar(scaffoldKey.currentContext!, 'downloaded', Duration(seconds: 1));

      bool currentValue = mediaScreenBloc?.getCurrentValue() ?? false;
      mediaScreenBloc?.changeMediaScreenState.add(!currentValue);
      return;
    });
  }

  static void _showSnackBar(BuildContext context, String text, Duration duration){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      duration: duration,
    ));
  }

  static _replaceMedia(DownloadTaskInfo task) async{
    MediaItem mediaItem = await MediaHelper.generateMediaItem(task.name, task.link, false);
    if(AudioService.queue == null) return;
    int? index = AudioService.queue?.indexOf(mediaItem);
    if(index != -1){
      String uri = await MediaHelper.changeLinkToFileUri(task.link);
      String id = await MediaHelper.getFileIdFromUri(task.link);
      Map<String, dynamic> _params = {
        'id': id,
        'name': task.name,
        'index': index,
        'uri': uri,
      };
      AudioService.customAction('editUri', _params);
    }
  }
}

class DownloadTaskInfo {
  final String name;
  final String link;

  String taskId = '';
  int progress = 0;

  DownloadTaskInfo({required this.name, required this.link});
}