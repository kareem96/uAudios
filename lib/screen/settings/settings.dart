


import 'package:appaudios/screen/settings/general/app_theme.dart';
import 'package:appaudios/widget/settings/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'general/starting_radio_stream.dart';

class Settings extends StatefulWidget {
  static const String route = 'settings';
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  PackageInfo _packageInfo = PackageInfo(
      appName: 'appName',
      packageName: 'packageName',
      version: 'version',
      buildNumber: 'buildNumber'
  );

  final EdgeInsetsGeometry _contentPadding = const EdgeInsets.only(left: 20);

  @override
  void initState(){
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async{
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }
  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text('Settings'),
        backgroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states){
          return states.contains(MaterialState.scrolledUnder)
              ? ((isDarkTheme) ? Color(0xfffffff) : Theme.of(context).colorScheme.secondary)
              : Theme.of(context).primaryColor;
        }),
      ),
      body: Container(
        color: Theme.of(context).backgroundColor,
        height: MediaQuery.of(context).size.height,
        child: Scrollbar(
          radius: const Radius.circular(8),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  _generateSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _generateSection() {
    return SettingsSection(
      title: 'General Settings',
      child: Column(
        children: [
          StartingRadioStream(
            contentPadding: _contentPadding
          ),
          AppTheme(contentPadding: _contentPadding)
        ],
      ),
    );
  }
}
