



import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:appaudios/audio_service/audio_manager.dart';
import 'package:appaudios/audio_service/service_locator.dart';
import 'package:appaudios/utils/helper/download_helper.dart';
import 'package:appaudios/utils/helper/media_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

class Media extends StatefulWidget {
  const Media({Key? key, required this.fids, this.title}) : super(key: key);
  final String fids;
  final String? title;

  @override
  _MediaState createState() => _MediaState();
}

class _MediaState extends State<Media> {
  bool _isLoading = true;

  final String baseUrl = '';
  String finalUrl = '';
  List<String> _finalMediaData = ['null'];
  List<String> _finalMediaLinks = [];
  String _mediaDirectory = '';
  List<DownloadTaskInfo>? _downloadTasks;
  AudioManager? _audioManager;

  @override
  void initState() {
    _audioManager = getIt<AudioManager>();
    _isLoading = true;
    super.initState();
    _getDirectoryPath();
    _updateURL();
    _downloadTasks = DownLoadHelper.getDownloadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  _getDirectoryPath() async{
    final mediaDirectoryPath = await MediaHelper.getDirectoryPath();
    setState(() {
      _mediaDirectory = mediaDirectoryPath;
    });
  }

  _updateURL() {
    var data = <String, dynamic>{};
    data['allfids'] = widget.fids;
    String url = '$baseUrl?allfids=${data['allfids']}';
    finalUrl = url;
    _getData(data);
  }

  _getData(Map<String, dynamic> formData) async{
    String tempResponse = '';
    var fileInfo = await DefaultCacheManager().getFileFromCache(finalUrl);
    if(fileInfo == null){
      http.Response response;
      try{
        response = await http.post(Uri.parse(baseUrl), body: formData).timeout(const Duration(seconds: 40));
      }on SocketException catch(_){
        setState(() {
          _finalMediaData = ['null'];
          finalUrl = '';
          _isLoading = false;
        });
        return;
      }on TimeoutException catch (_){
        setState(() {
          _finalMediaData = ['timeout'];
          finalUrl = '';
          _isLoading = false;
        });
        return;
      }
      tempResponse = response.body;

      List<int> list = tempResponse.codeUnits;
      Uint8List fileBytes = Uint8List.fromList(list);
      DefaultCacheManager().putFile(finalUrl, fileBytes);
    }else{
      tempResponse = fileInfo.file.readAsStringSync();
    }
    _parseData(tempResponse);
  }

  _parseData(String response) async {
    var document = parse(response);
    var mediaTags = document.getElementsByTagName('a');
    List<String> mediaFiles = [];
    List<String> mediaLinks = [];
    int length = mediaTags.length;
    for(int i = 0; i < length; i++){
      var temp = mediaTags[i].text;
      temp = temp.replaceAll('.mp3', '');
      mediaFiles.add(temp);
      mediaLinks.add('${MediaHelper.mediaBaseUrl}${mediaFiles[i]}${MediaHelper.mediaFileType}');
    }
    setState(() {
      _finalMediaData = mediaFiles;
      _finalMediaLinks = mediaLinks;
      _isLoading = false;
    });
  }
}
