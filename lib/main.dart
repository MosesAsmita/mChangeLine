import 'package:flutter/material.dart';
import 'package:onexbet/onexbet.dart';
import 'package:onexbet/ressources/local/onexbetDataBase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  OnexbetDataBase onexbetDataBase = OnexbetDataBase();
  List users = await onexbetDataBase.getAllUsers();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'M-Change Line',
      home: Onexbet(
        users: users,
        onexbetDataBase: onexbetDataBase,
      ),
    ),
  );
}
