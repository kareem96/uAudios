




import 'package:appaudios/utils/constants/constants.dart';
import 'package:appaudios/widget/bottom_media_player.dart';
import 'package:flutter/material.dart';

class AudioArchive extends StatefulWidget {
  static const String route = 'audioArchive';
  const AudioArchive({Key? key}) : super(key: key);

  @override
  _AudioArchiveState createState() => _AudioArchiveState();
}

class _AudioArchiveState extends State<AudioArchive> {
  @override
  Widget build(BuildContext context) {
    ///check if dark theme
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    Color backgroundColor = Theme.of(context).backgroundColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Archives'),
        backgroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
          return states.contains(MaterialState.scrolledUnder)
              ? ((isDarkTheme)
              ?  const Color(0xFFE86413)
              : Theme.of(context).colorScheme.secondary)
              : Theme.of(context).primaryColor;
        }),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: backgroundColor,
        child: _audioArchiveGrid(isDarkTheme),
      ),
      bottomNavigationBar: const BottomMediaPlayer(),
    );
  }

  Widget _audioArchiveGrid(bool isDarkTheme) {
    return Scrollbar(
      child: GridView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        children: Constants.of(context)!.audioArchive.keys.map((imageAsset) {
          return Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Card(
                elevation: 5,
                shadowColor: isDarkTheme ? Colors.white : Theme.of(context).primaryColor,
                child: InkWell(
                  onTap: (){
                    _navigateAudioArchive(Constants.of(context)!.audioArchive[imageAsset]);
                  },
                  child: Ink(),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _navigateAudioArchive(String? title) {

  }
}
