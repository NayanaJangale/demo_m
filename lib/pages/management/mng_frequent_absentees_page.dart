import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/custom_tab_view.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/branch.dart';
import 'package:teachers/models/mng_frequent_absentees.dart';

class MngFrequentAbsenteesPage extends StatefulWidget {
  @override
  _MngFrequentAbsenteesPageState createState() =>
      _MngFrequentAbsenteesPageState();
}

class _MngFrequentAbsenteesPageState extends State<MngFrequentAbsenteesPage> {
  bool isLoading;
  String loadingText;
  String studclass = "";
  bool isSelected = true;
  DateTime selectedDate = DateTime.now();
  List<FrequentAbsentStudent> _frequentAbsentsStudents = [];
  List<Branch> branches = [];
  String msgKey;

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
            ),
            buttonTheme: ButtonThemeData(
                textTheme: ButtonTextTheme.primary
            ),
            disabledColor: Colors.orange,
            accentColor: Theme.of(context).primaryColor,
            dialogBackgroundColor:Colors.grey[200],

          ),
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });

    fetchfrequentAbsentStudent().then((result) {
      setState(() {
        _frequentAbsentsStudents = result;
      });
    });
  }

  TextEditingController noOfDaysController = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    msgKey = "key_loading_frequent_absentee";

    fetchBranches().then((result) {
      setState(() {
        this.branches = result;
      });
    });

    fetchfrequentAbsentStudent().then((result) {
      setState(() {
        _frequentAbsentsStudents = result;
      });
    });

    noOfDaysController.text = "1";
  }

  @override
  Widget build(BuildContext context) {
    loadingText = AppTranslations.of(context).text("key_loading");
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: DefaultTabController(
        length: branches.length == 0 ? 1 : branches.length,
        child: Scaffold(
          appBar: AppBar(
            title: CustomAppBar(
              title: AppTranslations.of(context).text("Frequent_Absentees"),
              subtitle: AppTranslations.of(context)
                  .text("key_frequent_absent_subtitle"),
            ),
          ),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              getInputWidgets(context),
              getTabViewWidget(context),
              getDataTable(context),
            ],
          ),
        ),
      ),
    );
  }

  Expanded getDataTable(BuildContext context) {
    return Expanded(
      child: Container(
        child: CustomTabBarView(
          List<Widget>.generate(
            branches.length == 0 ? 1 : branches.length,
            (i) => RefreshIndicator(
              onRefresh: () async {
                fetchfrequentAbsentStudent().then((result) {
                  setState(() {
                    _frequentAbsentsStudents = result;
                  });
                });
              },
              child: _frequentAbsentsStudents != null &&
                      _frequentAbsentsStudents.length != 0
                  ? ListView.separated(
                      shrinkWrap: true,
                      separatorBuilder: (context, index) {
                        return Divider(
                          height: 0.0,
                        );
                      },
                      itemCount: _frequentAbsentsStudents.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (studclass ==
                            _frequentAbsentsStudents[index].class_name +
                                _frequentAbsentsStudents[index].division_name) {
                          isSelected = false;
                        } else {
                          isSelected = true;
                        }

                        studclass = _frequentAbsentsStudents[index].class_name +
                            _frequentAbsentsStudents[index].division_name;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Visibility(
                              visible: isSelected,
                              child: Container(
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    AppTranslations.of(context)
                                            .text("key_class") +
                                        ": ${_frequentAbsentsStudents[index].class_name + " - " + _frequentAbsentsStudents[index].division_name}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 12.0,
                                bottom: 12.0,
                                left: 8.0,
                                right: 8.0,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          StringHandlers.capitalizeWords(
                                              _frequentAbsentsStudents[index]
                                                  .student_name),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .copyWith(
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w600,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: Text(
                                      _frequentAbsentsStudents[index]
                                          .no_of_days
                                          .toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w600,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: 1,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            AppTranslations.of(context).text(msgKey),
                            style: Theme.of(context).textTheme.bodyText2.copyWith(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.2,
                                ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getTabViewWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: TabBar(
        isScrollable: true,
        indicatorColor: Theme.of(context).secondaryHeaderColor,
        tabs: List<Widget>.generate(
          branches.length == 0 ? 1 : branches.length,
          (i) => Tab(
            text: branches.length == 0 ? "" : branches[i].brname,
          ),
        ),
      ),
    );
  }

  Widget getInputWidgets(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          bottom: 15.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              color: Theme.of(context).primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    height: 40.0,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.0,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                      borderRadius: BorderRadius.circular(
                        5.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            AppTranslations.of(context).text("key_date"),
                            style: Theme.of(context).textTheme.bodyText2.copyWith(
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                right: 8.0,
                              ),
                              child: Text(
                                DateFormat('dd-MMM-yyyy').format(selectedDate),
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Colors.white,
                                        ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 8.0,
                            ),
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                _selectDate(context);
                              },
                              child: Icon(
                                Icons.date_range,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 40.0,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.0,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                      borderRadius: BorderRadius.circular(
                        5.0,
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          'No of days',
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                                color: Theme.of(context).secondaryHeaderColor,
                              ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                              controller: noOfDaysController,
                              cursorColor:
                                  Theme.of(context).secondaryHeaderColor,
                              style: Theme.of(context).textTheme.bodyText2.copyWith(
                                    color: Colors.white,
                                  ),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          color: Theme.of(context).secondaryHeaderColor,
                          child: Text(''),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            fetchfrequentAbsentStudent().then((result) {
                              setState(() {
                                _frequentAbsentsStudents = result;
                              });
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              AppTranslations.of(context).text("key_show"),
                              style: Theme.of(context).textTheme.bodyText2.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
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
      ),
    );
  }

  Future<List<FrequentAbsentStudent>> fetchfrequentAbsentStudent() async {
    List<FrequentAbsentStudent> frequentAbsentStudent = [];

    try {
      setState(() {
        isLoading = true;
      });

      /*String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchFrequentAbsenteesUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              FrequentAbsentStudentUrls.GET_FREQUENT_ABSENT_STUDENT,
          {
            "report_date": selectedDate.toIso8601String(),
            "no_of_days": noOfDaysController.text,
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
          setState(() {
            msgKey = "key_frequent_absentee_instruction";
          });
        } else {
          List responseData = json.decode(response.body);
          frequentAbsentStudent = responseData
              .map(
                (item) => FrequentAbsentStudent.fromJson(item),
              )
              .toList();
          setState(() {
            studclass = '';
          });
        }
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_no_internet"),
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.WARNING,
        );
        setState(() {
          msgKey = "key_check_internet";
        });
      }
    } catch (e) {
      FlushbarMessage.show(
        context,
        null,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.WARNING,
      );
      setState(() {
        msgKey = "key_api_error";
      });
    }

    setState(() {
      isLoading = false;
    });

    return frequentAbsentStudent;
  }

  Future<List<Branch>> fetchBranches() async {
    List<Branch> branches = [];

    try {
      setState(() {
        isLoading = true;
      });

      /* String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchBranchUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              BranchUrls.GET_BRANCHES,
          {},
        );

        http.Response response = await http.get(fetchBranchUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            '',
            response.body.toString(),
            MessageTypes.WARNING,
          );
        } else {
          List responseData = json.decode(response.body);
          branches = responseData
              .map(
                (item) => Branch.fromJson(item),
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
        setState(() {
          msgKey = "key_check_internet";
        });
      }
    } catch (e) {
      FlushbarMessage.show(
        context,
        null,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.WARNING,
      );
      setState(() {
        msgKey = "key_api_error";
      });
    }

    setState(() {
      isLoading = false;
    });

    return branches;
  }
}
