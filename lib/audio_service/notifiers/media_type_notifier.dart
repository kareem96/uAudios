

import 'package:appaudios/utils/helper/media_helper.dart';
import 'package:flutter/material.dart';

class MediaTypeNotifier extends ValueNotifier<MediaType>{
  static const _initialValue = MediaType.radio;
  MediaTypeNotifier() : super(_initialValue);
}