import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teachers/themes/colors_old.dart';

class CustomCupertinoActionsRemoved {
  final List<Object> data;
  final Function onItemSelected;
  final BuildContext context;
  final Color color;

  const CustomCupertinoActionsRemoved({
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
              Container(
                child: Text(''),
                width: 3.0,
                color: i % 2 == 0 ? Colors.grey[400] : Colors.pink[300],
              ),
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
