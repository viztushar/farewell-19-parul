import 'package:flutter/material.dart';
import 'package:myemrapp/utility/utility.dart';
import 'dart:math';

typedef onDeletedSelected(int i, bool value);

class NotificationUI extends StatefulWidget {
  final bool showdeleteButton;
  final int index;
  final String title;
  final String message;
  final String date;
  final onDeletedSelected onDeletedSelecteds;
  final bool isSelectAll;
  final bool newN;
  NotificationUI(
      {Key key,
      @required this.index,
      @required this.showdeleteButton,
      @required this.title,
      @required this.message,
      @required this.onDeletedSelecteds,
      @required this.date,
      @required this.isSelectAll,
      @required this.newN})
      : super(key: key);

  @override
  _NotificationUIState createState() => _NotificationUIState();
}

class _NotificationUIState extends State<NotificationUI> {
  bool value = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        widget.showdeleteButton == true
            ? Padding(
                padding: EdgeInsets.only(top: 10),
                child: Checkbox(
                  tristate: false,
                  value: widget.isSelectAll == true ? true : value,
                  onChanged: (value) {
                    setState(() {
                      this.value = value;
                    });

                    widget.onDeletedSelecteds(widget.index, value);
                  },
                  activeColor: Utility.darkColor,
                  checkColor: Utility.lightColor,
                  focusColor: Utility.darkColor,
                  hoverColor: Utility.darkColor,
                ),
              )
            : Container(
                width: 0,
                height: 0,
              ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: CircleAvatar(
                    radius: 25,
                    foregroundColor: Theme.of(context).cardColor,
                    backgroundColor: Utility.darkColor.withOpacity(0.2),
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.title[0].toString().toUpperCase(),
                          softWrap: true,
                          style: TextStyle(
                              fontSize: 25,
                              color: Utility.darkColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width -
                          (widget.showdeleteButton == true
                              ? MediaQuery.of(context).size.width / 3
                              : MediaQuery.of(context).size.width / 3),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipPath(
                          clipper: ClipRThread(2.5),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(2.5)),
                            child: Container(
                              constraints: BoxConstraints.loose(
                                  MediaQuery.of(context).size * 0.8),
                              padding: EdgeInsets.fromLTRB(
                                  8.0 + 2 * 2.5, 8.0, 8.0, 8.0),
                              color: Colors.white,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    widget.title,
                                    softWrap: true,
                                    style: TextStyle(
                                        fontSize:
                                            widget.showdeleteButton == true
                                                ? 14
                                                : 18,
                                        color: Utility.darkColor,
                                        fontWeight: widget.newN == true
                                            ? FontWeight.bold
                                            : FontWeight.normal),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.start,
                                    verticalDirection: VerticalDirection.up,
                                    alignment: WrapAlignment.start,
                                    runAlignment: WrapAlignment.start,
                                    direction: Axis.horizontal,
                                    runSpacing: 0,
                                    spacing: 0,
                                    textDirection: TextDirection.rtl,
                                    children: <Widget>[
                                      Text(
                                        widget.message,
                                        softWrap: true,
                                        style: TextStyle(
                                            fontSize:
                                                widget.showdeleteButton == true
                                                    ? 10
                                                    : 12,
                                            color: Utility.darkColor,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Text(
                        widget.date,
                        softWrap: true,
                        style: TextStyle(
                            fontSize: widget.showdeleteButton == true ? 10 : 12,
                            color: Utility.darkColor,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class ClipRThread extends CustomClipper<Path> {
  final double chatRadius;

  ClipRThread(this.chatRadius);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, chatRadius);
    // path.lineTo(chatRadius, chatRadius + chatRadius / 2);
    
    final r = chatRadius;
    final angle = 0.785;
    path.conicTo(
      r - r * sin(angle),
      r + r * cos(angle),
      r - r * sin(angle * 0.5),
      r + r * cos(angle * 0.5),
      1,
    );

    final moveIn = 2 * r; // need to be > 2 * r
    path.lineTo(moveIn, r + moveIn * tan(angle));

    path.lineTo(moveIn, size.height - chatRadius);

    path.conicTo(
      moveIn + r - r * cos(angle),
      size.height - r + r * sin(angle),
      moveIn + r,
      size.height,
      1,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
