



import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:appaudios/audio_service/audio_manager.dart';
import 'package:appaudios/audio_service/notifiers/play_button_notifier.dart';
import 'package:appaudios/audio_service/service_locator.dart';
import 'package:appaudios/bloc/media/media_screen_bloc.dart';
import 'package:appaudios/screen/media_player/media_player.dart';
import 'package:appaudios/utils/helper/download_helper.dart';
import 'package:appaudios/utils/helper/media_helper.dart';
import 'package:appaudios/utils/helper/navigator_helper.dart';
import 'package:appaudios/widget/no_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class Media extends StatefulWidget {
  const Media({Key? key, required this.fids, this.title}) : super(key: key);
  final String fids;
  final String? title;

  @override
  _MediaState createState() => _MediaState();
}

class _MediaState extends State<Media> {
  bool _isLoading = true;

  final String baseUrl = 'https://radiosai.org/program/Download.php';
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
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    Color backgroundColor = Theme.of(context).backgroundColor;
    return Scaffold(
      appBar: AppBar(title: (widget.title == null) ? const Text('Media') : Text(widget.title ?? '') ,),
      backgroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states){
        return states.contains(MaterialState.scrolledUnder) ? ((isDarkTheme) ? Colors.grey : Theme.of(context).colorScheme.secondary) : Theme.of(context).primaryColor;
      }),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: backgroundColor,
        child: Stack(
          children: [
            if(_isLoading == false && _finalMediaData[0][0] != 'null' && _finalMediaData[0][0] != 'timeout')
              Scrollbar(
                radius: const Radius.circular(8),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.9
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: Card(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                        ),
                        elevation: 1,
                        color: isDarkTheme ? Colors.grey[800] : Colors.grey[200],
                        child: Consumer<MediaScreenBloc>(
                          builder: (context, _mediaScreenStateBloc, child){
                            return StreamBuilder<dynamic>(
                              stream: _mediaScreenStateBloc.mediaScreenStream,
                                builder: (context, snapshot){
                                  return _mediaItems(isDarkTheme);
                                }
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if(_finalMediaData[0] == 'null' && _isLoading == false)
              NoData(
                backgroundColor: backgroundColor,
                text: 'No data available, \ncheck your internet and try again',
                onPressed: (){
                  setState(() {
                    _isLoading = true;
                    _updateURL();
                  });
                },
              ),
            if(_finalMediaData[0] == 'timeout' && _isLoading == false)
              NoData(
                  backgroundColor: backgroundColor,
                  text: 'No data available, \nURL timeour, try again after some time',
                  onPressed: (){
                    setState(() {
                      _isLoading = true;
                      _updateURL();
                    });
                  }
              ),
            if(_isLoading)
              Container(
                color: backgroundColor,
                child: Center(
                  child: _showLoading(isDarkTheme),
                ),
              )
          ],
        ),
      ),
    );
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

  _getData(Map<String, dynamic> formData) async {
    String tempResponse = '';
    // checks if the file exists in cache
    var fileInfo = await DefaultCacheManager().getFileFromCache(finalUrl);
    if (fileInfo == null) {
      // get data from online if not present in cache
      http.Response response;
      try {
        response = await http.post(Uri.parse(baseUrl), body: formData).timeout(const Duration(seconds: 40));
      } on SocketException catch (_) {
        setState(() {
          // if there is no internet
          _finalMediaData = ['null'];
          finalUrl = '';
          _isLoading = false;
        });
        return;
      } on TimeoutException catch (_) {
        setState(() {
          // if timeout
          _finalMediaData = ['timeout'];
          finalUrl = '';
          _isLoading = false;
        });
        return;
      }
      tempResponse = response.body;

      // put data into cache after getting from internet
      List<int> list = tempResponse.codeUnits;
      Uint8List fileBytes = Uint8List.fromList(list);
      DefaultCacheManager().putFile(finalUrl, fileBytes);
    } else {
      // get data from file if present in cache
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

  Widget _mediaItems(bool isDarkTheme) {
    return ListView.builder(
        shrinkWrap: true,
        primary: false,
        padding: const EdgeInsets.only(top: 2, bottom: 2),
        itemCount: _finalMediaData.length,
        itemBuilder: (context, index){
          String  mediaFileName = '${_finalMediaData[index]}${MediaHelper.mediaFileType}';
          String mediaName = _finalMediaData[index];
          mediaName = mediaName.replaceAll('', ' ');
          var mediaFilePath = '$_mediaDirectory/$mediaFileName';
          var mediaFile = File(mediaFilePath);
          var isFileExists = mediaFile.existsSync();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 4),
                child: Card(
                  elevation: 0,
                  color: isDarkTheme ? Colors.grey[800] : Colors.grey[200],
                  child: InkWell(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: Center(
                        child: ListTile(
                          title: Text(mediaName),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  icon: const Icon(CupertinoIcons.add_circled),
                                  onPressed: () async{
                                    bool hasInternet =  Provider.of<InternetConnectionStatus>(context, listen: false) == InternetConnectionStatus.connected;
                                    if(hasInternet){
                                      if(!(_audioManager!.queueNotifier.value.isNotEmpty && _audioManager!.mediaTypeNotifier.value == MediaType.media)){
                                        startPlayer(
                                          mediaName,
                                          _finalMediaLinks[index],
                                          isFileExists
                                        );
                                      }else{
                                        bool added = await addToQueue(mediaName, _finalMediaLinks[index], isFileExists);
                                        if(added){
                                          _showSnackBar(context, 'Added to queue', const Duration(seconds: 1));
                                        }
                                      }
                                    }else{
                                      _showSnackBar(context, 'Connect to the Internet and try again', const Duration(seconds: 2));
                                    }
                                  },
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                    onTap: () async{
                      bool hasInternet = Provider.of<InternetConnectionStatus>(context, listen: false) == InternetConnectionStatus.connected;

                      if(hasInternet){
                        await startPlayer(mediaName, _finalMediaLinks[index], isFileExists);
                      }else{
                        _showSnackBar(context, 'Connect to the Internet and try again', const Duration(seconds: 2));
                      }
                    },
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
              if(index != _finalMediaData.length - 1)
                const Divider(height: 2, thickness: 1.5,)
            ],
          );
        }
    );
  }

  Future<void> startPlayer(String name, String link, isFileExists) async{
    if(_audioManager!.playButtonNotifier.value == PlayButtonState.playing || _audioManager!.mediaTypeNotifier.value == MediaType.media){
      if(_audioManager!.mediaTypeNotifier.value == MediaType.media){
        if(_audioManager!.mediaTypeNotifier.value == name){
          if(_audioManager!.playButtonNotifier.value != PlayButtonState.playing){
            _audioManager!.play();
          }
          _showSnackBar(context, 'This i same as curently playing', const Duration(seconds: 2));
          getIt<NavigationService>().navigateTo(MediaPlayer.route);
          return;
        }
        _audioManager!.pause();
        bool isAdded = await addToQueue(name, link, isFileExists);
        if(!isAdded){
          await moveToLast(name, link, isFileExists);
        }
        int index = _audioManager!.queueNotifier.value.indexOf(name);
        await _audioManager!.load();
        await _audioManager!.skipToQueueItem(index);
        getIt<NavigationService>().navigateTo(MediaPlayer.route);
        _audioManager!.play();
      }else{
        _audioManager!.stop();
        await initMediaService(name, link, isFileExists).then((value) => getIt<NavigationService>().navigateTo(MediaPlayer.route));
      }
    }else{
      initMediaService(name, link, isFileExists).then((value) => getIt<NavigationService>().navigateTo(MediaPlayer.route));
    }
  }

  Future<void> initMediaService(String name, String link, bool isFileExists) async{
    final tempMediaItem = await MediaHelper.generateMediaItem(name, link, isFileExists);

    Map<String, dynamic> _params = {
      'id': tempMediaItem.id,
      'album': tempMediaItem.album,
      'title': tempMediaItem.title,
      'artist': tempMediaItem.artist,
      'artUri': tempMediaItem.artUri.toString(),
      'extrasUri': tempMediaItem.extras!['uri'],
    };
    _audioManager!.stop();
    await _audioManager!.init(MediaType.media, _params);
  }

  void _showSnackBar(BuildContext context, String text, Duration duration) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      duration: duration,
    ));
  }

  Future<void> moveToLast(String name, String link, bool isFileExists) async {
    if(_audioManager!.queueNotifier.value != null && _audioManager!.queueNotifier.value.length > 1){
      final tempMediaItem = await MediaHelper.generateMediaItem(name, link, isFileExists);
      await _audioManager!.removeQueueItemWithTitle(tempMediaItem.title);
      return _audioManager!.addQueueItem(tempMediaItem);
    }
    return;
  }

  Future<bool> addToQueue(String name, String link, bool isFileExists) async {
    final tempMediaItem = await MediaHelper.generateMediaItem(name, link, isFileExists);
    if(_audioManager!.queueNotifier.value.contains(tempMediaItem.title)){
      return false;
    }else{
      await _audioManager!.addQueueItem(tempMediaItem);
      return true;
    }
  }

  Widget _showLoading(bool isDarkTheme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Shimmer.fromColors(
          highlightColor: isDarkTheme ? Colors.grey : Colors.white,
          baseColor: isDarkTheme ? Colors.grey : Colors.white,
          child: Column(
          children: [
            for(int i = 0; i < 2; i++) _shimmerContent(),
        ],
      ),
      ),
    );
  }

  Widget _shimmerContent() {
    double width = MediaQuery.of(context).size.width;
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          width:  width * 0.9,
          height: 8,
          color: Colors.white,
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          width: width * 0.9,
          height: 8,
          color: Colors.white,
        )
      ],
    ),);
  }

}
