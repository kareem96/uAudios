


import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeZoneBloc{
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  String? _timeZone;
  final _timeZoneKey = 'timezone';
  final String initialTimeZone = 'INDIA';

  TimeZoneBloc(){
    prefs.then((value) {
      if(value.get(_timeZoneKey) != null){
        _timeZone = value.getString(_timeZoneKey) ?? initialTimeZone;
      }else{
        _timeZone = initialTimeZone;
      }
      _actionController.stream.listen(_changeStream);
      _addValue.add(_timeZone);
    });
  }
  final _timeZoneStream = BehaviorSubject<String?>.seeded('INDIA');
  Stream get timeZoneStream => _timeZoneStream.stream;
  Sink get _addValue => _timeZoneStream.sink;

  final StreamController _actionController = StreamController();
  void get resetCount => _actionController.sink.add(null);

  StreamSink get changeTimeZone => _actionController.sink;

  void _changeStream(data) async{
    if(data == null){
      _timeZone = initialTimeZone;
    }else{
      _timeZone = data;
    }
    _addValue.add(_timeZone);
    prefs.then((value) {
      value.setString(_timeZoneKey, _timeZone!);
    });
  }

  void dispose(){
    _timeZoneStream.close();
    _actionController.close();
  }

}