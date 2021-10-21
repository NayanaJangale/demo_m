import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:teachers/components/custom_data_not_found.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/homework_status.dart';

class HomeworkStatusWidget extends StatefulWidget {
  String selected_date, brcode;
  int flag;

  HomeworkStatusWidget({
    this.selected_date,
    this.flag,
    this.brcode,
  });

  @override
  _HomeworkStatusWidgetState createState() => _HomeworkStatusWidgetState();
}

class _HomeworkStatusWidgetState extends State<HomeworkStatusWidget> {
  List<HomeWorkStatus> _homeworkStatus = [];
  String loadingText;
  bool isLoading;
  bool isLoaded;
  String dateInState;
  String msgKey;

  @override
  void initState() {
    isLoading = false;
    loadingText = 'Loading . . .';
    msgKey = "key_loading_homework_status";

    fetchHomeWorkStatus().then((result) {
      setState(() {
        _homeworkStatus = result;
        dateInState = widget.selected_date;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    loadingText = AppTranslations.of(context).text("key_loading");
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: RefreshIndicator(
        onRefresh: () async {
          fetchHomeWorkStatus().then((result) {
            setState(() {
              _homeworkStatus = result;
              dateInState = widget.selected_date;
            });
          });
        },
        child: dataBody(),
      ),
    );
  }

  Widget dataBody() {
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
      fetchHomeWorkStatus().then((result) {
        setState(() {
          _homeworkStatus = result;
          dateInState = widget.selected_date;
        });
      });
    }

    return _homeworkStatus != null && _homeworkStatus.length != 0
        ? ListView(
            children: <Widget>[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowHeight: 40,
                  dataRowHeight: 40,
                  columns: [
                    DataColumn(
                      label: Text(
                        AppTranslations.of(context).text("key_period"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppTranslations.of(context).text("key_teacher_name"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppTranslations.of(context).text("key_subject"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppTranslations.of(context).text("key_status"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppTranslations.of(context).text("key_description"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                  rows: new List<DataRow>.generate(
                    _homeworkStatus.length,
                    (int index) {
                      if (_homeworkStatus[index].teacher_name == '') {
                        return DataRow(
                          selected: true,
                          cells: [
                            DataCell(
                              Text(
                                '${AppTranslations.of(context).text("key_class")} ${_homeworkStatus[index].class_name}',
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                              ),
                            ),
                            DataCell(
                              Text(''),
                            ),
                            DataCell(
                              Text(''),
                            ),
                            DataCell(
                              Text(''),
                            ),
                            DataCell(
                              Text(''),
                            ),
                          ],
                        );
                      } else {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                _homeworkStatus[index].division_name,
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                        ),
                              ),
                            ),
                            DataCell(
                              Text(
                                StringHandlers.capitalizeWords(
                                    _homeworkStatus[index].teacher_name),
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                        ),
                              ),
                            ),
                            DataCell(
                              Text(
                                StringHandlers.capitalizeWords(
                                    _homeworkStatus[index].subject_name),
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                        ),
                              ),
                            ),
                            DataCell(
                              Text(
                                StringHandlers.capitalizeWords(
                                    _homeworkStatus[index].hw_status),
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                        ),
                              ),
                            ),
                            DataCell(
                              Text(
                                _homeworkStatus[index].hw_desc != null
                                    ? _homeworkStatus[index].hw_desc
                                    : 'Not Available',
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                        ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          )
        : Padding(
            padding: const EdgeInsets.only(top: 30),
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return CustomDataNotFound(
                  description: AppTranslations.of(context)
                      .text("key_homework_status_instruction"),
                );
              },
            ),
          );
  }

  Future<List<HomeWorkStatus>> fetchHomeWorkStatus() async {
    List<HomeWorkStatus> homeWorkStatus = [];
    List<HomeWorkStatus> raw_homeWork_status = [];

    try {
      setState(() {
        isLoading = true;
      });

      /*String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchHomeworkStatusUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              HomeWorkStatusUrls.GET_HOMEWORK_STATUS,
          {
            "report_date": widget.selected_date,
            'brcode': widget.brcode,
          },
        );

        Response response = await get(fetchHomeworkStatusUri);

        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body.toString(),
            MessageTypes.WARNING,
          );
          setState(() {
            msgKey = "key_homework_status_instruction";
          });
        } else {
          List responseData = json.decode(response.body);
          raw_homeWork_status = responseData
              .map(
                (item) => HomeWorkStatus.fromJson(item),
              )
              .toList();

          String lClass = '';
          for (int i = 0; i < raw_homeWork_status.length; i++) {
            if (lClass == '') {
              setState(() {
                lClass = raw_homeWork_status[i].class_name;

                homeWorkStatus.add(
                  HomeWorkStatus(
                    class_name: raw_homeWork_status[i].class_name,
                    teacher_name: '',
                  ),
                );
              });
            } else {
              setState(() {
                lClass = raw_homeWork_status[i - 1].class_name;
              });
            }

            if (lClass == raw_homeWork_status[i].class_name) {
              setState(() {
                homeWorkStatus.add(raw_homeWork_status[i]);
              });
            } else {
              setState(() {
                homeWorkStatus.add(
                  HomeWorkStatus(
                    class_name: raw_homeWork_status[i].class_name,
                    teacher_name: '',
                  ),
                );
                homeWorkStatus.add(raw_homeWork_status[i]);
              });
            }
          }
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

    return homeWorkStatus;
  }
}
