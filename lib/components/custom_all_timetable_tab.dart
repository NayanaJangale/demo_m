import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/teacher_time_table.dart';

class NestedTabBar extends StatefulWidget {
  final List<TeacherTimeTable> list;

  NestedTabBar({this.list});
  @override
  _NestedTabBarState createState() => _NestedTabBarState();
}

class _NestedTabBarState extends State<NestedTabBar>
    with TickerProviderStateMixin {
  bool isLoading;
  String loadingText;
  List<TeacherTimeTable> teacherTimeTable = [];

  List<String> days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  List<Color> freePeriodCOlors;

  List<Color> busyPeriodCOlors;

  TabController _nestedTabController;

  @override
  void initState() {
    super.initState();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';

    _nestedTabController = new TabController(length: days.length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _nestedTabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    teacherTimeTable = widget.list;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: <Widget>[
        TabBar(
          
          controller: _nestedTabController,
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.black45,
          isScrollable: true,
          tabs: List<Widget>.generate(
            days.length == 0 ? 1 : days.length,
            (i) => Tab(
              text: days.length == 0 ? "" : days[i],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _nestedTabController,
            children: List<Widget>.generate(
              days.length,
              (i) => getPeriodList(days[i]),
            ),
          ),
        )
      ],
    );
  }

  Widget getPeriodList(String day) {
    String periodTitle = '', periodTime = '', periodClass = '';
    return teacherTimeTable != null && teacherTimeTable.length != 0
        ? ListView.separated(
            separatorBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(
                  left: 15.0,
                  top: 0.0,
                  bottom: 0.0,
                ),
                child: Divider(
                  height: 0.0,
                ),
              );
            },
            itemCount: teacherTimeTable.length,
            itemBuilder: (BuildContext context, int index) {
              freePeriodCOlors = [
                Colors.green[300],
                Colors.green[400],
                Colors.green,
              ];

              busyPeriodCOlors = [
                Theme.of(context).primaryColorLight,
                Theme.of(context).accentColor,
                Theme.of(context).primaryColor,
              ];

              switch (day) {
                case "SUN":
                  Map<String, dynamic> periodData =
                      getTitleAndClass(teacherTimeTable[index].Sunday);
                  periodTitle = periodData['periodTitle'];
                  periodClass = periodData['periodClass'];
                  break;
                case "MON":
                  Map<String, dynamic> periodData =
                      getTitleAndClass(teacherTimeTable[index].Monday);
                  periodTitle = periodData['periodTitle'];
                  periodClass = periodData['periodClass'];
                  break;
                case "TUE":
                  Map<String, dynamic> periodData =
                      getTitleAndClass(teacherTimeTable[index].Tuesday);
                  periodTitle = periodData['periodTitle'];
                  periodClass = periodData['periodClass'];
                  break;
                case "WED":
                  Map<String, dynamic> periodData =
                      getTitleAndClass(teacherTimeTable[index].Wednesday);
                  periodTitle = periodData['periodTitle'];
                  periodClass = periodData['periodClass'];
                  break;
                case "THU":
                  Map<String, dynamic> periodData =
                      getTitleAndClass(teacherTimeTable[index].Thursday);
                  periodTitle = periodData['periodTitle'];
                  periodClass = periodData['periodClass'];
                  break;
                case "FRI":
                  Map<String, dynamic> periodData =
                      getTitleAndClass(teacherTimeTable[index].Friday);
                  periodTitle = periodData['periodTitle'];
                  periodClass = periodData['periodClass'];
                  break;
                case "SAT":
                  Map<String, dynamic> periodData =
                      getTitleAndClass(teacherTimeTable[index].Saturday);
                  periodTitle = periodData['periodTitle'];
                  periodClass = periodData['periodClass'];
                  break;
                default:
                  periodClass = '';
                  periodTitle = 'Free Period';
                  break;
              }
              periodTime = '${teacherTimeTable[index].period_desc}';

              return Padding(
                padding: const EdgeInsets.only(
                  top: 6,
                  bottom: 9,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 5.0,
                              right: 10.0,
                            ),
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 3.0,
                                  bottom: 3.0,
                                ),
                                child: Text(''),
                              ),
                              width: 4.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment
                                      .bottomRight, // 10% of the width, so there are ten blinds.
                                  colors: periodClass != ''
                                      ? busyPeriodCOlors
                                      : freePeriodCOlors, // whitish to gray
                                  tileMode: TileMode
                                      .repeated, // repeats the gradient over the canvas
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        StringHandlers.capitalizeWords(
                                            periodTitle),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .copyWith(
                                              color: periodClass != ''
                                                  ? Colors.black87
                                                  : Colors.black54,
                                              fontWeight: FontWeight.w500,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      periodClass,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                            color: periodClass != ''
                                                ? Colors.black54
                                                : Colors.black45,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    periodClass != ''
                                        ? Icon(
                                            Icons.navigate_next,
                                            color: Colors.grey,
                                          )
                                        : Text(''),
                                  ],
                                ),
                                Text(
                                  periodTime,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(
                                        color: periodClass != ''
                                            ? Colors.black54
                                            : Colors.black45,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        : Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              AppTranslations.of(context).text("key_timetable_not_available"),
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
            ),
          );
  }

  getTitleAndClass(String rawPeriodData) {
    String periodTitle, periodClass;
    if (rawPeriodData != null && rawPeriodData.trim() != '') {
      if (rawPeriodData.contains(':')) {
        periodTitle = rawPeriodData.split(':')[0];
        periodClass = rawPeriodData.split(':')[1];
      } else {
        periodTitle = rawPeriodData;
        periodClass = '';
      }
    } else {
      periodTitle = 'Free Period';
      periodClass = '';
    }

    return {
      'periodTitle': periodTitle,
      'periodClass': periodClass,
    };
  }
}
