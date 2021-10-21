import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teachers/handlers/string_handlers.dart';

class CustomEmpLeavesItem extends StatelessWidget {
  final String leave_type;
  final String leave_desc;
  final Function onItemTap;

  CustomEmpLeavesItem({
    this.leave_type,
    this.leave_desc,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: this.onItemTap,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: EdgeInsets.all(10.0),
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
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10.0,
                            bottom: 10.0,
                          ),
                          child: Text(
                            StringHandlers.capitalizeWords(this.leave_type),
                            style: Theme.of(context).textTheme.bodyText2.copyWith(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10.0,
                            bottom: 10.0,
                          ),
                          child: Text(
                            StringHandlers.capitalizeWords(this.leave_desc),
                            style: Theme.of(context).textTheme.bodyText2.copyWith(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
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
        ),
      ),
    );
  }
}
