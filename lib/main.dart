import 'package:appaudios/audio_service/service_locator.dart';
import 'package:appaudios/bloc/radio/radio_index_bloc.dart';
import 'package:appaudios/bloc/radio/radio_loading_bloc.dart';
import 'package:appaudios/bloc/settings/app_theme_bloc.dart';
import 'package:appaudios/bloc/settings/initial_radio_index_bloc.dart';
import 'package:appaudios/screen/home.dart';
import 'package:appaudios/screen/settings/settings.dart';
import 'package:appaudios/utils/constants/constants.dart';
import 'package:appaudios/utils/helper/navigator_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

import 'bloc/internet_status.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(Constants(child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final Color secondaryColor = Colors.indigo;

  ///default light theme
  final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.indigo,
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark
      ),
    ),
    backgroundColor: Colors.white,
    secondaryHeaderColor: Colors.indigo
  );

  ///theme set dark
  final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.indigo,
    brightness: Brightness.dark,
    cardColor: Colors.grey[700],
    backgroundColor: Colors.grey[700],
    secondaryHeaderColor: Colors.indigo
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppThemeBloc>(
          create: (_) => AppThemeBloc(),
          dispose: (_, AppThemeBloc appThemeBloc) => appThemeBloc.dispose(),
        ),
        Provider<RadioIndexBloc>(
          create: (_) => RadioIndexBloc(),
          dispose: (_, RadioIndexBloc radioIndexBloc) => radioIndexBloc.dispose(),
        ),
        Provider<RadioLoadingBloc>(
          create: (_) => RadioLoadingBloc(),
          dispose: (_, RadioLoadingBloc radioLoadingBloc) => radioLoadingBloc.dispose(),
        ),
        Provider<InitialRadioIndexBloc>(
          create: (_) => InitialRadioIndexBloc(),
          dispose: (_, InitialRadioIndexBloc initialRadioIndexBloc) => initialRadioIndexBloc.dispose(),
        ),
        StreamProvider<InternetConnectionStatus>(
            initialData: InternetConnectionStatus.connected,
            create: (context) => InternetStatus().internetStatusStreamController.stream,
        )
      ],
      child: Consumer<AppThemeBloc>(
        builder: (context, _appThemeBloc, child){
          return StreamBuilder<String>(
            stream: _appThemeBloc.appThemeStream as dynamic,
            builder: (context, snapshot) {
              String? appTheme = snapshot.data ?? Constants.of(context)?.appThemes[2];
              bool isSystemDefault = appTheme == Constants.of(context)?.appThemes[2];
              bool isDarkTheme = appTheme == Constants.of(context)?.appThemes[1];

              return MaterialApp(
                title: 'uAudios',
                debugShowCheckedModeBanner: false,
                theme: isSystemDefault
                    ? lightTheme.copyWith(colorScheme: lightTheme.colorScheme.copyWith(secondary: Colors.indigo))
                    : (isDarkTheme ? darkTheme.copyWith(colorScheme: darkTheme.colorScheme.copyWith(secondary: Colors.indigo))
                    : lightTheme.copyWith(colorScheme: lightTheme.colorScheme.copyWith(secondary: Colors.indigo))) ,darkTheme: isSystemDefault
                  ? darkTheme.copyWith(colorScheme: darkTheme.colorScheme.copyWith(secondary: Colors.indigo)) : null,
                home: Home(),
                navigatorKey: getIt<NavigationService>().navigatorKey,
                routes: {
                  Settings.route: (context) => const Settings(),
                },
              );
            },
          );
        },
      ),
    );
  }
}

