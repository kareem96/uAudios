


import 'package:flutter/material.dart';

class SliderHandle extends StatelessWidget {
  const SliderHandle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 5,
      width: 30,
      decoration: BoxDecoration(
        color: isDarkTheme ? Colors.grey[400] : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
