



import 'dart:async';

import 'package:rxdart/rxdart.dart';

class MediaScreenBloc {
  bool? _changed;
  MediaScreenBloc(){
    _actionController.stream.listen(_changeStream);
  }
  bool getCurrentValue(){
    return _changed!;
  }
  final _downloadStream = BehaviorSubject<bool>.seeded(false);
  Stream get mediaScreenStream => _downloadStream.stream;
  Sink get _addValue => _downloadStream.sink;
  final StreamController _actionController = StreamController();
  StreamSink get changeMediaScreenState => _actionController.sink;

  void _changeStream(data){
    if(data == null){
      _changed = false;
    }else{
      _changed = data;
    }
    _addValue.add(_changed);
  }

  void dispose(){
    _downloadStream.close();
    _actionController.close();
  }
}