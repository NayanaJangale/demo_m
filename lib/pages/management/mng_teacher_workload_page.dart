import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/internet_connection.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/mng_teacher_workload.dart';

class MngTeacherWorkloadWidget extends StatefulWidget {
  String selected_date,brcode;

  MngTeacherWorkloadWidget({
    this.selected_date,
    this.brcode
  });

  @override
  _MngTeacherWorkloadWidgetState createState() =>
      _MngTeacherWorkloadWidgetState();
}

class _MngTeacherWorkloadWidgetState extends State<MngTeacherWorkloadWidget> {
  bool isLoading, isDescGroup;
  String loadingText, period_desc;
  bool isLoaded;
  String dateInState;

  List<TeacherWorkLoad> _teacherWorkLoad = [];

  List<String> days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.isLoading = false;
    this.loadingText = 'Loading . . .';

    fetchTeacherWorkLoad().then((result) {
      setState(() {
        _teacherWorkLoad = result;
        period_desc = _teacherWorkLoad[0].period_desc;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: days.length,
      initialIndex: DateTime.now().weekday-1,
      child: RefreshIndicator(
        onRefresh: () async {
          fetchTeacherWorkLoad().then((result) {
            setState(() {
              _teacherWorkLoad = result;
              period_desc = _teacherWorkLoad[0].period_desc;
            });
          });
        },
        child: Column(
          children: <Widget>[
            TabBar(
              isScrollable: true,
              indicatorColor: Theme.of(context).primaryColorDark,
              labelStyle: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Theme.of(context).primaryColorDark,
                    fontWeight: FontWeight.w500,
                  ),
              labelColor: Theme.of(context).primaryColorDark,
              unselectedLabelColor: Theme.of(context).primaryColorLight,
              tabs: List<Widget>.generate(
                days.length,
                (i) => Tab(
                  text: days.length == 0 ? "" : days[i],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: List<Widget>.generate(
                  days.length,
                  (i) => getTeacherWorkLoadTAbleView(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getTeacherWorkLoadTAbleView() {
    if (widget.selected_date == dateInState) {
      setState(() {
        isLoaded = false;
      });
    } else {
      setState(() {
        isLoaded = true;
      });
    }
    if (isLoaded) {
      fetchTeacherWorkLoad().then((result) {
        setState(() {
          _teacherWorkLoad = result;
          period_desc = _teacherWorkLoad[0].period_desc;
          dateInState = widget.selected_date;
        });
      });
    }
    return ListView.separated(
      separatorBuilder: (context, index) {
        return Divider(
          height: 0.0,
        );
      },
      itemCount: _teacherWorkLoad.length,
      itemBuilder: (BuildContext context, int index) {
        if (period_desc == _teacherWorkLoad[index].period_desc && index != 0) {
          isDescGroup = false;
        } else {
          isDescGroup = true;
        }

        period_desc = _teacherWorkLoad[index].period_desc;
        return Column(
          children: <Widget>[
            Visibility(
              visible: isDescGroup,
              child: Container(
                width: double.infinity,
                color: Colors.black12,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _teacherWorkLoad[index].period_desc,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Theme.of(context).primaryColorDark,
                        ),
                  ),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            StringHandlers.capitalizeWords(
                              _teacherWorkLoad[index].emp_name,
                            ),
                            style: Theme.of(context).textTheme.bodyText1.copyWith(
                                  color: Colors.black38,
                                fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        Text(
                          _teacherWorkLoad[index].activity,
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                            fontWeight: FontWeight.w500,
                                color:
                                    _teacherWorkLoad[index].activity != "Free"
                                        ? Colors.black38
                                        : Colors.green,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  Future<List<TeacherWorkLoad>> fetchTeacherWorkLoad() async {
    List<TeacherWorkLoad> teacherWorkLoad = [];

    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchFrequentAbsenteesUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              TeacherWorkLoadUrls.GET_DaywiseTeacherLoad,
          {
            "report_date": widget.selected_date,
            'brcode': widget.brcode,
          },
        );

        http.Response response = await http.get(fetchFrequentAbsenteesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            '',
            response.body.toString(),
            MessageTypes.WARNING,
          );
        } else {
          List responseData = json.decode(response.body);
          teacherWorkLoad = responseData
              .map(
                (item) => TeacherWorkLoad.map(item),
          )
              .toList();
        }
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_no_internet"),
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.WARNING,
        );
      }
    } catch (e) {
      FlushbarMessage.show(
        context,
        null,
        e.toString(),
        //AppTranslations.of(context).text("key_api_error"),
        MessageTypes.WARNING,
      );
    }

    setState(() {
      isLoading = false;
    });
    return teacherWorkLoad;
  }
}



