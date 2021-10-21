import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';

class CustomLeaveApplicationItem extends StatelessWidget {
  final String leave_type;
  final String start_date;
  final String end_date;
  final String apply_date;
  final String status;

  CustomLeaveApplicationItem({
    this.leave_type,
    this.start_date,
    this.end_date,
    this.apply_date,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30.0),
          topLeft: Radius.circular(3.0),
          bottomRight: Radius.circular(3.0),
          bottomLeft: Radius.circular(3.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Table(
              columnWidths: {
                0: FractionColumnWidth(.4),
              },
              children: [
                TableRow(
                  children: [
                    Container(),
                    Container(),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5.0,
                      ),
                      child: Text(
                        AppTranslations.of(context).text("key_leave_type"),
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5.0,
                      ),
                      child: Text(
                        StringHandlers.capitalizeWords(this.leave_type),
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5.0,
                        bottom: 5.0,
                      ),
                      child: Text(
                        AppTranslations.of(context).text("key_duration"),
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5.0,
                        bottom: 5.0,
                      ),
                      child: Text(
                        StringHandlers.capitalizeWords(
                            "${this.start_date}-${this.end_date}"),
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  /*decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[300],
                      ),
                    ),
                  ),*/
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5.0,
                        bottom: 5.0,
                      ),
                      child: Text(
                        AppTranslations.of(context).text("key_applied_on"),
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5.0,
                        bottom: 5.0,
                      ),
                      child: Text(
                        StringHandlers.capitalizeWords(this.apply_date),
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Container(),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5.0,
                        bottom: 5.0,
                      ),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: (){},
                          behavior: HitTestBehavior.translucent,
                          child: Text(
                            AppTranslations.of(context)
                                .text("key_Approve"),
                            style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
