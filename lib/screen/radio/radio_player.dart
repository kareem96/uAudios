



import 'dart:io';

import 'package:appaudios/audio_service/audio_manager.dart';
import 'package:appaudios/audio_service/notifiers/loading_notifier.dart';
import 'package:appaudios/audio_service/service_locator.dart';
import 'package:appaudios/bloc/radio/radio_loading_bloc.dart';
import 'package:appaudios/screen/radio/radio_stream_select.dart';
import 'package:appaudios/utils/constants/constants.dart';
import 'package:appaudios/utils/helper/media_helper.dart';
import 'package:appaudios/widget/radio/slider_handle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class RadioPlayer extends StatefulWidget {
  final Radius radius;
  final int radioStreamIndex;
  final bool isPlaying;
  final bool loadingState;
  final RadioLoadingBloc radioLoadingBloc;
  final bool hasInternet;
  const RadioPlayer({
    Key? key,
    required this.radius,
    required this.radioLoadingBloc,
    required this.isPlaying,
    required this.loadingState,
    required this.hasInternet,
    required this.radioStreamIndex,
      }) : super(key: key);

  @override
  _RadioPlayerState createState() => _RadioPlayerState();
}

class _RadioPlayerState extends State<RadioPlayer> with SingleTickerProviderStateMixin{

  ///controller used for animating pause and play
  AnimationController? _pausePlayController;

  ///controller used for handling sliding panel
  final PanelController _panelController = PanelController();

  ///change while radio is in playing state
  int _tempRadioStreamIndex = 0;

  ///to check if the app is built for first time
  bool initialBuild = false;

  ///reduce multiple snackbar when clicking many time
  bool _isSnackBarActive = false;
  AudioManager? _audioManager;

