import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onexbet/ressources/local/onexbetDataBase.dart';
import 'package:onexbet/screens/home.dart';
import 'package:onexbet/screens/login.dart';

class Onexbet extends StatefulWidget {
  final List<User> users;
  final OnexbetDataBase onexbetDataBase;
  Onexbet({this.onexbetDataBase, this.users});
  @override
  _OnexbetState createState() => _OnexbetState();
}

class _OnexbetState extends State<Onexbet> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return (widget.users.isEmpty)
        ? Login(
            onexbetDataBase: widget.onexbetDataBase,
          )
        : Home(
            onexbetDataBase: widget.onexbetDataBase,
            numero: widget.users.first.numero,
            email: widget.users.first.email,
          );
  }
}
