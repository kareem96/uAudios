
import 'package:appaudios/bloc/radio/radio_index_bloc.dart';
import 'package:appaudios/bloc/radio_schedule/time_zone_bloc.dart';
import 'package:appaudios/screen/schedule/schedule_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RadioSchedule extends StatefulWidget {
  static const route = 'schedule';
  const RadioSchedule({Key? key}) : super(key: key);

  @override
  _RadioScheduleState createState() => _RadioScheduleState();
}

class _RadioScheduleState extends State<RadioSchedule> {
  @override
  Widget build(BuildContext context) {
    return Consumer<RadioIndexBloc>(
      builder: (context, _radioIndexBloc, child){
        return StreamBuilder<int?>(
          stream: _radioIndexBloc.radioIndexStream as Stream<int?>?,
          builder: (context, snapshot){
            int radioStreamIndex = snapshot.data ?? -1;
            if(radioStreamIndex == 3) radioStreamIndex = 0;
            return Consumer<TimeZoneBloc>(
                builder: (context, _timeZoneBLoc, child){
                  return StreamBuilder<String?>(
                      stream: _timeZoneBLoc.timeZoneStream as Stream<String?>?,
                      builder: (context, snapshot){
                        String timeZone = snapshot.data ?? 'INDIA';
                        return ScheduleData(
                            radioStreamIndex: radioStreamIndex,
                            timeZone: timeZone,
                            timeZoneBloc: _timeZoneBLoc,
                        );
                      }
                  );
                }
            );
          },
        );
      },
    );
  }
}