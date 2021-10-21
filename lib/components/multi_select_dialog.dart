import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teachers/models/divison.dart';

import 'custom_select_item.dart';

class MultiSelectDialog extends StatefulWidget {
  String message;
  List<dynamic> data;
  List<dynamic> data1;
  Function onOkayPressed;

  MultiSelectDialog({
    this.message,
    this.data,
    this.data1,
    this.onOkayPressed,
  });

  @override
  _MultiSelectDialogState createState() => new _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
//  List<dynamic> filteredData = [];
//  dynamic filteredData1;

  @override
  Widget build(BuildContext context) {
//    filteredData = widget.data.where((item) => item.isSelected == true).toList();
//    filteredData1=widget.data1.where((item) => item.isSelected == true).toList();


    return AlertDialog(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            widget.message,
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 200),
                child: CustomSelectItem(
                  onItemTap: (dynamic selectedDivision,dynamic selectedClass) {
                    setState(() {


                      // widget.data1 = widget.data1[index].division_name;
                    });
                  },
                  itemDivision:widget.data1,
                  itemClass: widget.data,
//                  itemIndex: index,

                ),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'OK',
            style:
                Theme.of(context).textTheme.button.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
          onPressed: () {
            widget.onOkayPressed();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
