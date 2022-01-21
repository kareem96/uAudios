



import 'dart:async';

import 'package:rxdart/rxdart.dart';

class RadioLoadingBloc{
  bool? _loading;
  final _loadingStream = BehaviorSubject<bool>.seeded(false);
  final StreamController _actionController = StreamController();
  RadioLoadingBloc(){
    _actionController.stream.listen(_changeStream);
  }

  Stream get radioLoadingStream => _loadingStream.stream;
  Sink get _addValue => _loadingStream.sink;
  StreamSink get changeLoadingState => _actionController.sink;


  void _changeStream(data){
    if(data == null){
      _loading = false;
    }else{
      _loading = data;
    }
    _addValue.add(_loading);
  }

  void dispose(){
    _loadingStream.close();
    _actionController.close();
  }
}