import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
import 'package:teachers/models/mng_pending_fees.dart';
import 'package:teachers/models/paidfees.dart';

class MngPaidFeesWidget extends StatefulWidget {
  String selected_date, brcode;
  int flag;

  MngPaidFeesWidget({
    this.selected_date,
    this.flag,
    this.brcode,
  });

  @override
  _MngPaidFeesWidgetState createState() => _MngPaidFeesWidgetState();
}

class _MngPaidFeesWidgetState extends State<MngPaidFeesWidget> {
  List<PaidFees> pendingFees = [];
  String loadingText;
  bool isLoading;
  String dateInState;
  bool isLoaded;
  String msgKey;

  @override
  void initState() {
    isLoading = false;
    loadingText = 'Loading . . .';
    msgKey = "key_loading_pending_fees";

    fetchPaidFees().then((result) {
      setState(() {
        pendingFees = result;
      });
    });
    super.initState();
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
      fetchPaidFees().then((result) {
        setState(() {
          pendingFees = result;
          dateInState = widget.selected_date;
        });
      });
    }
    return pendingFees != null && pendingFees.length != 0
        ? ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 40,
            dataRowHeight: 40,
            columns: [
              DataColumn(
                label: Text(
                  AppTranslations.of(context).text("key_stud_no"),
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  AppTranslations.of(context).text("key_student_name"),
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              DataColumn(
                numeric: true,
                label: Text(
                  AppTranslations.of(context).text("key_transaction_date"),
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              DataColumn(
                numeric: true,
                label: Text(
                  AppTranslations.of(context).text("key_fees_amount"),
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              DataColumn(
                numeric: true,
                label: Text(
                  AppTranslations.of(context).text("key_paid_amount"),
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            rows: new List<DataRow>.generate(
              pendingFees.length,
                  (int index) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        pendingFees[index].STUD_NO.toString(),
                        style:
                        Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    DataCell(
                      Text(
                        StringHandlers.capitalizeWords(
                            pendingFees[index].STUD_FULLNAME),
                        style:
                        Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                      pendingFees[index].TRDATE!=null? DateFormat('dd-MMM-yyyy').format( pendingFees[index].TRDATE):'',

                        style:
                        Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    DataCell(
                      Text(
                        pendingFees[index].FEES_AMOUNT.toString(),
                        style:
                        Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    DataCell(
                      Text(
                        pendingFees[index].AMT.toString(),
                        style:
                        Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
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
                  description:
                      AppTranslations.of(context).text("key_fees_instruction"),
                );
              },
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    loadingText = AppTranslations.of(context).text("key_loading");
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: RefreshIndicator(
        onRefresh: () async {
          fetchPaidFees().then((result) {
            setState(() {
              pendingFees = result;
            });
          });
        },
        child: dataBody(),
      ),
    );
  }

  Future<List<PaidFees>> fetchPaidFees() async {
    List<PaidFees> paidfees = [];
    try {
      setState(() {
        isLoading = true;
      });

      /*String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchPaidFeesUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              PaidFeesUrls.GET_PAID_FEES,
          {
            "report_date": widget.selected_date.toString(),
            'brcode': widget.brcode,
          },
        );

        http.Response response = await http.get(fetchPaidFeesUri);

        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            '',
            response.body.toString(),
            MessageTypes.WARNING,
          );
          setState(() {
            msgKey = "key_fees_instruction";
          });
        } else {
          List responseData = json.decode(response.body);
          paidfees = responseData
              .map(
                (item) => PaidFees.fromMap(item),
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

    return paidfees;
  }

}
