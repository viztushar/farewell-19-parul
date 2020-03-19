import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';

class StringModel {
  String title;

  StringModel({this.title});
}

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  double textandIconSize, kToolbarHeight, appbarPadding, backbutton;
  var itemsNoti;
  List<String> data = ["1", "2", "3", "4", "5"];
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool showError = false, showPro = false;
  String errorMessage = "";

  ScrollController _scrollController = ScrollController();
  int _currentMax = 10;
  bool sendNeedUpdate = false;

  bool showDeleteButton = false;
  bool isSelectAll = false;
  List<int> listDeletedData = [];
  var date = "";
  bool getAllN = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 700) {
      textandIconSize = 18;
      kToolbarHeight = 56.0;
      appbarPadding = 8;
      backbutton = 24;
    } else if (MediaQuery.of(context).size.width < 900) {
      textandIconSize = 26;
      kToolbarHeight = 64.0;
      appbarPadding = 12;
      backbutton = 32;
    } else if (MediaQuery.of(context).size.width > 900) {
      textandIconSize = 30;
      backbutton = 32;
      kToolbarHeight = 84.0;
      appbarPadding = 20;
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.blue,
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.blue),
      child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: AppBar(
                centerTitle: Platform.isAndroid ? false : true,
                brightness: Brightness.light,
                automaticallyImplyLeading: false,
                title: Text(
                  "Notification",
                  style:
                      TextStyle(color: Colors.blue, fontSize: textandIconSize),
                  textAlign: TextAlign.center,
                ),
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                iconTheme: IconThemeData(color: Colors.blue, size: backbutton),
                leading: Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        size: backbutton,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        Navigator.maybePop(context, sendNeedUpdate);
                      },
                      tooltip:
                          MaterialLocalizations.of(context).backButtonTooltip,
                    );
                  },
                ),
                actions: <Widget>[
                  showDeleteButton == true
                      ? GestureDetector(
                          onTap: () async {},
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.only(right: 0),
                              child: Center(
                                child: FlatButton(
                                  child: Text(
                                    isSelectAll == true
                                        ? "Deselect All"
                                        : "Select All",
                                    softWrap: true,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isSelectAll = !isSelectAll;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () async {},
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.only(right: 35),
                              child: Container(
                                height: 20.0,
                                width: 20.0,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.transparent),
                                child: Center(
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        showDeleteButton = !showDeleteButton;
                                        print("delete " +
                                            showDeleteButton.toString());
                                      });
                                    },
                                    icon: Icon(Icons.delete),
                                    iconSize: textandIconSize + 5,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                ],
              ),
            ),
          ),
          bottomNavigationBar: showDeleteButton == true
              ? cancelOrdeleteButtons()
              : Container(
                  width: 0,
                  height: 0,
                ),
          body: SafeArea(
              child: ListView.builder(
            reverse: false,
            shrinkWrap: true,
            primary: false,
            physics: ClampingScrollPhysics(),
            controller: _scrollController,
            scrollDirection: Axis.vertical,
            itemCount: data.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: NotificationUI(
                  index: index,
                  showdeleteButton: showDeleteButton,
                  title: data[index],
                  message: data[index],
                  isSelectAll: isSelectAll,
                  onDeletedSelecteds: (i, value) {
                    print("id $i $value");
                  },
                ),
              );
            },
          ))),
    );
  }

  Widget cancelOrdeleteButtons() {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: <Widget>[
            Expanded(
              child: RaisedButton(
                  elevation: 0.0,
                  child: new Text(
                    'Cancel',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0),
                  ),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      showDeleteButton = false;
                      isSelectAll = false;
                      listDeletedData = [];
                    });
                  }),
            ),
            Text("  "),
            Expanded(
              child: RaisedButton(
                elevation: 0.0,
                child: new Text(
                  'Delete',
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0),
                ),
                color: Colors.white,
                onPressed: () {
                  print(listDeletedData
                      .toList()
                      .toString()
                      .replaceAll("[", "")
                      .replaceAll("]", "")
                      .replaceAll(" ", ""));
                },
              ),
            ),
          ],
        ),
      ),
      //   ),
    );
  }
}

typedef onDeletedSelected(int i, bool value);

class NotificationUI extends StatefulWidget {
  final bool showdeleteButton;
  final int index;
  final String title;
  final String message;
  final onDeletedSelected onDeletedSelecteds;
  final bool isSelectAll;
  NotificationUI({
    Key key,
    @required this.index,
    @required this.showdeleteButton,
    @required this.title,
    @required this.message,
    @required this.onDeletedSelecteds,
    @required this.isSelectAll,
  }) : super(key: key);

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
                child: Switch(
                  value: widget.isSelectAll == true ? true : value,
                  onChanged: (value) {
                    setState(() {
                      this.value = value;
                    });

                    widget.onDeletedSelecteds(widget.index, value);
                  },
                  activeColor: Colors.blue,
                  focusColor: Colors.blue,
                  hoverColor: Colors.blue,
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
                    backgroundColor: Colors.blue.withOpacity(0.2),
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
                              color: Colors.blue,
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
                              ? MediaQuery.of(context).size.width / 2
                              : MediaQuery.of(context).size.width / 2),
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
                              color: Colors.blue,
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
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal),
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
                                            color: Colors.white,
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
