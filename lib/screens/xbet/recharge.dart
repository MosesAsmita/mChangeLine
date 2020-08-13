import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile_number/sim_card.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:onexbet/constants/externalWidget.dart';
import 'package:onexbet/ressources/connection/onexbetNeworkingHelper.dart';
import 'package:onexbet/ressources/local/onexbetDataBase.dart';
import 'package:onexbet/screens/dashboard.dart';
import 'package:onexbet/screens/statistiques.dart';
import 'package:ussd_service/ussd_service.dart';

class Recharge extends StatefulWidget {
  final double pourcentageRecharges;
  final String numero;
  final OnexbetDataBase onexbetDataBase;
  Recharge({this.pourcentageRecharges, this.numero, this.onexbetDataBase});
  @override
  _RechargeState createState() => _RechargeState();
}

class _RechargeState extends State<Recharge> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> rechargeInfos = {
    'id1xBet': '',
    'montant': '',
    'montant_tarif': '',
    'num': '',
    'pin': '',
    'request_status': false
  };
  bool spinner = false, isVisible = false;
  SimCard _simCard;

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
        0, 'M-Change Line - Recharge', body, platformChannelSpecifics,
        payload: payload);
  }

  Future onSelectNotification(String payload) async {
    if (rechargeInfos['request_status']) {
      Navigator.pop(context);
      await Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) {
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
          title: Text('Recharge'),
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
                      if (value.isEmpty) {
                        return 'Entrez votre numéro de téléphone';
                      } else if (value.length != 8 || !regExp.hasMatch(value)) {
                        return 'Entrez un numéro de téléphone valide';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      rechargeInfos['num'] = '+229' + value;
                    },
                    textInputType: TextInputType.number),
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
                    rechargeInfos['id1xBet'] = value;
                  },
                ),
                SizedBox(
                  height: 8.0,
                ),
                textField(
                    fieldName: 'Montant à recharger',
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
                      rechargeInfos['montant'] = value;
                    },
                    textInputType: TextInputType.number),
                SizedBox(
                  height: 15.0,
                ),
                raisedButton(context, label: 'Recharger', onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    FocusScope.of(context).requestFocus(FocusNode());
                    _simCard = await showBarModalBottomSheet(
                      context: context,
                      builder: (context, scrollController) {
                        return Container(
                          height: 300.0,
                          child: Dashboard(),
                        );
                      },
                    );

                    if (_simCard != null) {
                      rechargeInfos['montant_tarif'] =
                          (double.parse(rechargeInfos['montant']) +
                                  (double.parse(rechargeInfos['montant']) *
                                          widget.pourcentageRecharges) /
                                      100)
                              .toInt()
                              .toString();

                      dialog(
                        context: context,
                        content: contentRecharge(
                          rechargeInfos,
                          textField(
                              fieldName: _simCard.carrierName == 'MTN'
                                  ? 'Code PIN MoMo'
                                  : (_simCard.carrierName == 'Etisalat Benin')
                                      ? 'Code PIN Flooz'
                                      : _simCard.carrierName,
                              helperText: (_simCard.carrierName == 'MTN')
                                  ? 'Entrez votre code PIN MoMo'
                                  : (_simCard.carrierName == 'Etisalat Benin')
                                      ? 'Entrez votre code PIN Flooz'
                                      : 'Entrez votre code PIN',
                              autoValidate: true,
                              prefixIcon: Icon(Icons.lock),
                              onChanged: (value) {
                                rechargeInfos['pin'] = value;
                              },
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return 'Entrer votre code PIN';
                                } else if (_simCard.carrierName == 'MTN' &&
                                    value.length != 5) {
                                  return 'Entrer votre code PIN';
                                } else if (_simCard.carrierName ==
                                        'Etisalat Benin' &&
                                    value.length != 4) {
                                  return 'Entrer votre code PIN';
                                }
                                return null;
                              },
                              textInputType: TextInputType.number),
                        ),
                        fstBtnTxt: 'Continuer',
                        fstBtnOnPressed: () async {
                          if (_simCard.carrierName == 'MTN' &&
                              rechargeInfos['pin'].length == 5) {
                            Navigator.pop(context);
                            setState(() {
                              spinner = true;
                            });
                            await makeMyRequest();
                          } else if (_simCard.carrierName == 'Etisalat Benin' &&
                              (rechargeInfos['pin'].length == 4 ||
                                  rechargeInfos['pin'].length == 5)) {
                            Navigator.pop(context);
                            setState(() {
                              spinner = true;
                            });
                            await makeMyRequest();
                          }
                        },
                        sndBtnTxt: 'Annuler',
                        sndBtnOnPressed: () {
                          Navigator.pop(context);
                        },
                      );
                    }
                  }
                }, colors: Colors.green),
              ],
            ),
          ),
        ),
      ),
    );
  }

  makeMyRequest() async {
    int subscriptionId = _simCard.slotIndex;
    String code;

    if (_simCard.carrierName == 'MTN')
      code =
          "*400*1*1*96551416*96551416*${rechargeInfos['montant_tarif']}*${rechargeInfos['id1xBet']}*${rechargeInfos['pin']}#";
    else if (_simCard.carrierName == 'Etisalat Benin')
      code =
          "*155*1*1*1*64429602*64429602*${rechargeInfos['montant_tarif']}*${rechargeInfos['pin']}#";
    try {
      var ussdResponseMessage = await UssdService.makeRequest(
        subscriptionId,
        code,
        Duration(seconds: 10),
      );
      if (ussdResponseMessage.contains('Transfert effectue pour ') ||
          ussdResponseMessage.contains('ID de la transaction') ||
          ussdResponseMessage.contains('Ref')) {
        save();
        rechargeInfos['request_status'] = true;
        setState(() {
          spinner = false;
        });
        _showNotification(
            body:
                'Vous aviez ordonner une recharge de ${rechargeInfos['montant']} sur votre compte 1xBet ID: ${rechargeInfos['id_xbet']}. Votre demande est en cours de traitement.',
            payload: 'confirm');
        Navigator.pop(context);
      } else {
        setState(() {
          spinner = false;
        });
        alert(context: context);
      }
    } catch (e) {
      debugPrint("error! code: ${e.code} - message: ${e.message}");
      setState(() {
        spinner = false;
      });
    }
  }

  save() async {
    DocumentReference reference = await OnexbetNetworkingHelper.sendData(
        collectionName: 'recharges',
        dataToSend: {
          'id_xbet': rechargeInfos['id1xBet'],
          'montant': rechargeInfos['montant'],
          'montant_tarif': rechargeInfos['montant_tarif'],
          'date': DateTime.now().toString(),
          'moyen_paiement': _simCard.carrierName,
          'numero': rechargeInfos['num'],
          'status': false
        });

    final transfert = Transfert(
        documentID: reference.documentID,
        type: 'recharges',
        numero: '+229' + widget.numero);
    await widget.onexbetDataBase.insertTransferts(transfert);
  }
}
