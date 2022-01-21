



import 'dart:async';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetStatus{
  StreamController<InternetConnectionStatus> internetStatusStreamController = StreamController<InternetConnectionStatus>();

  InternetStatus(){
    InternetConnectionChecker().onStatusChange.listen((internetStatus) {
      internetStatusStreamController.add(internetStatus);
    });
  }
}