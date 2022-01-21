

import 'package:appaudios/audio_service/audio_manager.dart';
import 'package:appaudios/audio_service/notifiers/play_button_notifier.dart';
import 'package:appaudios/audio_service/service_locator.dart';
import 'package:appaudios/bloc/radio/radio_index_bloc.dart';
import 'package:appaudios/bloc/radio/radio_loading_bloc.dart';
import 'package:appaudios/screen/radio/radio_player.dart';
import 'package:appaudios/utils/helper/media_helper.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';


class RadioHome extends StatefulWidget {
  const RadioHome({Key? key}) : super(key: key);

  @override
  _RadioHomeState createState() => _RadioHomeState();
}

class _RadioHomeState extends State<RadioHome> {
  AudioManager? _audioManager;

  @override
  void initState() {
    _audioManager = getIt<AudioManager>();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Radius radius = const Radius.circular(24);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: const Image(
              fit: BoxFit.cover,
              alignment: Alignment(0,-1),
              image: AssetImage('assets/default.jpeg'),
            ),
          ),
          Container(color: Color(0x2f000000),),
          Consumer<RadioIndexBloc>(
              builder: (context, _radioIndexBloc, child){
                return StreamBuilder<int>(
                  stream: _radioIndexBloc.radioIndexStream as dynamic,
                    builder: (context, snapshot){
                    int radioStreamIndex = snapshot.data ?? 0;

                    ///listen to change of radio player loading state
                    return Consumer<RadioLoadingBloc>(
                      builder: (context, _radioLoadingBloc, child){
                        return StreamBuilder<bool>(
                          stream: _radioLoadingBloc.radioLoadingStream as dynamic,
                          builder: (context, snapshot){
                            bool loadingState = snapshot.data ?? false;

                            ///listen to change of paling state
                            ///form audio service
                            return ValueListenableBuilder<PlayButtonState>(
                                valueListenable: _audioManager!.playButtonNotifier,
                                builder: (context, playButtonState, snapshot){
                                  bool isPlaying = playButtonState == PlayButtonState.playing;

                                  ///change the playing state only when radio
                                  ///player is playing
                                  if(_audioManager!.mediaTypeNotifier.value == MediaType.media) {
                                    isPlaying = false;
                                  }

                                  ///get the data of the internet
                                  ///connectivity change
                                  bool hasInternet = Provider.of<InternetConnectionStatus>(context) == InternetConnectionStatus.connected;
                                  return RadioPlayer(
                                      radius: radius,
                                      radioLoadingBloc: _radioLoadingBloc,
                                      isPlaying: isPlaying,
                                      loadingState: loadingState,
                                      hasInternet: hasInternet,
                                      radioStreamIndex: radioStreamIndex
                                  );
                                }
                            );
                          },
                        );
                      },
                    );
                    }
                );
              }
          )
        ],
      ),
    );
  }
}
