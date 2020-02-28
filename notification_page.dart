import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:myemrapp/database/notification_database/notificatio_database.dart';
import 'package:myemrapp/enums/connectivityStatus.dart';
import 'package:myemrapp/model/notification_model.dart';
import 'package:myemrapp/pages/service/network_provider.dart';
import 'package:myemrapp/utility/utility.dart';
import 'package:dio/dio.dart' as dios;
import 'package:myemrapp/utility/widgets_utitlity.dart';
import 'package:myemrapp/widget/NetworkSensitive.dart';
import 'package:myemrapp/widget/notification_ui.dart';
import 'package:myemrapp/widget/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  final String clientId;
  final String userid;
  NotificationPage({Key key, @required this.clientId, @required this.userid})
      : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  double textandIconSize, kToolbarHeight, appbarPadding, backbutton;
  var itemsNoti;
  List<NotificationModel> data;
  NotificationDatabase dbNHelper;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool showError = false, showPro = false;
  String errorMessage = "";
  //bool showNext = false;
  //bool showPre = false;
  ScrollController _scrollController = ScrollController();
  int _currentMax = 10;
  dios.CancelToken diotoken = dios.CancelToken();
  bool sendNeedUpdate = false;

  bool showDeleteButton = false;
  bool isSelectAll = false;
  List<int> listDeletedData = [];
  var date = "";
  bool getAllN = true;

  @override
  void initState() {
    super.initState();
    dbNHelper = NotificationDatabase();
    Timer(Duration(milliseconds: 500), () {
      if (Theme.of(context).platform == TargetPlatform.android) {
        var connectionStatus =
            Provider.of<ConnectivityStatus>(context).toString();
        print(connectionStatus.toString());
        if (connectionStatus.toString().compareTo("ConnectivityStatus.WiFi") ==
                0 ||
            connectionStatus
                    .toString()
                    .compareTo("ConnectivityStatus.Cellular") ==
                0) {
          getData();
        } else {
          diotoken.cancel();
        }
      } else {
        getData();
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
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
          systemNavigationBarColor: Utility.lightColor,
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Utility.lightColor),
      child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Utility.lightColor,
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
                  style: TextStyle(
                      color: Utility.darkColor, fontSize: textandIconSize),
                  textAlign: TextAlign.center,
                ),
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                iconTheme:
                    IconThemeData(color: Utility.darkColor, size: backbutton),
                leading: Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        size: backbutton,
                        color: Utility.darkColor,
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
                                        color: Utility.darkColor,
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
                                    color: Utility.darkColor,
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
                      child: Provider<NetworkProvider>(
              create: (context) => NetworkProvider(),
              child: Consumer<NetworkProvider>(builder: (context, value, _) {
                return NetworkSensitive(
                  networkProvider: value,
                  opacity: 0.8,
                  errorChild: errorWidget(context),
                  child: Flex(
                    direction: Axis.vertical,
                    children: <Widget>[
                      Expanded(
                        flex: 11,
                        child: Consumer<NotificationDatabase>(
                          builder: (context, dbHelper, child) {
                            return StreamBuilder<List<NotificationModel>>(
                              stream: dbHelper
                                  .getNotification(_currentMax)
                                  .asStream(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<NotificationModel>>
                                      snapshot) {
                                if (null == snapshot.data ||
                                    snapshot.data.length == 0) {
                                  return !showError
                                      ? notificationShimmerEffectWidget()
                                      // Container(
                                      //     child: Center(
                                      //       child: Padding(
                                      //         padding: EdgeInsets.only(top: 2.0),
                                      //         child: SizedBox(
                                      //           height: 2,
                                      //           child: LinearProgressIndicator(
                                      //             valueColor:
                                      //                 AlwaysStoppedAnimation<
                                      //                         Color>(
                                      //                     Utility.darkColor),
                                      //             backgroundColor: Utility
                                      //                 .darkColor
                                      //                 .withOpacity(0.5),
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   )
                                      : errorMessage.toString().contains(
                                              "There is No New Notification.")
                                          ? Center(
                                              child:
                                                  noNotificationWidget(context),
                                            )
                                          : Center(
                                              child: Text("$errorMessage"),
                                            );
                                } else if (snapshot.data.isNotEmpty) {
                                  //print("load");
                                  return getAllN == true
                                      // ? Center(
                                      //     child: CircularProgressIndicator(
                                      //       valueColor:
                                      //           AlwaysStoppedAnimation<Color>(
                                      //               Utility.darkColor),
                                      //       backgroundColor: Utility.darkColor
                                      //           .withOpacity(0.5),
                                      //     ),
                                      //   )
                                      ? notificationShimmerEffectWidget()
                                      : ListView.builder(
                                          reverse: false,
                                          shrinkWrap: true,
                                          primary: false,
                                          physics: ClampingScrollPhysics(),
                                          controller: _scrollController,
                                          scrollDirection: Axis.vertical,
                                          itemCount: snapshot.data.length,
                                          itemBuilder: (context, index) {
                                            if (snapshot.data[index].title
                                                    .compareTo(
                                                        "datefordateToshow") ==
                                                0) {
                                              // date = snapshot.data[index].sentOn
                                              //     .split(" ")
                                              //     .first;
                                              return Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Container(
                                                    color: Utility.darkColor,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        snapshot
                                                            .data[index].sentOn
                                                            .toString()
                                                            .split(" ")
                                                            .first,
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold),
                                                      ),
                                                    ),
                                                  ),
                                                  // Padding(
                                                  //   padding: const EdgeInsets.all(8.0),
                                                  //   child: NotificationUI(
                                                  //     index: index,
                                                  //     showdeleteButton:
                                                  //         showDeleteButton,
                                                  //     title: snapshot.data[index].title,
                                                  //     message:
                                                  //         snapshot.data[index].message,
                                                  //     date: snapshot.data[index].sentOn,
                                                  //     isSelectAll: isSelectAll,
                                                  //     readOn:
                                                  //         snapshot.data[index].readOn,
                                                  //     onDeletedSelecteds: (i, value) {
                                                  //       print(snapshot
                                                  //               .data[i].notificationid
                                                  //               .toString() +
                                                  //           " " +
                                                  //           value.toString());
                                                  //       if (value == true) {
                                                  //         listDeletedData.add(int.parse(
                                                  //             snapshot.data[i]
                                                  //                 .notificationid));
                                                  //       } else {
                                                  //         listDeletedData.remove(
                                                  //             int.parse(snapshot.data[i]
                                                  //                 .notificationid));
                                                  //       }
                                                  //     },
                                                  //   ),
                                                  // )
                                                ],
                                              );
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: NotificationUI(
                                                index: index,
                                                showdeleteButton:
                                                    showDeleteButton,
                                                title: snapshot.data[index].title,
                                                message:
                                                    snapshot.data[index].message,
                                                date:
                                                    // snapshot
                                                    //         .data[index].notificationid +
                                                    //     " " +
                                                    //     snapshot.data[index].sentOn +
                                                    //     " " +
                                                    snapshot.data[index].date
                                                            .toString()
                                                            .substring(0, 5) +
                                                        " " +
                                                        (snapshot
                                                            .data[index].sentOn
                                                            .toString()
                                                            .split(" ")
                                                            .last),
                                                isSelectAll: isSelectAll,
                                                newN: snapshot.data[index].newN,
                                                onDeletedSelecteds: (i, value) {
                                                  print(snapshot
                                                          .data[i].notificationid
                                                          .toString() +
                                                      " " +
                                                      value.toString());
                                                  if (value == true) {
                                                    listDeletedData.add(int.parse(
                                                        snapshot.data[i]
                                                            .notificationid));
                                                  } else {
                                                    listDeletedData.remove(
                                                        int.parse(snapshot.data[i]
                                                            .notificationid));
                                                  }
                                                },
                                              ),
                                            );
                                            // Slidable(
                                            //   key: ValueKey(index),
                                            //   actionPane: SlidableDrawerActionPane(),
                                            //   direction: Axis.horizontal,
                                            //   secondaryActions: <Widget>[
                                            //     IconSlideAction(
                                            //       caption: 'Delete',
                                            //       color: Colors.red,
                                            //       icon: Icons.delete,
                                            //       onTap: () async {
                                            //         await mDeleteNotification(snapshot
                                            //             .data[index].notificationid);
                                            //       },
                                            //     ),
                                            //   ],
                                            //   child: Padding(
                                            //     padding: const EdgeInsets.all(8.0),
                                            //     child: Theme(
                                            //       data: ThemeData(
                                            //           primaryColor: Utility.darkColor,
                                            //           accentColor: Utility.darkColor),
                                            //       child: ExpansionTile(
                                            //         title: Padding(
                                            //           padding:
                                            //               const EdgeInsets.all(8.0),
                                            //           child: Text(
                                            //             snapshot.data[index].title,
                                            //             style: TextStyle(
                                            //                 color: Utility.darkColor,
                                            //                 fontSize: textandIconSize,
                                            //                 fontWeight: snapshot
                                            //                             .data[index]
                                            //                             .readOn
                                            //                             .toString()
                                            //                             .compareTo(
                                            //                                 "null") ==
                                            //                         0
                                            //                     ? FontWeight.bold
                                            //                     : FontWeight.normal),
                                            //             textAlign: TextAlign.start,
                                            //           ),
                                            //         ),
                                            //         onExpansionChanged: (chnage) {
                                            //           if (chnage == true &&
                                            //               snapshot.data[index].readOn
                                            //                       .toString()
                                            //                       .compareTo("null") ==
                                            //                   0) {
                                            //             markASReadNotification(
                                            //                 NotificationModel(
                                            //                     title: snapshot
                                            //                         .data[index].title,
                                            //                     readOn: "",
                                            //                     message: snapshot
                                            //                         .data[index]
                                            //                         .message,
                                            //                     notificationid: snapshot
                                            //                         .data[index]
                                            //                         .notificationid,
                                            //                     pushOn: "",
                                            //                     sentOn: ""));
                                            //           }
                                            //         },
                                            //         children: <Widget>[
                                            //           Padding(
                                            //             padding:
                                            //                 const EdgeInsets.all(8.0),
                                            //             child: Text(
                                            //               snapshot.data[index].message,
                                            //               style: TextStyle(
                                            //                   color: Utility.darkColor,
                                            //                   fontSize: textandIconSize,
                                            //                   fontWeight:
                                            //                       FontWeight.w300),
                                            //               textAlign: TextAlign.start,
                                            //             ),
                                            //           )
                                            //         ],
                                            //       ),
                                            //     ),
                                            //   ),
                                            // );
                                          },
                                        );
                                }
                              },
                            );
                          },
                        ),
                      ),
                      showPro
                          ? Padding(
                              padding: EdgeInsets.all(4),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Utility.darkColor),
                                backgroundColor:
                                    Utility.darkColor.withOpacity(0.5),
                              ),
                            )
                          : Container(
                              width: 0,
                              height: 0,
                            )
                    ],
                  ),
                );
              }),
            ),
          )
          // SingleChildScrollView(
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     mainAxisSize: MainAxisSize.max,
          //     children: <Widget>[
          //       // Padding(
          //       //   padding:
          //       //       EdgeInsets.only(left: 0, right: 0, bottom: 10, top: 10),
          //       //   child: Row(
          //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       //     crossAxisAlignment: CrossAxisAlignment.start,
          //       //     mainAxisSize: MainAxisSize.max,
          //       //     children: <Widget>[
          //       //       showNext
          //       //           ? SizedBox(
          //       //               height: 60,
          //       //               width: 60,
          //       //               child: RaisedButton(
          //       //                 shape: RoundedRectangleBorder(
          //       //                     borderRadius: BorderRadius.only(
          //       //                         topLeft: Radius.circular(0),
          //       //                         bottomLeft: Radius.circular(0),
          //       //                         topRight: Radius.circular(30),
          //       //                         bottomRight: Radius.circular(30))),
          //       //                 child: Icon(
          //       //                   CupertinoIcons.back,
          //       //                   color: Colors.white,
          //       //                 ),
          //       //                 onPressed: () {},
          //       //                 color: Utility.darkColor,
          //       //               ),
          //       //             )
          //       //           : SizedBox(
          //       //               height: 60,
          //       //               width: 60,
          //       //               child: RaisedButton(
          //       //                 shape: RoundedRectangleBorder(
          //       //                     borderRadius: BorderRadius.only(
          //       //                         topLeft: Radius.circular(0),
          //       //                         bottomLeft: Radius.circular(0),
          //       //                         topRight: Radius.circular(30),
          //       //                         bottomRight: Radius.circular(30))),
          //       //                 child: Icon(
          //       //                   CupertinoIcons.back,
          //       //                   color: Colors.white,
          //       //                 ),
          //       //                 onPressed: null,
          //       //               ),
          //       //             ),
          //       //       showPre
          //       //           ? SizedBox(
          //       //               height: 60,
          //       //               width: 60,
          //       //               child: RaisedButton(
          //       //                 shape: RoundedRectangleBorder(
          //       //                     borderRadius: BorderRadius.only(
          //       //                         topLeft: Radius.circular(30),
          //       //                         bottomLeft: Radius.circular(30),
          //       //                         topRight: Radius.circular(0),
          //       //                         bottomRight: Radius.circular(0))),
          //       //                 child: Icon(
          //       //                   CupertinoIcons.forward,
          //       //                   color: Colors.white,
          //       //                 ),
          //       //                 onPressed: () {},
          //       //                 color: Utility.darkColor,
          //       //               ),
          //       //             )
          //       //           : SizedBox(
          //       //               height: 60,
          //       //               width: 60,
          //       //               child: RaisedButton(
          //       //                 shape: RoundedRectangleBorder(
          //       //                     borderRadius: BorderRadius.only(
          //       //                         topLeft: Radius.circular(30),
          //       //                         bottomLeft: Radius.circular(30),
          //       //                         topRight: Radius.circular(0),
          //       //                         bottomRight: Radius.circular(0))),
          //       //                 child: Icon(
          //       //                   CupertinoIcons.forward,
          //       //                   color: Colors.white,
          //       //                 ),
          //       //                 onPressed: null,
          //       //               ),
          //       //             )
          //       //     ],
          //       //   ),
          //       // ),

          //     ],
          //   ),
          // ),
          ),
    );
  }

  Future getData() async {
    await dbNHelper.deleteNotificationTable();
    setState(() {
      getAllN = true;
    });
    String url = "?UserId=${widget.userid}";
    //"?UserId=${widget.userid}&pageSize=500";

    dios.Response response;
    dios.Dio dio = dios.Dio();
    dio.options.headers = {
      "Accept": "application/json",
      'phrUsername': 'phr_user',
      'phrPassword': 'phr20150*'
    };
    print(Utility.baseUrltest + Utility.getAllNotification + url);
    try {
      response = await dio.post(
          Utility.baseUrltest + Utility.getAllNotification + url,
          cancelToken: diotoken);
      //print(" Notification " + response.data.toString());
      if (response.statusCode == 200) {
        // print("get Notification " + response.data.toString());
        var verifyresponse;
        if (response.data['success'] == true) {
          if (response.data['errorcode'] == null) {
            verifyresponse = response.data['Items'];
            setState(() {
              if (verifyresponse != null) {
                itemsNoti = verifyresponse;
                var list = List.from(itemsNoti);
                //print("getData " + list.length.toString());

                setState(() {
                  //_currentMax = list.length;
                  showError = false;
                });
                _getApiData();
              }
            });
          } else {
            setState(() {
              showError = false;
            });
          }

          //print(data['user']);
        } else {
          if (response.data['message'].toString().compareTo("Data Not Found") ==
              0) {
            // scaffoldKey.currentState.showSnackBar(SnackBar(
            //     content: Text("Error while Getting New Notification.")));
            int count = await dbNHelper.getCount();
            print(count);
            if (count == 0) {
              setState(() {
                showError = true;
                showDeleteButton = false;
                errorMessage = "There is No New Notification.";
              });
            }
          }
        }
      } else {
        scaffoldKey.currentState.showSnackBar(
            SnackBar(content: Text("Error while Getting New Notification.")));
        debugPrint(response.statusCode.toString());
      }
      // await http
      //     .get(
      //   Utility.baseUrltest + Utility.getNotificationPaging + url,
      //   headers: headers,
      // ).then((response) {
      // });
    } catch (e) {
      //debugPrint(e.toString());
    }
  }

  Future<List<NotificationModel>> _getApiData() async {
    //print("data");
    //date = await dbNHelper.getLastDate();
    List<NotificationModel> notificationModel = [];
    if (itemsNoti != null) {
      for (var data in itemsNoti) {
        var dataDate = data["SentOn"]
            .toString()
            .replaceAll("am", "")
            .replaceAll("pm", "")
            .split(" ");
        //print(data["SentOn"]
        //    .toString()
        //    .replaceAll("am", "")
        //    .replaceAll("pm", ""));
        NotificationModel notification = NotificationModel(
            notificationid: data["Id"].toString(),
            title: data['Title'],
            message: data["Message"],
            sentOn: data["SentOn"].toString(),
            pushOn: data["PushOn"].toString(),
            readOn: data["ReadOn"].toString(),
            date: dataDate[1].toString(),
            newN: data["ReadOn"].toString().compareTo("null") == 0
                ? true
                : false);
        if (date != dataDate[0]) {
          date = dataDate[0];
          await dbNHelper
              .save(NotificationModel(
                  notificationid: data["Id"].toString() + "datefordateToshow",
                  title: "datefordateToshow",
                  message: "datefordateToshow",
                  sentOn: data["SentOn"].toString(),
                  pushOn: data["PushOn"].toString(),
                  readOn: data["ReadOn"].toString(),
                  date: dataDate[1].toString(),
                  newN: data["ReadOn"].toString().compareTo("null") == 0
                      ? true
                      : false))
              .then((onValue) async {
            await dbNHelper.save(notification);
          });
        } else {
          await dbNHelper.save(notification);
        }
      }
    }
    setState(() {
      getAllN = false;
    });
    if (mounted) Provider.of<NotificationDatabase>(context).setDatalistShow = 1;
    markASReadNotifications(widget.userid);
    return notificationModel;
  }

  Future markASReadNotification(NotificationModel model) async {
    setState(() {
      sendNeedUpdate = true;
    });
    String url = "?MessageId=${model.notificationid}";
    var date = DateTime.now();
    String readonDate = DateFormat("dd/MM/yyyy").format(date);

    dios.Response response;
    dios.Dio dio = dios.Dio();
    dio.options.headers = {
      "Accept": "application/json",
      'phrUsername': 'phr_user',
      'phrPassword': 'phr20150*'
    };
    print(Utility.baseUrltest + Utility.markNotification + url);
    try {
      response =
          await dio.post(Utility.baseUrltest + Utility.markNotification + url);
      print(response.statusCode);
      if (response.statusCode == 200) {
        print(response.data);
        if (response.data['success'] == true) {
          dbNHelper.updateNotification(NotificationModel(
              title: model.title,
              readOn: "$readonDate",
              message: model.message,
              notificationid: model.notificationid,
              pushOn: "",
              sentOn: "",
              date: "",
              newN: true));
          //print(data['user']);
          Provider.of<NotificationDatabase>(context).setDatalistShow = 1;
        } else {
          scaffoldKey.currentState.showSnackBar(
              SnackBar(content: Text("Error while Updatting Notification.")));
        }
      } else {
        scaffoldKey.currentState.showSnackBar(
            SnackBar(content: Text("Error while Updatting Notification.")));
        print(response.statusCode.toString());
      }
      // await http
      //     .post(b
      //       Utility.baseUrltest + Utility.markNotification + url,
      //       headers: headers,
      //     )
      //     .then((response) {});
    } catch (e) {
      //debugPrint(e.toString());
    }
  }

  Future markASReadNotifications(String userId) async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    var notificationsetMark = _pref.getInt("notificationsetMark");
    if (notificationsetMark == null) {
      _pref.setInt("notificationsetMark", 0);
    } else {
      _pref.setInt("notificationsetMark", notificationsetMark + 1);
      // setState(() {
      //   showPro = false;
      // });
    }
    //print("notificationsetMark " + notificationsetMark.toString());
    if (notificationsetMark == null || (notificationsetMark % 2) == 0) {
      setState(() {
        sendNeedUpdate = true;
      });
      //print(sendNeedUpdate);
      String url = "?MessageId=&UserId=$userId";
      var date = DateTime.now();
      String readonDate = DateFormat("dd/MM/yyyy HH:mm a").format(date);

      dios.Response response;
      dios.Dio dio = dios.Dio();
      dio.options.headers = {
        "Accept": "application/json",
        'phrUsername': 'phr_user',
        'phrPassword': 'phr20150*'
      };
      print(Utility.baseUrltest + Utility.markNotification + url);
      try {
        response = await dio
            .post(Utility.baseUrltest + Utility.markNotification + url);
        print(response.statusCode);
        if (response.statusCode == 200) {
          //print(response.data);
          if (response.data['success'] == true) {
            dbNHelper.updateNotifications(readonDate);
            //print(data['user']);
            Provider.of<NotificationDatabase>(context).setDatalistShow = 1;
          } else {
            scaffoldKey.currentState.showSnackBar(
                SnackBar(content: Text("Error while Updatting Notification.")));
          }
        } else {
          scaffoldKey.currentState.showSnackBar(
              SnackBar(content: Text("Error while Updatting Notification.")));
          print(response.statusCode.toString());
        }
        // await http
        //     .post(b
        //       Utility.baseUrltest + Utility.markNotification + url,
        //       headers: headers,
        //     )
        //     .then((response) {});
      } catch (e) {
        //debugPrint(e.toString());
      }
    }
  }

  Future mDeleteNotification(String id) async {
    String url = "?MessageId=$id";

    dios.Response response;
    dios.Dio dio = dios.Dio();
    dio.options.headers = {
      "Accept": "application/json",
      'phrUsername': 'phr_user',
      'phrPassword': 'phr20150*'
    };
    try {
      response = await dio
          .post(Utility.baseUrltest + Utility.deleteNotification + url);
      if (response.statusCode == 200) {
        // print(response.data);
        if (response.data['success'] == true) {
          //await dbNHelper.deleteNotification(id);
          //await dbNHelper.deleteNotificationTable();
          await getData();
          Navigator.of(context, rootNavigator: true).pop();
          // scaffoldKey.currentState.showSnackBar(
          //     SnackBar(content: Text("${response.data['message']}")));
          //Provider.of<NotificationDatabase>(context).setDatalistShow = 1;
          setState(() {
            showDeleteButton = false;
            isSelectAll = false;
            listDeletedData = [];
          });
        } else {
          scaffoldKey.currentState.showSnackBar(
              SnackBar(content: Text("Error while Deleting Notification")));
        }
      } else {
        debugPrint(response.statusCode.toString());
        scaffoldKey.currentState.showSnackBar(
            SnackBar(content: Text("Error while Deleting Notification")));
      }
      // await http
      //     .post(
      //       Utility.baseUrltest + Utility.deleteNotification + url,
      //       headers: headers,
      //     ).then((response) async {});
    } catch (e) {
      //debugPrint(e.toString());
    }
  }

  Future<void> _getMoreData() async {
    if (itemsNoti != null) {
      setState(() {
        showPro = true;
      });
      var list = List.from(itemsNoti);
      //print("_getMoreData" + list.length.toString());

      await Future.delayed(Duration(milliseconds: 700));
      var count = await dbNHelper.getDateCount();
      //print("count " + count.toString());
      if (list.length > _currentMax) {
        _currentMax = list.length + count;
      } else if (list.length < _currentMax) {
        _currentMax += (10 + count);
      }
      setState(() {
        if (list.length > _currentMax) {
          _currentMax = list.length + count;
        }
        showPro = false;
      });
    }
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
                        color: Utility.darkColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0),
                  ),
                  color: Utility.lightColor,
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
                      color: Utility.darkColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0),
                ),
                color: Utility.lightColor,
                onPressed: () {
                  if (isSelectAll != true) {
                    if (listDeletedData != null) {
                      mDeleteNotification(listDeletedData
                          .toList()
                          .toString()
                          .replaceAll("[", "")
                          .replaceAll("]", "")
                          .replaceAll(" ", ""));
                      showNotificationDialog(
                          context, "Deleting Notification....");
                    }
                  } else {
                    mDeleteNotification("all");
                    showNotificationDialog(
                        context, "Deleting Notification....");
                  }

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
