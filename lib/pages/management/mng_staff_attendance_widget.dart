import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_data_not_found.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/components/overlay_for_select_page.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/mng_staff_attendance.dart';

class MngStaffAttendceWidget extends StatefulWidget {
  String selected_date, brcode;
  int flag;

  MngStaffAttendceWidget({
    this.selected_date,
    this.flag,
    this.brcode,
  });

  @override
  _MngStaffAttendceWidgetState createState() => _MngStaffAttendceWidgetState();
}

class _MngStaffAttendceWidgetState extends State<MngStaffAttendceWidget> {
  bool isLoading;
  String loadingText;
  bool isLoaded;
  String dateInState;
  List<StaffAttendace> _staffAttendace = [];
  String designation = "";
  bool isSelected = true;
  String msgKey;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    msgKey = "key_loading_staff_attendance";

    fetchStaffAttendace().then((result) {
      setState(() {
        _staffAttendace = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: RefreshIndicator(
        onRefresh: () async {
          fetchStaffAttendace().then((result) {
            setState(() {
              _staffAttendace = result;
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
      fetchStaffAttendace().then((result) {
        setState(() {
          _staffAttendace = result;
          dateInState = widget.selected_date;
        });
      });
    }
    return _staffAttendace != null && _staffAttendace.length != 0
        ? ListView.separated(
            separatorBuilder: (context, index) {
              return Divider(
                color: Colors.black26,
                height: 0.0,
              );
            },
            itemCount: _staffAttendace.length,
            itemBuilder: (BuildContext context, int index) {
              if (designation == _staffAttendace[index].designation) {
                isSelected = false;
              } else {
                isSelected = true;
              }
              designation = _staffAttendace[index].designation;
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Visibility(
                      visible: isSelected,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          border: Border(
                            bottom: BorderSide(
                              width: 0.8,
                              color: Colors.black12,
                            ),
                          ),
                        ),
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 12.0,
                            bottom: 12.0,
                            left: 8.0,
                            right: 8.0,
                          ),
                          child: Text(
                            StringHandlers.capitalizeWords(
                                _staffAttendace[index].designation),
                            style: Theme.of(context).textTheme.bodyText1.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ), //txt
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
                            child: Text(
                              StringHandlers.capitalizeWords(
                                  _staffAttendace[index].emp_name),
                              style: Theme.of(context).textTheme.bodyText2.copyWith(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _staffAttendace[index].at_status,
                            style: Theme.of(context).textTheme.bodyText2.copyWith(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          )
        : Padding(
            padding: const EdgeInsets.only(top: 30),
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return CustomDataNotFound(
                  description: AppTranslations.of(context)
                      .text("key_loading_staff_attendance"),
                );
              },
            ),
          );
  }

  Future<List<StaffAttendace>> fetchStaffAttendace() async {
    List<StaffAttendace> staffAttendace = [];

    try {
      setState(() {
        isLoading = true;
      });

      /*String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchActivityLogUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              StaffAttendaceUrls.GET_EMPLOYEE_ATTENDACE,
          {
            "report_date": widget.selected_date.toString(),
            'brcode': widget.brcode,
          },
        );

        http.Response response = await http.get(fetchActivityLogUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            '',
            response.body.toString(),
            MessageTypes.WARNING,
          );
          setState(() {
            msgKey = "key_Staff_Attendance";
          });
        } else {
          List responseData = json.decode(response.body);
          staffAttendace = responseData
              .map(
                (item) => StaffAttendace.fromJson(item),
              )
              .toList();
          bool AttendaceOverlay = AppData.getCurrentInstance()
                  .preferences
                  .getBool('attendace_overlay') ??
              false;
          if (!AttendaceOverlay) {
            AppData.getCurrentInstance()
                .preferences
                .setBool("attendace_overlay", true);
            _showOverlay(context);
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

    return staffAttendace;
  }

  void _showOverlay(BuildContext context) {
    Navigator.of(context).push(
      OverlayForSelectPage(
          AppTranslations.of(context).text("key_select_date_from_here")),
    );
  }
}
