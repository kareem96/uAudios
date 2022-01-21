




import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RadioIndexBloc{
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  int? _index;
  final _indexKey = 'radioIndex';
  final _initialIndexKey = 'initialRadioIndex';

  RadioIndexBloc(){
    prefs.then((value) {
      int openOption;
      if(value.get(_initialIndexKey) != null){
        openOption = value.getInt(_initialIndexKey) ?? -1;
      }else{
        openOption = -1;
        value.setInt(_initialIndexKey, openOption);
      }

      if(openOption < 0){
        if(value.get(_indexKey) != null){
          _index = value.getInt(_indexKey) ?? 0;
        }else{
          _index=0;
        }
      }else{
        _index = openOption;
      }
      _actionController.stream.listen(_changeStream);
      _addValue.add(_index);
      value.setInt(_indexKey, _index!);
    });
  }

  final _indexStream = BehaviorSubject<int>.seeded(0);
  Stream get radioIndexStream => _indexStream.stream;
  Sink  get _addValue => _indexStream.sink;
  final StreamController _actionController = StreamController();
  void get resetCount => _actionController.sink.add(null);
  StreamSink get changeRadioIndex => _actionController.sink;

  void _changeStream(data) async{
    if(data == null){
      _index = 0;
    }else{
      _index = data;
    }
    _addValue.add(_index);
    prefs.then((value) {
      value.setInt(_indexKey, _index!);
    });
  }

  void dispose(){
    _indexStream.close();
    _actionController.close();
  }
}