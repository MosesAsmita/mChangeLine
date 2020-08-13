import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:onexbet/constants/constant.dart';
import 'package:onexbet/constants/externalWidget.dart';
import 'package:onexbet/ressources/connection/onexbetNeworkingHelper.dart';
import 'package:onexbet/ressources/local/onexbetDataBase.dart';
import 'package:onexbet/screens/statistiques.dart';
import 'package:onexbet/screens/transaction.dart';
import 'package:onexbet/screens/xbet/xbet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  final OnexbetDataBase onexbetDataBase;
  final String numero, email;
  Home({this.numero, this.email, this.onexbetDataBase});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List grid;
  final Permission _permission = Permission.phone;
  PermissionStatus _permissionStatus = PermissionStatus.undetermined;
  List<DocumentSnapshot> pourcentages = [];
  bool spinner = false, isConnected = false, isAdmin = false;
  String recharges, retraits;
  @override
  void initState() {
    super.initState();
    permissionStatus();
    verifyConnection();
    grid = [
      {
        'icon': 'images/xbet.png',
        'function': () async {
          if (_permissionStatus != PermissionStatus.granted) {
            permissionStatus();
          } else if (!isConnected) {
            verifyConnection();
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return Xbet(
                onexbetDataBase: widget.onexbetDataBase,
                pourcentages: pourcentages,
                numero: widget.numero,
              );
            }));
          }
        }
      },
      {
        'icon': 'images/payeer.png',
        'function': () => Future.delayed(
            Duration.zero, () => alert(currentChoice: 'PAYEER Mobile'))
      },
      {
        'icon': 'images/perfect.png',
        'function': () => Future.delayed(
            Duration.zero, () => alert(currentChoice: 'Perfect Mobile'))
      }
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: spinner,
      progressIndicator: waitMsg(),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('M-Change Line'),
          centerTitle: true,
          backgroundColor: Colors.orange,
          leading: InkWell(
            onTap: () => _scaffoldKey.currentState.openDrawer(),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('images/avatar.png'),
              ),
            ),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text('+229' + widget.numero),
                accountEmail: Text(widget.email),
                decoration: BoxDecoration(color: Colors.orange),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage('images/logo.png'),
                ),
              ),
              (isAdmin)
                  ? Column(
                      children: <Widget>[
                        Card(
                          elevation: 5,
                          child: ExpansionTile(
                            leading: Icon(Icons.person),
                            title: Text('Administrateur'),
                            children: <Widget>[
                              Card(
                                elevation: 5,
                                child: ListTile(
                                  trailing: Icon(Icons.arrow_forward_ios),
                                  title: Text('Transactions'),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return Transactions();
                                    }));
                                  },
                                ),
                              ),
                              Card(
                                elevation: 5,
                                child: ListTile(
                                  trailing: Icon(Icons.arrow_forward_ios),
                                  title: Text('Pourcentages'),
                                  onTap: () {
                                    Pattern pattern =
                                        r'[0-9]{1,13}(\\.[0-9]*)?$';
                                    RegExp regExp = RegExp(pattern);
                                    Navigator.of(context).pop();
                                    dialog(
                                      context: context,
                                      content: Column(
                                        children: <Widget>[
                                          Text(
                                              'Veuillez définir un pourcentage pour les recharges et les retraits'),
                                          textField(
                                              fieldName: 'Recharge',
                                              value: pourcentages
                                                  .first.data['%recharge']
                                                  .toString(),
                                              helperText:
                                                  'Entrer le pourcentage des recharges',
                                              autoValidate: true,
                                              validator: (String value) {
                                                if (value.isEmpty ||
                                                    !regExp.hasMatch(value) ||
                                                    !(double.parse(value) >=
                                                            0.0 &&
                                                        double.parse(value) <=
                                                            100.0)) {
                                                  return 'Entrer un pourcentage valide';
                                                } else {
                                                  recharges = value;
                                                }
                                                return null;
                                              },
                                              textInputType:
                                                  TextInputType.number),
                                          textField(
                                              fieldName: 'Retrait',
                                              value: pourcentages
                                                  .first.data['%retrait']
                                                  .toString(),
                                              helperText:
                                                  'Entrer un pourcentage pour les retraits',
                                              autoValidate: true,
                                              validator: (String value) {
                                                if (value.isEmpty ||
                                                    !regExp.hasMatch(value) ||
                                                    !(double.parse(value) >=
                                                            0.0 &&
                                                        double.parse(value) <=
                                                            100.0)) {
                                                  return 'Entrer un pourcentage valide';
                                                } else {
                                                  retraits = value;
                                                }
                                                return null;
                                              },
                                              textInputType:
                                                  TextInputType.number),
                                        ],
                                      ),
                                      fstBtnTxt: 'Sauvegarder',
                                      fstBtnOnPressed: () async {
                                        print('$recharges $retraits');
                                        Navigator.pop(context);
                                        spinner = true;
                                        setState(() {});
                                        await OnexbetNetworkingHelper
                                            .updateDocuments(
                                                collection: 'pourcentages',
                                                dataToSend: {
                                                  '%recharge':
                                                      double.parse(recharges),
                                                  '%retrait':
                                                      double.parse(retraits),
                                                },
                                                documentID:
                                                    'MPU51SvzJPBRXLFBJUO0');
                                        await fetchPourcentage();
                                        spinner = false;
                                        setState(() {});
                                      },
                                      sndBtnTxt: 'Annuler',
                                      sndBtnOnPressed: () {
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          elevation: 5,
                          child: ExpansionTile(
                            leading: Icon(Icons.people),
                            title: Text('Clients'),
                            children: <Widget>[
                              Card(
                                elevation: 5,
                                child: ListTile(
                                  trailing: Icon(Icons.arrow_forward_ios),
                                  title: Text('Statistiques'),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return Statistiques(
                                        numero: widget.numero,
                                        onexbetDataBase: widget.onexbetDataBase,
                                      );
                                    }));
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                  : Card(
                      elevation: 5,
                      child: ListTile(
                        trailing: Icon(Icons.arrow_forward_ios),
                        title: Text('Statistiques'),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return Statistiques(
                              numero: widget.numero,
                              onexbetDataBase: widget.onexbetDataBase,
                            );
                          }));
                        },
                      ),
                    ),
            ],
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 12,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Flexible(
                      child: ListView(
                        children: <Widget>[
                          customCard(grid[0]),
                          customCard(grid[1]),
                          customCard(grid[2]),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0.0, 0.0, 30.0, 30.0),
                    width: double.maxFinite,
                    color: Colors.orange,
                    height: 25.0,
                    child: ScrollingText(
                      text:
                          'Pour tous problèmes, n\'hesitez pas à contacter M-Change Line. M-Change Line, ouvert de 8 h 30 min à 23 h 30 min. PAYEER Mobile & Perfect Mobile bientôt disponible.',
                      textStyle: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange,
          child: CircleAvatar(
            backgroundImage: AssetImage('images/whatsapp.jpg'),
          ),
          onPressed: launchWhatsApp,
        ),
      ),
    );
  }

  fetchPourcentage() async {
    pourcentages =
        await OnexbetNetworkingHelper.getData(collectionName: 'pourcentages');
    retraits = pourcentages.first.data['%retrait'].toString();
    recharges = pourcentages.first.data['%recharge'].toString();
    setState(() {});
  }

  void showSnackBar() {
    final snackBarContent = SnackBar(
      content: Text("Verifiez votre connexion internet puis ressayer."),
      action: SnackBarAction(
          label: 'OK',
          onPressed: _scaffoldKey.currentState.hideCurrentSnackBar),
      duration: Duration(seconds: 3),
    );
    _scaffoldKey.currentState.showSnackBar(snackBarContent);
  }

  void permissionStatus() async {
    final status = await _permission.status;
    setState(() {
      _permissionStatus = status;
      if (_permissionStatus != PermissionStatus.granted)
        requestPermission(_permission);
    });
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();

    setState(() {
      _permissionStatus = status;
    });
  }

  verifyConnection() async {
    if (this.mounted) {
      spinner = true;
      setState(() {});
    }
    Connectivity connectivity = Connectivity();
    var connectivityResult = await (connectivity.checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
        final result = await InternetAddress.lookup('github.com')
            .timeout(const Duration(seconds: 15));
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          isConnected = true;
          await fetchPourcentage();
          spinner = false;
          setState(() {});
        }
      } on SocketException catch (_) {
        isConnected = false;
        spinner = false;
        setState(() {});
        showSnackBar();
      } on TimeoutException catch (_) {
        isConnected = false;
        spinner = false;
        setState(() {});
        showSnackBar();
      }
    } else if (connectivityResult == ConnectivityResult.none) {
      isConnected = false;
      spinner = false;
      setState(() {});
      showSnackBar();
    }
  }

  void launchWhatsApp() async {
    String url =
        "whatsapp://send?phone=+22964429602&text=${Uri.parse("Cc M-Change Line")}";

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  alert({String currentChoice}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text('M-Change Line'),
          content: Text(
              '$currentChoice\nBientôt disponible dans votre application M-Change Line.'),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Compris',
                style: textStyle.copyWith(color: Colors.blue),
              ),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

class ScrollingText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final Axis scrollAxis;
  final double ratioOfBlankToScreen;

  ScrollingText({
    @required this.text,
    this.textStyle,
    this.scrollAxis: Axis.horizontal,
    this.ratioOfBlankToScreen: 0.25,
  }) : assert(
          text != null,
        );

  @override
  State<StatefulWidget> createState() {
    return ScrollingTextState();
  }
}

