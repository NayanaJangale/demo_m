import 'package:flutter/material.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/models/student_attendance.dart';

class CustomAttendanceItem extends StatelessWidget {
  final StudentAttendance item;
  final int itemIndex;
  final Function onItemTap;

  const CustomAttendanceItem({this.item, this.itemIndex, this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: this.onItemTap,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 8.0,
          bottom: 8.0,
        ),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              decoration: BoxDecoration(
                color:
                    item.at_status == 'P' ? Colors.green[400] : Colors.red[400],
                borderRadius: BorderRadius.circular(
                  5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 8.0,
                  bottom: 8.0,
                  left: 12,
                  right: 12.0,
                ),
                child: Text(
                  item.at_status,
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                item.roll_no.toString() +
                    ' - ' +
                    StringHandlers.capitalizeWords(item.student_name),
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.navigate_next,
              color:
                  item.at_status == 'P' ? Colors.green[400] : Colors.red[400],
            ),
          ],
        ),
      ),
    );
  }
}
