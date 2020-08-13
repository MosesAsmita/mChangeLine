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
import 'package:onexbet/screens/xbet/retrait.dart';
import 'package:onexbet/screens/xbet/recharge.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class Xbet extends StatefulWidget {
  final OnexbetDataBase onexbetDataBase;
  final String numero;
  final List<DocumentSnapshot> pourcentages;
  Xbet({this.numero,this.pourcentages, this.onexbetDataBase});
  @override
  _XbetState createState() => _XbetState();
}

class _XbetState extends State<Xbet> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List grid;
  final Permission _permission = Permission.phone;
  PermissionStatus _permissionStatus = PermissionStatus.undetermined;
  List<DocumentSnapshot> pourcentages = [];
  bool spinner = false, isConnected = false;
  String recharges, retraits;
  @override
  void initState() {
    super.initState();
    permissionStatus();
    verifyConnection();
    pourcentages = widget.pourcentages;
    grid = [
      {
        'name': 'Recharges',
        'icon': 'images/recharge.png',
      },
      {
        'name': 'Retraits',
        'icon': 'images/retrait.png',
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
        ),
        body: Stack(
          children: <Widget>[
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 0.0,
              crossAxisSpacing: 0.0,
              semanticChildCount: grid.length,
              children: grid.map((data) {
                return GestureDetector(
                    child: Card(
                      margin: EdgeInsets.all(5.0),
                      elevation: 5.0,
                      child: Container(
                        height: 400.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                              height: 120.0,
                              child: Image.asset(
                                data['icon'],
                                cacheWidth: 80,
                              ),
                            ),
                            Text(
                              data['name'],
                              style: textStyle,
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    ),
                    onTap: () async {
                      if (_permissionStatus != PermissionStatus.granted) {
                        permissionStatus();
                      } else if (!isConnected) {
                        verifyConnection();
                      } else {
                        (data['name'] == 'Retraits')
                            ? Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return Retrait(
                                onexbetDataBase: widget.onexbetDataBase,
                                pourcentageRetrait:
                                pourcentages.first.data['%retrait'],
                                numero: widget.numero,
                              );
                            }))
                            : Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return Recharge(
                                onexbetDataBase: widget.onexbetDataBase,
                                numero: widget.numero,
                                pourcentageRecharges:
                                pourcentages.first.data['%recharge'],
                              );
                            }));
                      }
                    });
              }).toList(),
            ),
          ],
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
}

