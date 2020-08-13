import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:onexbet/constants/externalWidget.dart';
import 'package:onexbet/ressources/connection/onexbetNeworkingHelper.dart';
import 'package:onexbet/ressources/local/onexbetDataBase.dart';
import 'package:onexbet/screens/home.dart';
import 'package:permission_handler/permission_handler.dart';

class Login extends StatefulWidget {
  final OnexbetDataBase onexbetDataBase;
  Login({this.onexbetDataBase});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldkey = GlobalKey<ScaffoldState>();
  final Permission _permission = Permission.phone;
  PermissionStatus _permissionStatus = PermissionStatus.undetermined;
  List<DocumentSnapshot> pourcentages = [];
  Map<String, dynamic> usersInfos = {
    'num': '',
    'email': null,
  };
  bool spinner = false, isConnected = false;

  @override
  void initState() {
    super.initState();
    permissionStatus();
    verifyConnection();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: spinner,
      progressIndicator: waitMsg(),
      child: Scaffold(
        key: _scaffoldkey,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Image.asset(
                'images/logo.png',
                filterQuality: FilterQuality.high,
                cacheHeight: 320,
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    textField(
                        fieldName: 'Numéro de Téléphone',
                        prefixText: '+229',
                        validator: (String value) {
                          Pattern pattern = r'^[0-9]*$';
                          RegExp regExp = RegExp(pattern);
                          if (value.isEmpty) {
                            return 'Entrez votre numéro de téléphone';
                          } else if (value.length != 8 ||
                              !regExp.hasMatch(value)) {
                            return 'Entrez un numéro de téléphone valide';
                          }
                          return null;
                        },
                        onSaved: (value) => usersInfos['num'] = value,
                        textInputType: TextInputType.number),
                    textField(
                        fieldName: 'Email',
                        validator: (String value) {
                          Pattern pattern =
                              r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$';
                          RegExp regExp = RegExp(pattern);
                          if (value.isNotEmpty && !regExp.hasMatch(value)) {
                            return 'Entrer une email valide';
                          }
                          return null;
                        },
                        onSaved: (value) => usersInfos['email'] = value,
                        textInputType: TextInputType.emailAddress),
                    raisedButton(context, label: 'Se connecter',
                        onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        if (_permissionStatus != PermissionStatus.granted) {
                          permissionStatus();
                        } else if (!isConnected) {
                          verifyConnection();
                        } else {
                          spinner = true;
                          setState(() {});
                          save();
                        }
                      }
                    }, colors: Colors.orange),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
  void showSnackBar() {
    final snackBarContent = SnackBar(
      content: Text("Verifiez votre connexion internet puis ressayer."),
      action: SnackBarAction(
          label: 'OK',
          onPressed: _scaffoldkey.currentState.hideCurrentSnackBar),
      duration: Duration(seconds: 3),
    );
    _scaffoldkey.currentState.showSnackBar(snackBarContent);
  }

  save() async {
    await OnexbetNetworkingHelper.sendData(
        collectionName: 'users',
        dataToSend: {
          'numero': '+229' + usersInfos['num'],
          'email': usersInfos['email']
        });
    final user = User(numero: usersInfos['num'], email: usersInfos['email']);
    widget.onexbetDataBase.insertUsers(user);
    spinner = false;
    setState(() {});
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return Home(onexbetDataBase: widget.onexbetDataBase,
          numero: usersInfos['num'],
          email: usersInfos['email'],);
    }));
  }
}
