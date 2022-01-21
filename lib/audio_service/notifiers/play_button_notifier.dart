


import 'package:flutter/material.dart';

enum PlayButtonState{paused, playing}

class PlayButtonNotifier extends ValueNotifier<PlayButtonState>{
  static const _initialValue = PlayButtonState.paused;
  PlayButtonNotifier() : super(_initialValue);
}