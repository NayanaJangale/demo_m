import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teachers/themes/colors_old.dart';

class SelectableCupertinoActions {
  final List<dynamic> data;
  final Function onItemSelected;
  final BuildContext context;
  final Color color;

  const SelectableCupertinoActions({
    this.context,
    this.data,
    this.onItemSelected,
    this.color,
  });

  List<Widget> getActions() {
    List<Widget> widgets = new List<Widget>();

    for (int i = 0; i < data.length; i++) {
      widgets.add(
        CupertinoActionSheetAction(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.check_box,
                  color: data[i].isSelected == true
                      ? ThemeColors.primaryLight
                      : Colors.transparent),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: Text(
                  data[i].toString(),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.primary,
                  ),
                ),
              ),
              Icon(
                Icons.navigate_next,
                color: Colors.grey,
              ),
            ],
          ),
          onPressed: () {
            onItemSelected(i);
          },
        ),
      );
    }

    return widgets;
  }
}
