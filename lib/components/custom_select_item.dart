import 'package:flutter/material.dart';
import 'package:dropdownfield/dropdownfield.dart';


class CustomSelectItem extends StatefulWidget {
  List<dynamic> itemClass;
  int itemIndex;
  Function onItemTap;
  List<dynamic> itemDivision;
  bool isSelected = false;


  CustomSelectItem({
    this.itemClass,
    this.itemIndex,
    this.onItemTap,
    this.itemDivision,
    this.isSelected,
  });

  @override
  _CustomSelectItemState createState() => _CustomSelectItemState();
}

class _CustomSelectItemState extends State<CustomSelectItem> {
  dynamic selectedDivision;
  dynamic selectedClass;



  @override
  void initState() {
    // TODO: implement initState
    selectedDivision = widget.itemDivision[0];
    selectedClass = widget.itemClass[0];

    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap:(){
        this.widget.onItemTap(selectedDivision,selectedClass);
      },
      child: Row(
        children: <Widget>[
//          Padding(
//            padding: const EdgeInsets.only(
//              right: 10.0,
//              top: 3.0,
//              bottom: 3.0,
//            ),
//            child: Icon(
//              Icons.check_box,
//              color: this.widget.isSelected
//
//                  ? Theme.of(context).accentColor
//                  : Theme.of(context).secondaryHeaderColor,
//            ),
//          ),
//          Expanded(
//            child: Text(
//              widget.itemTitle,
//              style: Theme.of(context).textTheme.bodyText2.copyWith(
//                    color: Colors.black54,
//                    fontWeight: FontWeight.w500,
//                  ),
//              maxLines: 2,
//              overflow: TextOverflow.ellipsis,
//            ),
//          ),
          new DropdownButton<dynamic>(
            value: selectedClass,
            autofocus: true,
            underline: Text(""),
            onChanged: (dynamic newValue) {
//              selected = newValue;
              setState(() {
                selectedClass = newValue;
              });
            },
            items: widget.itemClass.map((dynamic className) {
              return new DropdownMenuItem(
                value: className,
                child: new Text(
                  className.class_name,
                  style: new TextStyle(color: Colors.black),
                ),
              );
            },
            ).toList(),

          ),
          new DropdownButton<dynamic>(
            value: selectedDivision,
            autofocus: true,
            underline: Text(""),
            onChanged: (dynamic newValue) {
//              selected = newValue;
              setState(() {
                selectedDivision = newValue;
              });
            },
            items: widget.itemDivision.map((dynamic division) {
              return new DropdownMenuItem(
                value: division,
                child: new Text(
                  division.division_name,
                  style: new TextStyle(color: Colors.black),
                ),
              );
            },
            ).toList(),

          ),//          DropdownButton<String>(
        ],
      ),
    );
  }
}
