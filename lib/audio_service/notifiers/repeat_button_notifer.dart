


import 'package:flutter/material.dart';

enum RepeatState{
  off,
  repeatQueue,
  repeatSong,
}

class RepeatButtonNotifier extends ValueNotifier<RepeatState>{
  static const RepeatState _initialValue = RepeatState.off;
  RepeatButtonNotifier() : super(_initialValue);

  void nextState(){
    final next = (value.index + 1) % RepeatState.values.length;
    value = RepeatState.values[next];
  }

}