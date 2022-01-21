

import 'package:flutter/material.dart';


enum LoadingState{loading, done,}

class LoadingNotifer extends ValueNotifier<LoadingState>{
  static const _initialValue = LoadingState.done;
  LoadingNotifer() : super(_initialValue);
}