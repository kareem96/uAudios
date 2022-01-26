





import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:appaudios/bloc/radio_schedule/time_zone_bloc.dart';
import 'package:appaudios/screen/media/media.dart';
import 'package:appaudios/utils/constants/constants.dart';
import 'package:appaudios/widget/bottom_media_player.dart';
import 'package:appaudios/widget/no_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

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
  final String baseUrl = 'https://radiosai.org/program/Index.php';
  ///
  String finalUrl ='';
  ///
  String streamId = '';
  ///
  String selectedStream = '';
  ///select time zone id
  String zoneId = '';

  List<String> _finalTableHead = [];

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
    _handleStreamName();
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
            onPressed: () => (Platform.isAndroid) ? _selectedDate(context) : _selectedDateIOS(context),
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
                duration: _showDropDown ? const Duration(microseconds: 200) : const Duration(milliseconds: 300),
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
                      ),
                      AnimatedContainer(
                        height: _showDropDown ? height * 0.035 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: const [
                              Flexible(
                                // flex: 1,
                                  child: Center(
                                    child: FittedBox(
                                      fit: BoxFit.fitHeight,
                                      child: Text('Select Zone', style: TextStyle(fontSize: 18),),
                                    ),
                                  )
                              ),
                              Flexible(
                                // flex: 1,
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.fitHeight,
                                    child: Text('Select Stream', style: TextStyle(fontSize: 18),),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        height: _showDropDown ? height * 0.08 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Row(
                          children: [
                            Flexible(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                    child: _timeZoneDropDown(isDarkTheme),
                                  ),
                                )
                            ),
                            Flexible(child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: _streamDropDown(isDarkTheme),
                              ),
                            ))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: Stack(
                children: [
                  if(_isLoading == false && _finalTableData[0][0] != 'null' && _finalTableData[0][0] != 'timeout')
                    RefreshIndicator(
                      onRefresh: _refresh,
                      child: Scrollbar(
                        radius: const Radius.circular(8),
                        controller: _scrollController,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics()),
                          child: ConstrainedBox(
                            // have minimum height to reload even when 1 item is present
                            constraints: BoxConstraints(
                                minHeight: (isSmallerScreen || !_showDropDown)
                                    ? MediaQuery.of(context).size.height * 0.9
                                    : MediaQuery.of(context).size.height *
                                    0.75),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: Card(
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(18)),
                                ),
                                elevation: 1,
                                color: isDarkTheme ? Colors.grey[800] : Colors.grey[200],
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    primary: false,
                                    padding: const EdgeInsets.only(top: 2, bottom: 2),
                                    itemCount: _finalTableData.length,
                                    itemBuilder: (context, index) {
                                      List<String> rowData = _finalTableData[index];
                                      String localTime = '${rowData[1]} $_finalLocalTime';
                                      String gmtTime = '${rowData[2]} GMT';
                                      String duration = '${rowData[4]} min';
                                      List<String> mainRowData = rowData[3].split('<split>');
                                      String category = mainRowData[0];
                                      String programe = mainRowData[1];
                                      String fids = mainRowData[2].substring(1, mainRowData[2].length - 1);
                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 4, right: 4),
                                            child: Card(
                                              elevation: 0,
                                              color: isDarkTheme ? Colors.grey[800] : Colors.grey[200],
                                              child: InkWell(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                                                  child: Center(
                                                    child: ListTile(
                                                      title: Text(
                                                        category,
                                                        style: TextStyle(
                                                          color: Theme.of(context).secondaryHeaderColor,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      subtitle: Text(programe),
                                                      trailing: Column(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        children: [
                                                          Text(localTime, style: TextStyle(color: isDarkTheme ? Colors.grey[300] : Colors.grey[700],),),
                                                          Text(duration, style: TextStyle(color: isDarkTheme ? Colors.grey[300] : Colors.grey[700],),),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                borderRadius: BorderRadius.circular(8.0),
                                                focusColor: isDarkTheme ? Colors.grey[700] : Colors.grey[300],
                                                onTap: () {
                                                  if (fids != '') {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => Media(fids: fids)));
                                                  } else {
                                                    _showSnackBar(
                                                        context,
                                                        'No media found!',
                                                        const Duration(seconds: 1));
                                                  }
                                                },
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(8.0),
                                              ),
                                            ),
                                          ),
                                          if (index != _finalTableData.length - 1)
                                            const Divider(height: 2, thickness: 1.5,),
                                        ],
                                      );
                                    }),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if(_finalTableData[0][0] == 'null' && _isLoading == false)
                    NoData(
                      backgroundColor: backgroundColor,
                      text: 'No data Available,\n check your internet or try again',
                      onPressed: () {
                        _isLoading = true;
                        _updateUrl(selectedDate!);
                      },
                    ),
                  if(_finalTableData[0][0] == 'timeout' && _isLoading == false)
                    NoData(
                        backgroundColor: backgroundColor,
                        text: 'No data Available,\n check your internet or try again',
                        onPressed: (){
                          setState(() {
                            _isLoading = true;
                            _updateUrl(selectedDate!);
                          });
                        }
                    ),
                  if(_isLoading)
                    Container(
                      color: backgroundColor,
                      child: Center(
                        child: _showLoading(isDarkTheme),
                      ),
                    )
                ]
              ),
            )
          ],
        )
      ),
      bottomNavigationBar: const BottomMediaPlayer(),
    );
  }




  void _updateUrl(DateTime date) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    var data = <String, dynamic>{};
    data['streamId'] = streamId;
    data['zoneId'] = zoneId;
    data['currentDate'] = formattedDate;
    data['dchange'] = '1';

    String url = '$baseUrl?streamId=${data['streamId']}&zoneId=${data['zoneId']}&currentDate=${data['currentDate']}';
    finalUrl = url;
    _getData(data);
  }

  _getData(Map<String, dynamic> formData) async{
    String tempResponse = '';
    var fileInfo = await DefaultCacheManager().getFileFromCache(finalUrl);
    if(fileInfo == null) {
      // get data from online if not present in cache
      http.Response response;
      try {
        response = await http
            .post(Uri.parse(baseUrl), body: formData)
            .timeout(const Duration(seconds: 40));
      } on SocketException catch (_) {
        setState(() {
          // if there is no internet
          _finalTableData = [
            ['null']
          ];
          finalUrl = '';
          _isLoading = false;
        });
        return;
      } on TimeoutException catch (_) {
        setState(() {
          // if timeout
          _finalTableData = [
            ['timeout']
          ];
          finalUrl = '';
          _isLoading = false;
        });
        return;
      }
      tempResponse = response.body;

      // put data into cache after getting from internet
      List<int> list = tempResponse.codeUnits;
      Uint8List fileBytes = Uint8List.fromList(list);
      DefaultCacheManager().putFile(finalUrl, fileBytes);
    }else{
        tempResponse = fileInfo.file.readAsStringSync();
    }
    _parseData(tempResponse);
  }

  _parseData(String response) {
    var document = parse(response);
    var table = document.getElementById('sch');
    // parsing table heads
    List<String> tableHead = [];
    for (int i = 1; i < 6; i++) {
      tableHead.add(table!.getElementsByTagName('th')[i].text);
      var stringLength = tableHead[i - 1].length;
      tableHead[i - 1] = tableHead[i - 1].substring(4, stringLength - 3);
      tableHead[i - 1] = tableHead[i - 1].replaceAll('\n', ' ');
      tableHead[i - 1] = tableHead[i - 1].replaceAll('\t', '');
      tableHead[i - 1] = tableHead[i - 1].trim();
    }

    // getting the local time
    String localTime = tableHead[1].substring(4);
    localTime = localTime.replaceAll('(', '');
    localTime = localTime.replaceAll(')', '');
    localTime = localTime.trim();

    // parsing table data
    List<List<String>> tableData = [];
    int dataLength = table!.getElementsByTagName('tr').length - 1;
    if (dataLength == 0) {
      tableData = [
        ['null']
      ];
      setState(() {
        // set the data
        _finalTableHead = tableHead;
        _finalTableData = tableData;
        _finalLocalTime = localTime;

        // loading is done
        _isLoading = false;
      });
      return;
    }
    for (int i = 1; i <= dataLength; i++) {
      List<String> tempList = [];
      var rowData = table.getElementsByTagName('tr')[i].getElementsByTagName('td');
      for (int j = 1; j < 6; j++) {
        if (j != 4) {
          tempList.add(rowData[j].text);
          var stringLength = tempList[j - 1].length;
          tempList[j - 1] = tempList[j - 1].substring(4, stringLength - 3);
          tempList[j - 1] = tempList[j - 1].replaceAll('\n', ' ');
          tempList[j - 1] = tempList[j - 1].replaceAll('\t', '');
          tempList[j - 1] = tempList[j - 1].trim();
        } else {
          // if j is 4, parse it differently

          String tempText = rowData[j].text;
          var stringLength = tempText.length;
          tempText = tempText.substring(4, stringLength - 3);
          tempText = tempText.replaceAll('\n', ' ');
          tempText = tempText.replaceAll('\t', '');
          tempText = tempText.trim();
          tempText = tempText.replaceFirst(' ', '<split>');

          // remove click here tags
          int clickHere = tempText.indexOf('- Click here');
          if (clickHere > 0) {
            int clickHereEnd = tempText.indexOf('-', clickHere + 2);
            tempText = tempText.substring(0, clickHere) +
                tempText.substring(clickHereEnd);
          }
          // TODO: get pdf scripts for discourse stream (click here tags)

          String? fids = '';
          if (rowData[j].getElementsByTagName('input').isNotEmpty) {
            fids = rowData[j].getElementsByTagName('input')[0].attributes['value'];
          }
          tempText += '<split>[$fids]';

          tempList.add(tempText);
        }
      }
      tableData.add(tempList);
    }

    if (tableData == null || tableData.isEmpty) {
      tableData = [
        ['null']
      ];
    }

    setState(() {
      // set the data
      _finalTableHead = tableHead;
      _finalTableData = tableData;
      _finalLocalTime = localTime;

      // loading is done
      _isLoading = false;
    });
  }

  Future<void> _selectedDate(BuildContext context) async{
    final DateTime? picked = await showDatePicker(
        context: context,
        firstDate: DateTime(2021, 01, 01),
        initialDate: selectedDate!,
        lastDate: now.add(const Duration(days: 1)),
    );
    if(picked != null && picked != selectedDate){
      setState(() {
        _isLoading = true;
        selectedDate = picked;
        _updateUrl(selectedDate!);
      });
    }
  }

  void _selectedDateIOS(BuildContext context){
    DateTime? _picked;
    showCupertinoModalPopup(
        context: context,
        builder: (_) => Container(
          color: Theme.of(context).backgroundColor,
          height: 200,
          child: Column(
            children: [
              SizedBox(
                height: 120,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: selectedDate,
                  minimumDate: DateTime(2021, 01, 01),
                  maximumDate: now.add(const Duration(days: 1)),
                  onDateTimeChanged: (picked){
                    _picked = picked;
                  },
                ),
              ),
              SizedBox(
                height: 70,
                child: CupertinoButton(
                  child: const Text('Oke'),
                  onPressed: (){
                    if(_picked != null && _picked != selectedDate){
                      setState(() {
                        _isLoading = true;
                        selectedDate = _picked;
                        _updateUrl(selectedDate!);
                      });
                    }
                    Navigator.of(context).maybePop();
                  },
                ),
              )
            ],
          ),
        )
    );
  }

  Future<void> _refresh() async{
    await DefaultCacheManager().removeFile(finalUrl);
    setState(() {
      _isLoading = true;
      _updateUrl(selectedDate!);
    });
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

  void _handleStreamName() {
    if(streamId == '') return;
    int index = firstStreamMap.indexOf(int.parse(streamId));
    selectedStream = Constants.of(context)!.radioStream.keys.toList()[index];
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

  Widget _streamDropDown(bool isDarkTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDarkTheme ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(10)
      ),
      child: DropdownButton<String>(
        value: selectedStream,
        items: Constants.of(context)!.scheduleStream.keys.map((String value){
          return DropdownMenuItem(
            value: value,
            child: Text(value),
          );
        }).toList(),
        underline: const SizedBox(),
        iconSize: 20,
        icon: const Icon(Icons.arrow_drop_down_circle_outlined),
        isExpanded: true,
        onChanged: (value){
          if(value != selectedStream){
            setState(() {
              _isLoading = true;
              streamId = '${Constants.of(context)!.scheduleStream[value]}';
              _updateUrl(selectedDate!);
            });
          }
        },
      ),
    );
  }

  Widget _timeZoneDropDown(bool isDarkTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDarkTheme ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        value: widget.timeZone,
        items: Constants.of(context)!.timeZones.keys.map((String value){
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down_circle_outlined),
        iconSize: 20,
        isExpanded: true,
        onChanged: (value){
          if(value != widget.timeZone){
            setState(() {
              _isLoading = true;
              widget.timeZoneBloc.changeTimeZone.add(value);
              zoneId = '${Constants.of(context)!.timeZones[value]}';
              _updateUrl(selectedDate!);
            });
          }
        },
      ),
    );
  }

  void _showSnackBar(BuildContext context, String text, Duration duration) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      duration: duration,
    ));
  }

  Widget _showLoading(bool isDarkTheme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Shimmer.fromColors(
        baseColor: isDarkTheme ? Colors.grey : Colors.white24,
        highlightColor: isDarkTheme ? Colors.grey : Colors.white24,
        enabled: true,
        child: Column(
          children: [
            for(int i = 0; i < 5; i++) _shimmerContent(),
          ],
        ),
      ),
    );
  }

  Widget _shimmerContent() {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    width: width * 0.4,
                    height: 9,
                    color: Colors.white,
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    width: width * 0.6,
                    height: 8,
                    color: Colors.white,
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    width: width * 0.6,
                    height: 8,
                    color: Colors.white,
                  ),
                  Container(
                    width: width * 0.6,
                    height: 8,
                    color: Colors.white,
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    width: width * 0.2,
                    height: 8,
                    color: Colors.white,
                  ),
                  Container(
                    width: width * 0.2,
                    height: 8,
                    color: Colors.white,
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
