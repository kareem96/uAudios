


import 'package:appaudios/bloc/radio/radio_index_bloc.dart';
import 'package:appaudios/utils/constants/constants.dart';
import 'package:appaudios/widget/radio/slider_handle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class RadioStreamSelect extends StatefulWidget {
  final PanelController panelController;
   final Radius radius;
  const RadioStreamSelect({Key? key, required this.panelController, required this.radius}) : super(key: key);

  @override
  _RadioStreamSelectState createState() => _RadioStreamSelectState();
}

class _RadioStreamSelectState extends State<RadioStreamSelect> {
  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Consumer<RadioIndexBloc>(
      builder: (context, _radioIndexBloc, child){
        return StreamBuilder<int>(
          builder: (context, snapshot){
            int index  = snapshot.data ?? 0;
            return GestureDetector(
              ///handle open panel on tap, when small screen
              onTap: () => widget.panelController.open(),
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkTheme ? Colors.grey[700] : Colors.white,
                  borderRadius: BorderRadius.all(widget.radius)
                ),
                margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 12,),
                    const SliderHandle(),
                    _slide(_radioIndexBloc, index, isDarkTheme),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _slide(RadioIndexBloc radioIndexBloc, int radioIndex, bool isDarkTheme) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    bool isBigScreen = (height * 0.1 >= 50);
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: width * 0.4 / (height * 0.27 /2),
      ),
      itemCount: Constants.of(context)?.radioStream.length,
      ///
      padding: const EdgeInsets.only(top: 10),
      primary: false,
      shrinkWrap: true,
      itemBuilder: (context, widgetIndex){
        bool isMatch = (widgetIndex == radioIndex);
        String radioName = Constants.of(context)!.radioStream.keys.toList()[widgetIndex];
        return Padding(
          padding: isBigScreen ? const EdgeInsets.all(4) : const EdgeInsets.all(2),
          child: Card(
            elevation: 1.5,
            shadowColor: isDarkTheme ? Colors.white : Theme.of(context).primaryColor,

          ),
        );
      },

    );
  }
}
