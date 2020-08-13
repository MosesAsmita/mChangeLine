import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:onexbet/constants/constant.dart';
import 'package:onexbet/constants/externalWidget.dart';
import 'package:onexbet/ressources/connection/onexbetNeworkingHelper.dart';
import 'package:onexbet/ressources/local/onexbetDataBase.dart';
import 'package:onexbet/screens/statistiques.dart';

class Retrait extends StatefulWidget {
  final String numero;
  final double pourcentageRetrait;
  final OnexbetDataBase onexbetDataBase;
  Retrait({this.pourcentageRetrait, this.numero, this.onexbetDataBase});
  @override
  _RetraitState createState() => _RetraitState();
}

class _RetraitState extends State<Retrait> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> retraitInfos = {
    'id1xBet': '',
    'montant': '',
    'montant_tarif': '',
    'num': '',
    'nom': '',
    'code': '',
    'request_status': false
  };
  List<String> selectionList = [];
  bool spinner = false, isVisible = false;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var initializationSettingAndroid,
      initializationSettingIOS,
      initializationSettings;

  @override
  void initState() {
    super.initState();
    initializationSettingAndroid = AndroidInitializationSettings('app_icon');
    initializationSettingIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(
        initializationSettingAndroid, initializationSettingIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    Future.delayed(Duration.zero, () => alert());
  }

  void _showNotification({String body, String payload}) async {
    await _demoNotification(body: body, payload: payload);
  }

  Future _demoNotification({String body, String payload}) async {
    var androidPlatformChannelSpecifis = AndroidNotificationDetails(
        'channel_ID', 'channel_name', 'channel_description',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'test ticker');
    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifis, iOSChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        0, 'M-Change Line - Retrait', body, platformChannelSpecifics,
        payload: payload);
  }

  Future onSelectNotification(String payload) async {
    if (retraitInfos['request_status']) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Statistiques(
          numero: widget.numero,
        );
      }));
    }
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(body),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: spinner,
      progressIndicator: waitMsg(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          title: Text('Retrait'),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: () {
                    Future.delayed(Duration.zero, () => alert());
                  }),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                textField(
                    value: widget.numero,
                    fieldName: 'Numéro de Téléphone',
                    prefixText: '+229',
                    helperText: ' Entrez votre numéro de téléphone',
                    validator: (String value) {
                      Pattern pattern = r'^[0-9]*$';
                      RegExp regExp = RegExp(pattern);
                      if (value.isEmpty ||
                          value.length != 8 ||
                          !regExp.hasMatch(value)) {
                        return 'Entrez votre numéro MTNMoMo';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      retraitInfos['num'] = '+229' + value;
                    },
                    textInputType: TextInputType.number),
                SizedBox(
                  height: 8.0,
                ),
                textField(
                    fieldName: 'Appartenant à',
                    helperText: ' Entrez le nom du propriétaire du numéro',
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'Entrez le nom du propriétaire du numéro';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      retraitInfos['nom'] = value;
                    },
                    textInputType: TextInputType.text),
                SizedBox(
                  height: 8.0,
                ),
                textField(
                  fieldName: 'ID du compte 1XBET',
                  helperText: 'Ex: 85786214785',
                  prefixText: 'ID ',
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Entrer l\' ID du compte 1XBET';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    retraitInfos['id1xBet'] = value;
                  },
                ),
                SizedBox(
                  height: 8.0,
                ),
                textField(
                  obscureText: isVisible,
                  fieldName: 'Code (Token)',
                  helperText: 'Entrez le code généré',
                  prefixIcon: Icon(Icons.lock),
                  onChanged: (value) {
                    retraitInfos['code'] = value;
                  },
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Entrer le code du compte 1XBET';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 8.0,
                ),
                textField(
                    fieldName: 'Montant à retirer',
                    validator: (String value) {
                      Pattern pattern = r'^[0-9]*$';
                      RegExp regExp = RegExp(pattern);
                      if (value.isEmpty) {
                        return 'Vueillez entrer un montant';
                      } else if (!regExp.hasMatch(value)) {
                        return 'Entrer un montant valide';
                      } else if (int.parse(value) < 500) {
                        return 'Les recharges sont à partir de 500 FCFA';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      retraitInfos['montant'] = value;
                    },
                    textInputType: TextInputType.number),
                SizedBox(
                  height: 15.0,
                ),
                raisedButton(context, label: 'Retrait', onPressed: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    retraitInfos['montant_tarif'] =
                        (double.parse(retraitInfos['montant']) -
                                (double.parse(retraitInfos['montant']) *
                                        widget.pourcentageRetrait) /
                                    100)
                            .toInt()
                            .toString();
                    dialog(
                      context: context,
                      content: contentRetrait(retraitInfos),
                      fstBtnTxt: 'Continuer',
                      fstBtnOnPressed: () async {
                        Navigator.pop(context);
                        setState(() {
                          spinner = true;
                        });
                        save();
                      },
                      sndBtnTxt: 'Annuler',
                      sndBtnOnPressed: () {
                        Navigator.pop(context);
                      },
                    );
                  }
                }, colors: Colors.green),
              ],
            ),
          ),
        ),
      ),
    );
  }

  save() async {
    DocumentReference reference = await OnexbetNetworkingHelper.sendData(
        collectionName: 'retraits',
        dataToSend: {
          'appartenant': retraitInfos['nom'],
          'id_xbet': retraitInfos['id1xBet'],
          'montant_tarif': retraitInfos['montant_tarif'],
          'montant': retraitInfos['montant'],
          'numero': retraitInfos['num'],
          'status': false,
          'date': DateTime.now().toString(),
          'code': retraitInfos['code']
        });
    final transfert = Transfert(
        documentID: reference.documentID,
        type: 'retraits',
        numero: '+229' + widget.numero);
    await widget.onexbetDataBase.insertTransferts(transfert);
    retraitInfos['request_status'] = true;
    setState(() {
      spinner = false;
    });
    _showNotification(
        body:
            'Vous aviez ordonner un retait de ${retraitInfos['montant']} sur votre compte 1xBet ID: ${retraitInfos['id_xbet']}. Votre demande est en cours de traitement.',
        payload: 'confirm');
    Navigator.pop(context);
  }

  alert() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text('M-Change Line'),
          content: Text(
            'Comment retirer ?\nToutes les étapes de la procédure sont obligatoires et c’est au client de l’effectuer.\nAvant toute chose, le client doit s’assurer d’avoir remplir correctement la partie PROFIL PERSONNEL dans son compte 1XBET.\n1ère étape (Dans votre compte 1XBET)\n1 - Appuyez sur Retirer\n2 - Choisissez le moyen de paiement 1XBET Espèces\n3 - Saisissez le Montant à Retirer\n4 - Choisissez Ville : Cotonou\n5 - Choisissez Rue : M-Change Line\n6 - Confirmez avec le code envoyé par 1XBET sur le numéro lié au compte puis valider.\n7 - Patientez un instant que la transaction affiche Approuvée et appuyer sur Obtenir le Code. Une fois le code généré, copier le et rediriger vers l\'option Retirer.\n2ème étape (Remplir les champs de l\'option Retrait de l\'application M-Change Line).',
          ),
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
