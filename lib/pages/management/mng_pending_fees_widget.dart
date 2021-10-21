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
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/mng_pending_fees.dart';

class MngPendingFeesWidget extends StatefulWidget {
  String selected_date, brcode;
  int flag;

  MngPendingFeesWidget({
    this.selected_date,
    this.flag,
    this.brcode,
  });

  @override
  _MngPendingFeesWidgetState createState() => _MngPendingFeesWidgetState();
}

class _MngPendingFeesWidgetState extends State<MngPendingFeesWidget> {
  List<PendingFees> pendingFees = [];
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

    fetchPendingFees().then((result) {
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
      fetchPendingFees().then((result) {
        setState(() {
          pendingFees = result;
          dateInState = widget.selected_date;
        });
      });
    }
    return pendingFees != null && pendingFees.length != 0
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
                        AppTranslations.of(context).text("key_division"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppTranslations.of(context).text("key_school_fees"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppTranslations.of(context).text("key_paid_fees"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppTranslations.of(context).text("key_pending_fees"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppTranslations.of(context).text("key_consession"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppTranslations.of(context).text("key_bus_fee"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppTranslations.of(context).text("key_paid_fees"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        AppTranslations.of(context).text("key_pending_fees"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),

                  ],
                  rows: new List<DataRow>.generate(
                    pendingFees.length,
                    (int index) {
                      if (pendingFees[index].division_name == '') {
                        return DataRow(
                          selected: true,
                          cells: [
                            DataCell(
                              Text(
                                '${AppTranslations.of(context).text("key_class")} ${pendingFees[index].class_name}',
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
                        return pendingFees[index].division_name == 'TOTAL'
                            ? DataRow(
                                selected: true,
                                cells: [
                                  DataCell(
                                    Text(
                                      pendingFees[index].division_name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      pendingFees[index].total_fees.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      pendingFees[index].paid_fees.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      pendingFees[index]
                                          .pending_fees
                                          .toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      pendingFees[index].concession.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                        color:
                                        Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      pendingFees[index]
                                          .total_bus_fees
                                          .toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      pendingFees[index]
                                          .paid_bus_fees
                                          .toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      pendingFees[index]
                                          .pending_bus_fees
                                          .toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),

                                ],
                              )
                            : DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      pendingFees[index].division_name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      pendingFees[index].total_fees.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      pendingFees[index].paid_fees.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      pendingFees[index]
                                          .pending_fees
                                          .toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      pendingFees[index].concession.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      pendingFees[index]
                                          .total_bus_fees
                                          .toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      pendingFees[index]
                                          .paid_bus_fees
                                          .toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      pendingFees[index]
                                          .pending_bus_fees
                                          .toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w500,
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
          fetchPendingFees().then((result) {
            setState(() {
              pendingFees = result;
            });
          });
        },
        child: dataBody(),
      ),
    );
  }

  Future<List<PendingFees>> fetchPendingFees() async {
    List<PendingFees> attStatus = [];

    List<PendingFees> att_all = [];

    try {
      setState(() {
        isLoading = true;
      });

      /*String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchPendingFeesUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              PendingFeesUrls.GET_PENDING_FEES,
          {
            "report_date": widget.selected_date.toString(),
            'brcode': widget.brcode,
          },
        );

        http.Response response = await http.get(fetchPendingFeesUri);

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
          att_all = responseData
              .map(
                (item) => PendingFees.fromMap(item),
              )
              .toList();

          String lClass = '';
          double tot_f = 0,
              tot_pending = 0,
              tot_paid = 0,
              tot_con = 0,
              tot_bus = 0,
              tot_bus_paid = 0,
              tot_bus_pending = 0;


          for (int i = 0; i < att_all.length; i++) {
            setState(() {
              tot_f = tot_f + att_all[i].total_fees;
              tot_pending = tot_pending + att_all[i].pending_fees;
              tot_paid = tot_paid + att_all[i].paid_fees;
              tot_con = tot_con + att_all[i].concession;
              tot_bus = tot_bus + att_all[i].total_bus_fees;
              tot_bus_paid = tot_bus_paid + att_all[i].paid_bus_fees;
              tot_bus_pending = tot_bus_pending + att_all[i].pending_bus_fees;

            });
            if (lClass == '') {
              setState(() {
                lClass = att_all[i].class_name;

                attStatus.add(
                  PendingFees(
                    class_name: att_all[i].class_name,
                    division_name: '',
                  ),
                );
              });
            } else {
              setState(() {
                lClass = att_all[i - 1].class_name;
              });
            }

            if (lClass == att_all[i].class_name) {
              setState(() {
                attStatus.add(att_all[i]);
              });
            } else {
              setState(() {
                attStatus.add(
                  PendingFees(
                    class_name: att_all[i].class_name,
                    division_name: '',
                  ),
                );
                attStatus.add(att_all[i]);
              });
            }
          }
          attStatus.add(
            PendingFees(
                division_name: 'TOTAL',
                total_fees: tot_f,
                paid_fees: tot_paid,
                pending_fees: tot_pending,
                concession: tot_con,
                total_bus_fees: tot_bus,
                pending_bus_fees: tot_bus_pending,
                paid_bus_fees: tot_bus_paid
               ),
          );
          bool PendingfeesOverlay = AppData.getCurrentInstance()
                  .preferences
                  .getBool('pendingfees_overlay') ??
              false;
          if (!PendingfeesOverlay) {
            AppData.getCurrentInstance()
                .preferences
                .setBool("pendingfees_overlay", true);
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

    return attStatus;
  }

  void _showOverlay(BuildContext context) {
    Navigator.of(context).push(
      OverlayForSelectPage(
          AppTranslations.of(context).text("key_select_date_from_here")),
    );
  }
}
