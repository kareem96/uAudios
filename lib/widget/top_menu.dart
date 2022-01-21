



import 'dart:io';

import 'package:appaudios/audio_service/service_locator.dart';
import 'package:appaudios/screen/audio_archive/audio_archive.dart';
import 'package:appaudios/screen/settings/settings.dart';
import 'package:appaudios/utils/constants/constants.dart';
import 'package:appaudios/utils/helper/navigator_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TopMenu extends StatefulWidget {
  const TopMenu({Key? key}) : super(key: key);

  @override
  _TopMenuState createState() => _TopMenuState();
}

class _TopMenuState extends State<TopMenu> {
  @override
  Widget build(BuildContext context) {
    double topPadding = MediaQuery.of(context).padding.top + 5;
    double rightPadding = MediaQuery.of(context).size.width * 0.02;
    List<String>? menuTitles = Constants.of(context)!.menuTitles;
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.only(top: topPadding, right: rightPadding),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Material(
              color: Colors.transparent,
              child: IconButton(
                icon: Icon((Platform.isAndroid) ? Icons.search_outlined : CupertinoIcons.search),
                splashRadius: 24,
                iconSize: 30,
                tooltip: 'Search uAudios',
                color: Colors.white,
                onPressed: (){},
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Material(
                color: Colors.transparent,
                child: PopupMenuButton<String>(
                  icon: Icon(
                    (Platform.isAndroid)
                        ? Icons.more_vert
                        : CupertinoIcons.ellipsis,
                    color: Colors.white,
                  ),
                  iconSize: 30,
                  offset: const Offset(-10, 10),
                  itemBuilder: (context) {
                    // Takes list of data from constants
                    return menuTitles.map<PopupMenuEntry<String>>((value) {
                      return PopupMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                        ),
                      );
                    }).toList();
                  },
                  onSelected: (value) {
                    switch (value) {
                      case 'Settings':
                        getIt<NavigationService>().navigateTo(Settings.route);
                        break;
                      case 'Audio Archive':
                        getIt<NavigationService>()
                            .navigateTo(AudioArchive.route);
                        break;
                      case 'Schedule':
                        getIt<NavigationService>()
                            .navigateTo('RadioSchedule.route');
                        break;

                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
