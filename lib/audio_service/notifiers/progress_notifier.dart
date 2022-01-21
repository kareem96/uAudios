


import 'package:flutter/material.dart';

class ProgressBarState{
  final Duration current;
  final Duration buffered;
  final Duration total;

  const ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });
}


class ProgressNotifier extends ValueNotifier<ProgressBarState>{
  ProgressNotifier() : super(_initialValue);
  static const _initialValue = ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero
  );
}