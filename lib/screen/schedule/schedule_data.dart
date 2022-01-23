





import 'dart:io';

import 'package:appaudios/bloc/radio_schedule/time_zone_bloc.dart';
import 'package:appaudios/utils/constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

class ScheduleData extends StatefulWidget {
  final int? radioStreamIndex;
  final String? timeZone;
  final TimeZoneBloc timeZoneBloc;
  const ScheduleData({
    Key? key,
    required this.timeZone,
    required this.timeZoneBloc,
    required this.radioStreamIndex
  }) : super(key: key);

  @override
  _ScheduleDataState createState() => _ScheduleDataState();
}

class _ScheduleDataState extends State<ScheduleData> {
  ///variable to show the loading screen
  bool _isLoading = true;
  final DateTime now = DateTime.now();
  DateTime? selectedDate;

  ///below are used to hide/show the selected widget
  ScrollController? _scrollController;
  bool _showDropDown = true;
  bool _isScrollingDown = false;

  ///use for the initial build
  int? oldStreamId = 0;
  final List<int> firstStreamMap = [1,2,3,1,6,5];

  ///the url with all the parameters(a unique url)
  final String baseUrl = '';
  ///
  String streamId = '';
  ///
  String selectedStream = '';
  ///select time zone id
  String zoneId = '';

  ///
  List<List<String>> _finalTableData = [
    ['null']
  ];

  ///
  String _finalLocalTime = '';

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    selectedDate = now;
    selectedStream = 'Asia Stream';
    oldStreamId = widget.radioStreamIndex;
    _scrollController = ScrollController();
    _scrollController!.addListener(_scrollListener);
  }
  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    Color backgroundColor = Theme.of(context).backgroundColor;
    double height = MediaQuery.of(context).size.height;
    bool isSmallerScreen = (height * 0.1 < 30);
    ///handle the screen for the initial build
    _handleFirstBuild();
    ///handle stream name display
    _handleStreamNam();
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule'),
        backgroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states){
          return states.contains(MaterialState.scrolledUnder)
              ?((isDarkTheme)
              ? Colors.grey[700]!
              : Theme.of(context).colorScheme.secondary)
              : Theme.of(context).primaryColor;
        }),
        actions: <Widget>[
          IconButton(
            icon: Icon((Platform.isAndroid)
                ? Icons.date_range_outlined
                : CupertinoIcons.calendar),
            tooltip: 'Selected date',
            splashRadius: 24,
            onPressed: (){},
          )
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: backgroundColor,
        child: Column(
          children: [
            if(!isSmallerScreen)
              AnimatedContainer(
                height: _showDropDown ? height * 0.19 :0,
                duration: _showDropDown ? const Duration(microseconds: 200) : Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        height: _showDropDown ? height * 0.045 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                'Date: ${DateFormat('MMMM dd, yyyy').format(selectedDate!)}',
                                style: TextStyle(
                                  fontSize: 19,
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontWeight: FontWeight.w600
                                )
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
          ],
        )
      ),
    );
  }

  void _scrollListener() {
    int sensitivity = 8;
    if(_scrollController!.offset > sensitivity || _scrollController!.offset < -sensitivity){
      if(_scrollController!.position.userScrollDirection == ScrollDirection.reverse){
        if(!_isScrollingDown){
          _isScrollingDown = true;
          _showDropDown = false;
          setState(() {});
        }
      }
      if(_scrollController!.position.userScrollDirection == ScrollDirection.forward){
        if(_isScrollingDown){
          _isScrollingDown = false;
          _showDropDown = true;
          setState(() {});
        }
      }
    }
  }

  void _handleFirstBuild() {
    if(widget.radioStreamIndex == oldStreamId){
      return;
    }
    oldStreamId = widget.radioStreamIndex;
    streamId = '${firstStreamMap[widget.radioStreamIndex!]}';
    zoneId = '${Constants.of(context)!.timeZones[widget.timeZone]}';
    _updateUrl(selectedDate!);
  }

  void _updateUrl(DateTime date) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    var data = <String, dynamic>{};
    data['streamId'] = streamId;
    data['zoneId'] = zoneId;
    data['currentDate'] = formattedDate;
    data['dChange'] = '1';
  }

  void _handleStreamNam() {
    if(streamId == '') return;
    int index = firstStreamMap.indexOf(int.parse(streamId));
    selectedStream = Constants.of(context)!.radioStream.keys.toList()[index];
  }

}
