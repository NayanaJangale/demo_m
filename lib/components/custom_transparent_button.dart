import 'package:flutter/material.dart';

class CustomTransparentButton extends StatelessWidget {
  final Function onPressed;
  final Color color;
  final String caption;

  const CustomTransparentButton({
    this.onPressed,
    this.color,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 1.0,
            color: this.color,
          ),
          borderRadius: BorderRadius.circular(
            5.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: Text(
                  this.caption,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: this.color,
                  ),
                ),
              ),
              Icon(
                Icons.navigate_next,
                color: this.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
