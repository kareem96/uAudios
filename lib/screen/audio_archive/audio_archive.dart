




import 'package:appaudios/utils/constants/constants.dart';
import 'package:appaudios/widget/bottom_media_player.dart';
import 'package:flutter/material.dart';

class AudioArchive extends StatefulWidget {
  static const String route = 'audio';
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
        title: const Text('Audio'),
        backgroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
          return states.contains(MaterialState.scrolledUnder)
              ? ((isDarkTheme)
              ? Colors.grey[700]!
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
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,),
        children: Constants.of(context)!.audio.keys.map((imageAsset) {
          return Card(color:Colors.red);
          /*Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Card(
                elevation: 5,
                shadowColor:
                    isDarkTheme ? Colors.white : Theme.of(context).primaryColor,
                child: InkWell(
                  onTap: () {
                    _navigateAudioArchive(
                        MyConstants.of(context)!.audioArchive[imageAsset]);
                  },
                  child: Ink(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(imageAsset),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );*/
        }).toList(),
      ),
    );
  }

  void _navigateAudioArchive(String? title) {
    bool isMedia = Constants.of(context)!.audioArchiveFids.containsKey(title);
    if(isMedia){
      /*Navigator.push(
          context,
          MaterialPageRoute(

          )
      )*/
    }
  }
}
