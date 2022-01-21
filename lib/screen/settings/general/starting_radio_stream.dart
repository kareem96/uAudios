


import 'package:appaudios/bloc/settings/initial_radio_index_bloc.dart';
import 'package:appaudios/utils/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const String recentlyPlayed = 'Recently played';

class StartingRadioStream extends StatefulWidget {
  final EdgeInsetsGeometry contentPadding;
  const StartingRadioStream({Key? key, required this.contentPadding}) : super(key: key);

  @override
  _StartingRadioStreamState createState() => _StartingRadioStreamState();
}

class _StartingRadioStreamState extends State<StartingRadioStream> {
  @override
  Widget build(BuildContext context) {
    return Consumer<InitialRadioIndexBloc>(
      builder: (context, _initialRadioIndexBloc, child){
        return StreamBuilder<int>(
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            int initialRadioStreamIndex = snapshot.data ?? -1;
            String subtitle =(initialRadioStreamIndex >= 0)
              ? Constants.of(context)!
                .radioStream
                .keys
                .toList()[initialRadioStreamIndex]
                : recentlyPlayed;

            return Tooltip(
              message: 'favorite radio stream to show on app start',
              child: ListTile(
                contentPadding: widget.contentPadding,
                title: const Text('starting radio stream'),
                subtitle: Text(subtitle),
                onTap: () async{
                  showDialog<void>(
                    context: context,
                    // false = user must tap button, true = tap outside dialog
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('Staeting radio stream'),
                        contentPadding: const EdgeInsets.only(top: 10),
                        content: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Scrollbar(
                            radius: const Radius.circular(8),
                            isAlwaysShown: true,
                            child: SingleChildScrollView(
                              child: ListView.builder(
                                  itemCount: Constants.of(context)!.radioStream.length + 1,
                                  primary: false,
                                  itemBuilder: (context, index){
                                    int value = index - 1;
                                    return RadioListTile(
                                        value: value,
                                        selected: value == initialRadioStreamIndex,
                                        title: (value >= 0) ? Text(Constants.of(context)!.radioStream.keys.toList()[value]) : const Text(recentlyPlayed),
                                        groupValue: initialRadioStreamIndex,
                                        onChanged: (value){
                                          _initialRadioIndexBloc.changeInitialRadioIndex.add(value);
                                          Navigator.of(context).pop();
                                        }
                                    );
                                  }
                              ),
                            ),
                          ),
                        ),
                        buttonPadding: const EdgeInsets.all(4),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('cancel'),
                            onPressed: () {
                              Navigator.of(context).pop(); // Dismiss alert dialog
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            );
          },);
      },
    );
  }
}