class ScrollingTextState extends State<ScrollingText>
    with SingleTickerProviderStateMixin {
  ScrollController scrollController;
  double screenWidth;
  double screenHeight;
  double position = 0.0;
  Timer timer;
  final double _moveDistance = 3.0;
  final int _timerRest = 100;
  GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      startTimer();
    });
  }

  void startTimer() {
    if (_key.currentContext != null) {
      double widgetWidth =
          _key.currentContext.findRenderObject().paintBounds.size.width;
      double widgetHeight =
          _key.currentContext.findRenderObject().paintBounds.size.height;

      timer = Timer.periodic(Duration(milliseconds: _timerRest), (timer) {
        double maxScrollExtent = scrollController.position.maxScrollExtent;
        double pixels = scrollController.position.pixels;
        if (pixels + _moveDistance >= maxScrollExtent) {
          if (widget.scrollAxis == Axis.horizontal) {
            position = (maxScrollExtent -
                        screenWidth * widget.ratioOfBlankToScreen +
                        widgetWidth) /
                    2 -
                widgetWidth +
                pixels -
                maxScrollExtent;
          } else {
            position = (maxScrollExtent -
                        screenHeight * widget.ratioOfBlankToScreen +
                        widgetHeight) /
                    2 -
                widgetHeight +
                pixels -
                maxScrollExtent;
          }
          scrollController.jumpTo(position);
        }
        position += _moveDistance;
        scrollController.animateTo(position,
            duration: Duration(milliseconds: _timerRest), curve: Curves.linear);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  Widget getBothEndsChild() {
    if (widget.scrollAxis == Axis.vertical) {
      String newString = widget.text.split("").join("\n");
      return Center(
        child: Text(
          newString,
          style: widget.textStyle,
          textAlign: TextAlign.center,
        ),
      );
    }
    return Center(
        child: Text(
      widget.text,
      style: widget.textStyle,
    ));
  }

  Widget getCenterChild() {
    if (widget.scrollAxis == Axis.horizontal) {
      return Container(width: screenWidth * widget.ratioOfBlankToScreen);
    } else {
      return Container(height: screenHeight * widget.ratioOfBlankToScreen);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (timer != null) {
      timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: _key,
      scrollDirection: widget.scrollAxis,
      controller: scrollController,
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        getBothEndsChild(),
        getCenterChild(),
        getBothEndsChild(),
      ],
    );
  }
}