  @override
  void initState() {
    ///get audio manager
    _audioManager = getIt<AudioManager>();
    ///initialize the pause play controller
    _pausePlayController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 300));
    ///true when the widgets are building
    initialBuild = true;
    ///false the value after the build is completed
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      initialBuild = false;
  });
    super.initState();
  }
  @override
  void dispose() {
    _audioManager?.stop();
    _pausePlayController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.red,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ));
    ///handle the pause and play button
    _handlePlayingState(widget.isPlaying);
    ///handle the stream change when it is changed
    _handleRadioStreamChange(widget.radioStreamIndex, widget.isPlaying, widget.radioLoadingBloc);

    ///get the height  of the screen useful for split screen
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    bool isBigScreen = (height * 0.1 >= 50);
    bool isBiggerScreen = (height * 0.1 >= 70);
    bool isSmallerScreen = (height * 0.1 < 30);



    return WillPopScope(
      onWillPop: () async{
        if (_panelController.isPanelOpen) _panelController.close();
        // sends the app to background when backpress on home screen
        // achieved by adding a method in MainActivity.kt to support send app to background
        const MethodChannel('com.immadisairaj/android_app_retain')
            .invokeMethod('sendToBackground');
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SlidingUpPanel(
              borderRadius: BorderRadius.all(widget.radius),
              backdropEnabled: true,
              minHeight: height * 0.1,
              ///remove the collapse widget if the height is small below 2 lines
              collapsed: isBigScreen ? _slidingPanelCollapse(widget.radius) : null,
              renderPanelSheet: false,
              ///
              maxHeight: isBigScreen ? (isBiggerScreen ? height * 0.54 : height * 0.57) : height * 0.6,
              ///remove panel if small screen
              panel: isSmallerScreen
                  ? Container()
                  : RadioStreamSelect(
                  panelController: _panelController,
                  radius: widget.radius
              ),
              body: GestureDetector(
                onVerticalDragUpdate: (details){
                  int sensitivity = 8;
                  if(details.delta.dy < -sensitivity){
                    if(!isSmallerScreen){
                      _panelController.open();
                    }
                  }
                },
                child: Container(
                  height: height,
                  color: Colors.transparent,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: height * 0.2,
                      width: width,
                      child: Container(
                        color: Colors.black54,
                        child: _playerDisplay(
                            widget.radioStreamIndex,
                            widget.isPlaying,
                            widget.loadingState,
                            widget.radioLoadingBloc,
                            widget.hasInternet
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // if(!initialBuild) InternetAlert(hasInternet: widget.hasInternet),
          ],
        ),
      ),
    );
  }

  void _handlePlayingState(bool isPlaying) {
    if(isPlaying){
      _pausePlayController!.forward();
    }else{
      _pausePlayController!.reverse();
    }
  }

  void _handleRadioStreamChange(int radioStreamIndex, bool isPlaying, RadioLoadingBloc loadingStreamBloc) async {
    if(_tempRadioStreamIndex != radioStreamIndex){
      widget.radioLoadingBloc.changeLoadingState.add(false);
      if(isPlaying){
        loadingStreamBloc.changeLoadingState.add(true);
        await _audioManager!.clear();
        initRadioService(radioStreamIndex);
      }else{

      }
    }
  }

  ///initial the radio service to start playing
  Future<void> initRadioService(int index)async {
    await _audioManager!.init(MediaType.radio, {
      'radioStream': (Platform.isAndroid) ? Constants.of(context)!.radioStream : Constants.of(context)?.radioStreamHttps,
      'index': index
    });
    _audioManager?.playRadio(index);
    ///setting the temporary radio stream index to track the
    setState(() {
      _tempRadioStreamIndex = index;
    });
  }

  Widget _slidingPanelCollapse(Radius radius) {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: (){
        _panelController.open();
      },
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: widget.radius, topRight: widget.radius
          ),
          color: isDarkTheme ? Colors.grey[700] : Colors.white
        ),
        child: Column(
          children: const [
            SizedBox(height: 12,),
            SliderHandle(),
            SizedBox(height: 12,),
            Text('Select Stream', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),)
          ],
        ),
      ),
    );
  }

  Widget _playerDisplay(int streamIndex, bool isPlaying, bool loadingState, RadioLoadingBloc radioLoadingBloc, bool hasInternet) {
    double height = MediaQuery.of(context).size.height;
    bool isBigScreen = (height * 0.1 >= 50);
    bool isSmallerScreen = (height * 0.1 < 30);
    double iconSize = isBigScreen ? 40 : 30;
    String? playingRadioStreamName =
    Constants.of(context)?.radioStream.keys.toList()[streamIndex];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(playingRadioStreamName!, style: const TextStyle(color: Colors.white, fontSize: 24),),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ///circular loading progress
                  if(loadingState)
                    SizedBox(height: iconSize, width: iconSize, child: const CircularProgressIndicator(),),
                  IconButton(
                    splashColor: Theme.of(context).primaryColor,
                      splashRadius: 24,
                      highlightColor: Theme.of(context).primaryColor,
                      iconSize: iconSize,
                      color: Colors.white,
                      icon: AnimatedIcon(
                        icon: AnimatedIcons.play_pause, progress: _pausePlayController!,),
                      onPressed: () async {
                      if(streamIndex != null){
                        _handleOnPressed(streamIndex, isPlaying, hasInternet);
                      }
                      },
                  )
                ],
              ),
            )
          ],
        ),
        ///hiding the below widget as other functions are dependent on this
        ///Display the status of audio in text
        ValueListenableBuilder<LoadingState>(
            valueListenable: _audioManager!.loadingNotifier,
            builder: (context, loadingState, snapshot){
              bool loadingUpdate = loadingState == LoadingState.loading;
              if(loadingUpdate != null){
                if(loadingUpdate == true &&
                    _audioManager!.mediaTypeNotifier.value == MediaType.media){
                  loadingUpdate = false;
                }
                radioLoadingBloc.changeLoadingState.add(loadingUpdate);
              }
              return Container(
                color: Colors.transparent,
                height:  isBigScreen ? height * 0.09 : (isSmallerScreen ? 0 : height * 0.08),
                width: 0,
              );
            }
        )
      ],
    );
  }

  void _handleOnPressed(int index, bool isPlaying, bool hasInternet)async {
    if(!isPlaying){
      if(_audioManager?.mediaTypeNotifier.value == MediaType.media){
        _audioManager?.clear();
        _startRadioPlayer(index, isPlaying, hasInternet);
      }else{
        _startRadioPlayer(index, isPlaying, hasInternet);
      }
    }else{
      stopRadioService();
    }
  }

  void _startRadioPlayer(int index, bool isPlaying, bool hasInternet) {
    if(hasInternet){
      initRadioService(index);
    }else{
      initRadioService(index);
      if(_isSnackBarActive == false){
        _isSnackBarActive = true;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Try to play after connecting to internet'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(milliseconds: 1500),
        )).closed.then((value){
          _isSnackBarActive = false;
        });
      }
    }
  }

  void stopRadioService() {
    _audioManager?.stop();
  }
}
