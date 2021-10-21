import 'package:flutter/material.dart';

class CustomMessageItem extends StatelessWidget {
  String messageTitle, messageBody, messageTimestamp;
  int messageIndex, noOfReceivers;
  Function onMessageItemTap;

  CustomMessageItem({
    this.messageTitle,
    this.messageBody,
    this.messageTimestamp,
    this.messageIndex,
    this.onMessageItemTap,
  }) {
    this.messageTitle = this.messageTitle.trim();
    this.messageTitle = this.messageTitle.endsWith(',')
        ? this.messageTitle.substring(0, this.messageTitle.length - 1)
        : this.messageTitle;
    List<String> receivers = this.messageTitle.split(',');
    this.messageTitle = receivers[0];
    noOfReceivers = receivers.length;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: this.onMessageItemTap,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 8.0,
          bottom: 8.0,
        ),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                right: 15.0,
                top: 3.0,
                bottom: 3.0,
              ),
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom: 8.0,
                  ),
                  child: Text(''),
                ),
                width: 3.0,
                color: Colors.transparent,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            Text(
                              messageTitle,
                              style: Theme.of(context).textTheme.bodyText1.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Container(
                              child: noOfReceivers > 1
                                  ? CircleAvatar(
                                      maxRadius: 10,
                                      backgroundColor:
                                          Theme.of(context).accentColor,
                                      child: Text(
                                        '+' + (noOfReceivers - 1).toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                      ),
                                    )
                                  : Container(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        messageTimestamp,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Icon(
                        Icons.navigate_next,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 8.0,
                    ),
                    child: Text(
                      messageBody,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
