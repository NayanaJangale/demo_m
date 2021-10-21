import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/custom_tab_view.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/menu_constants.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/branch.dart';
import 'package:teachers/pages/management/mng_activity_log_widget.dart';
import 'package:teachers/pages/management/mng_attendance_entry_status_widget.dart';
import 'package:teachers/pages/management/mng_balance_sheet_widget.dart';
import 'package:teachers/pages/management/mng_balances_widget.dart';
import 'package:teachers/pages/management/mng_employee_leave_widget.dart';
import 'package:teachers/pages/management/mng_homework_status_widget.dart';
import 'package:teachers/pages/management/mng_paid_fees_widget.dart';
import 'package:teachers/pages/management/mng_pending_fees_widget.dart';
import 'package:teachers/pages/management/mng_staff_attendance_widget.dart';
import 'package:teachers/pages/management/mng_student_attendance_widget.dart';
import 'package:teachers/pages/management/mng_teacher_workload_page.dart';

class MngBrancwiseReportFormat extends StatefulWidget {
  String menuName;

  MngBrancwiseReportFormat({
    this.menuName,
  });

  @override
  _MngBrancwiseReportFormatState createState() =>
      _MngBrancwiseReportFormatState();
}

class _MngBrancwiseReportFormatState extends State<MngBrancwiseReportFormat> with SingleTickerProviderStateMixin {

  bool isLoading;
  String loadingText, subtitle = "";

  GlobalKey<ScaffoldState> _branchwiseReportPageGK;
  DateTime reportDate;
  int flag = 0;
  List<Branch> _branches = [];

  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    this.reportDate = DateTime.now();

    _branchwiseReportPageGK = GlobalKey<ScaffoldState>();

   // _tabController = new TabController(vsync: this, length: _branches.length);

    fetchBranches().then((result) {
      setState(() {
        this._branches = result;
        flag = 1;
      });
    });
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: reportDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
            ),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            disabledColor: Colors.orange,
            accentColor: Theme.of(context).primaryColor,
            dialogBackgroundColor: Colors.grey[200],
          ),
          child: child,
        );
      },
    );
    if (picked != null && picked != reportDate)
      setState(() {
        reportDate = picked;
        subtitle = AppTranslations.of(context).text("key_report_date") +
            " : " +
            DateFormat('dd-MMM-yyyy').format(reportDate);
        flag = flag + 1;
        // call method to refresh
      });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      subtitle = DateFormat('dd-MMM-yyyy').format(reportDate);
    });
    loadingText = AppTranslations.of(context).text("key_loading");
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: DefaultTabController(
        length: _branches.length,
        child: Scaffold(
          key: _branchwiseReportPageGK,
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppTranslations.of(context).text(
                    widget.menuName.replaceAll(' ', '_'),
                  ),
                  style: Theme.of(context)
                      .appBarTheme
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.white),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .appBarTheme
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.white),
                ),
              ],
            ),
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.date_range),
                  onPressed: () {
                    _selectDate(context);
                  }),
            ],
            bottom: TabBar(
              isScrollable: true,
              indicatorColor: Theme.of(context).secondaryHeaderColor,
             // controller: _tabController,
              tabs: List<Widget>.generate(
                _branches.length,
                (i) => Tab(
                  text: _branches[i].brname,
                ),
              ),
            ),
            elevation: 0,
          ),
          body: TabBarView(
            children:List<Widget>.generate(
              _branches.length,
                  (i) => selectPage(widget.menuName, _branches[i].brcode),
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Branch>> fetchBranches() async {
    List<Branch> branches = [];

    try {
      setState(() {
        isLoading = true;
      });

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
      }
    } catch (e) {
      FlushbarMessage.show(
        context,
        null,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.WARNING,
      );
    }

    setState(() {
      isLoading = false;
    });

    return branches;
  }

  Widget selectPage(String menuName, String sbrcode) {
    switch (menuName) {
      case MenuNameConst.HomeworkStatus:
        return HomeworkStatusWidget(
          selected_date: DateFormat('dd-MMM-yyyy').format(reportDate),
          brcode: sbrcode,
        );
        break;
      case MenuNameConst.AttendanceEntry:
        return MngAttendanceEntryStatusWidget(
          selected_date: DateFormat('dd-MMM-yyyy').format(reportDate),
          brcode: sbrcode,
        );
        break;
      case MenuNameConst.PendingFees:
        return MngPendingFeesWidget(
          selected_date: DateFormat('dd-MMM-yyyy').format(reportDate),
          brcode: sbrcode,
        );
        break;
      case MenuNameConst.BalanceSheet:
        return MngBalanceSheetWidget(
          selected_date: DateFormat('dd-MMM-yyyy').format(reportDate),
          brcode: sbrcode,
        );
        break;
      case MenuNameConst.ActivityLog:
        return MngActivityLogWidget(
          selected_date: DateFormat('dd-MMM-yyyy').format(reportDate),
          brcode: sbrcode,
        );
        break;
      case MenuNameConst.StaffAttendance:
        return MngStaffAttendceWidget(
          selected_date: DateFormat('dd-MMM-yyyy').format(reportDate),
          brcode: sbrcode,
        );
        break;
      case MenuNameConst.StudentAttendance:
        return StudentAttendanceWidget(
          selected_date: DateFormat('dd-MMM-yyyy').format(reportDate),
          brcode: sbrcode,
        );
        break;
      case MenuNameConst.Balances:
        return MngBalancesWidget(
          selected_date: DateFormat('dd-MMM-yyyy').format(reportDate),
          brcode: sbrcode,
        );
        break;
      case MenuNameConst.EmployeeLeaves:
        return MngEmployeeLeaves(
          selected_date: DateFormat('dd-MMM-yyyy').format(reportDate),
          brcode: sbrcode,
        );
        break;
      case MenuNameConst.TeacherLoad:
        return MngTeacherWorkloadWidget(
          selected_date: DateFormat('dd-MMM-yyyy').format(reportDate),
          brcode: sbrcode,
        );
        break;
      case MenuNameConst.PaidFees:
        return MngPaidFeesWidget(
          selected_date: DateFormat('dd-MMM-yyyy').format(reportDate),
          brcode: sbrcode,
        );
        break;
    }
  }
}
