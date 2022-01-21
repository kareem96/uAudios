


import 'package:appaudios/bloc/settings/app_theme_bloc.dart';
import 'package:appaudios/utils/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppTheme extends StatefulWidget {
  final EdgeInsetsGeometry contentPadding;
  const AppTheme({Key? key, required this.contentPadding}) : super(key: key);

  @override
  _AppThemeState createState() => _AppThemeState();
}

class _AppThemeState extends State<AppTheme> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeBloc>(
      builder: (context, _appThemeBloc, child){
        return StreamBuilder<dynamic>(
          stream: _appThemeBloc.appThemeStream,
          builder: (context, snapshot){
            String? appTheme = snapshot.data ?? Constants.of(context)!.appThemes[2];
            return Tooltip(
              message: 'change app theme',
              child: ListTile(
                contentPadding: widget.contentPadding,
                title: const Text('Theme'),
                subtitle: Text(appTheme!),
                onTap: () async{
                  showDialog<void>(
                    context: context,
                    // false = user must tap button, true = tap outside dialog
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Change Theme'),
                        contentPadding: const EdgeInsets.only(top: 10),
                        content: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Scrollbar(
                            radius: const Radius.circular(8),
                            isAlwaysShown: true,
                            child: SingleChildScrollView(
                              child: ListView.builder(
                                itemCount: Constants.of(context)!.appThemes.length,
                                shrinkWrap: true,
                                primary: false,
                                itemBuilder: (context, index){
                                  String value = Constants.of(context)!.appThemes[index];
                                  return RadioListTile(
                                      activeColor: Theme.of(context).colorScheme.secondary,
                                      value: value,
                                      groupValue: value == appTheme,
                                      title: Text(value),
                                      onChanged: (value){
                                        _appThemeBloc.changeAppTheme.add(value);
                                        Navigator.of(context).pop();
                                      });
                                  },
                              ),
                            ),
                          ),
                        ),
                        buttonPadding: const EdgeInsets.all(4),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop(); // Dismiss alert dialog
                            },
                          ),
                        ],
                      );
                    },);
                },
              ),
            );
          },);
      },);
  }
}
