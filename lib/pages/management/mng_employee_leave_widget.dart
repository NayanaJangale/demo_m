import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teachers/components/custom_data_not_found.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/employee_leaves.dart';

class MngEmployeeLeaves extends StatefulWidget {
  String selected_date;
  String brcode;
  int flag;

  MngEmployeeLeaves({
    this.selected_date,
    this.flag,
    this.brcode,
  });

  @override
  _MngEmployeeLeavesState createState() => _MngEmployeeLeavesState();
}

class _MngEmployeeLeavesState extends State<MngEmployeeLeaves> {
  bool isLoading;
  bool isLoaded;

  String loadingText;

  String dateInState;
  String msgKey;

  List<EmployeeLeave> _employeeLeave = [];
  List<LeaveTypeData> desc_list = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.isLoading = false;
    this.isLoaded = false;
    this.loadingText = 'Loading . . .';
    msgKey = "key_Loading_Employee_Leaves";

    fetchEmployeeLeaves().then((result) {
      setState(() {
        _employeeLeave = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    loadingText = AppTranslations.of(context).text("key_loading");
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: RefreshIndicator(
        onRefresh: () async {
          fetchEmployeeLeaves().then((result) {
            setState(() {
              _employeeLeave = result;
            });
          });
        },
        child: getEmployeeLeaveTable(),
      ),
    );
  }

  Widget getEmployeeLeaveTable() {
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
      fetchEmployeeLeaves().then((result) {
        setState(() {
          _employeeLeave = result;
          dateInState = widget.selected_date;
        });
      });
    }
    return _employeeLeave != null && _employeeLeave.length != 0
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
                        AppTranslations.of(context).text("key_name"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    for (int i = 0; i < desc_list.length; i++)
                      DataColumn(
                        label: Text(
                          StringHandlers.capitalizeWords(
                                  desc_list[i].type_desc) +
                              '\n' +
                              desc_list[i].max_limit.toString(),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                  rows: getEmployeeRecords(),
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
                  description:
                      AppTranslations.of(context).text("key_Employee_Leaves"),
                );
              },
            ),
          );
  }

  List<DataRow> getEmployeeRecords() {
    List<DataRow> rows = [];
    for (EmployeeLeave leave in _employeeLeave) {
      if (!leave.isPrinted) {
        List<EmployeeLeave> singleEmpData = _employeeLeave
            .where((item) => item.emp_no == leave.emp_no)
            .toList();

        for (LeaveTypeData d in desc_list) {
          d.type_count = 0.0;
        }

        for (EmployeeLeave eLeave in singleEmpData) {
          desc_list
              .where((item) => item.type_desc == eLeave.l_desc)
              .elementAt(0)
              .type_count = eLeave.type_count;

          eLeave.isPrinted = true;
        }

        rows.add(
          DataRow(
            cells: List.generate(
              desc_list.length + 1,
              (i) => DataCell(
                Text(
                  i == 0
                      ? StringHandlers.capitalizeWords(
                          singleEmpData.elementAt(0).emp_name)
                      : desc_list[i - 1].type_count.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return rows;
  }

  List<DataRow> getDataRow() {
    List<DataRow> dataRow = new List();

    String empName = "";
    int c = 0;

    for (int i = 0; i < _employeeLeave.length; i++) {
      c = i;
      //empName = _employeeLeave[i].emp_name;
      if (_employeeLeave[i].emp_name != empName)
        dataRow.add(
          DataRow(
            cells: [
              DataCell(
                Text(
                  StringHandlers.capitalizeWords(_employeeLeave[i].emp_name) ??
                      '',
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              for (int j = 0; j < desc_list.length; j++)
                if (_employeeLeave[i].emp_no == _employeeLeave[j].emp_no)
                  DataCell(
                    Text(
                      _employeeLeave[c].type_count.toString() ?? '',
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  )
                else
                  DataCell(
                    Text(""),
                  )
            ],
          ),
        );
      empName = _employeeLeave[i].emp_name;
    }

    return dataRow;
  }

  List<DataCell> getDatacells() {
    List<DataCell> data = List();
  }

  Future<List<EmployeeLeave>> fetchEmployeeLeaves() async {
    List<EmployeeLeave> employeeLeave = [];

    try {
      setState(() {
        isLoading = true;
      });


      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchteacherAlbumsUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              EmployeeLeaveUrls.GET_EMPLOYEE_LEAVES,
          {
            "report_date": widget.selected_date.toString(),
            'brcode': widget.brcode,
          },
        );

        http.Response response = await http.get(fetchteacherAlbumsUri);

        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            '',
            response.body.toString(),
            MessageTypes.WARNING,
          );
          setState(() {
            msgKey = "key_Employee_Leaves";
          });
        } else {
          List responseData = json.decode(response.body);
          employeeLeave = responseData
              .map(
                (item) => EmployeeLeave.fromJson(item),
              )
              .toList();
          final seen = Set<String>();

          List<dynamic> dTypes =
              employeeLeave.where((str) => seen.add(str.l_desc)).toList();

          desc_list = List<LeaveTypeData>.generate(
            dTypes.length,
            (i) => LeaveTypeData(
              type_desc: dTypes[i].l_desc,
              max_limit: dTypes[i].max_limit,
              type_count: 0,
            ),
          ).toList();
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

    return employeeLeave;
  }
}

class LeaveTypeData {
  String type_desc;
  double max_limit;
  double type_count;

  LeaveTypeData({
    this.type_desc,
    this.type_count,
    this.max_limit,
  });
}
