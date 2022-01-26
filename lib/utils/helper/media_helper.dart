


import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

enum MediaType{radio, media,}

class MediaHelper{

  /// url for media
  static String mediaBaseUrl = 'https://dl.radiosai.org/';
  /// type file
  static String mediaFileType = '.mp3';

  static Future<MediaItem> generateMediaItem(String name, String link, bool isFileExists) async{
    String path = await getDefaultNotificationImage();
    if(isFileExists){
      link = await changeLinkToFileUri(link);
    }

    String fileId = await getFileIdFromUri(link);
    Map<String, dynamic> _extras = {
      'uri':link,
    };

    final tempMediaItem = MediaItem(
      id: fileId,
      album: 'uAdios Album',
      title: name,
      artist: 'Artist uAudio',
      artUri: Uri.parse('file://$path'),
      extras: _extras,
    );
     return tempMediaItem;
  }

  static String getLinkFromFileId(String id){
    return '$mediaBaseUrl$id';
  }

  static String getFileUriFileWithDirectory(String id, String directory) {
    return 'file://$directory/$id';
  }

  static Future<String> getCacheDirectoryPath() async {
    String cachedPath = await _getCachedPath();
    return '$cachedPath/Media';
  }

  static Future<String>_getCachedPath() async{
    Directory pathDirectory = await getApplicationDocumentsDirectory();
    return pathDirectory.path;
  }

  static Future<String> getDefaultNotificationImage() async {
    String path = await _getNotificationFilePath();
    File file = File(path);
    bool fileExists = file.existsSync();
    if (fileExists) return path;
    final byteData = await rootBundle.load('assets/sai_listens_notification.jpg');
    file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return path;
  }

  static Future<String> _getNotificationFilePath()async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    String filePath = '$appDocPath/sai_listens_notification.jpg';
    return filePath;
  }

  static Future<String> changeLinkToFileUri(String link) async{
    String directory = await getDirectoryPath();
    link = link.replaceAll(mediaBaseUrl, '');
    return 'file: //$directory/$link';
  }

  static Future<String> getDirectoryPath()async {
    final publicDirectoryPath = await _getPublicPath();
    const albumName = 'Voice';
    final mediaDirectoryPath = '$publicDirectoryPath/$albumName';
    return mediaDirectoryPath;
  }

  static Future<String> _getPublicPath() async{
    Directory pathDirectory = await getApplicationDocumentsDirectory();
    return pathDirectory.path;
  }

  static Future<String> getFileIdFromUri(String uri)async {
    String directory = await getDirectoryPath();
    uri = uri.replaceAll(mediaBaseUrl, '');
    uri = uri.replaceAll('file://$directory', '');
    return uri;
  }
}
